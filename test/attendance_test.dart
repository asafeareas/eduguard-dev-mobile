import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/models/academic/academic_class.dart';
import 'package:eduguard/models/attendance/attendance_record.dart';
import 'package:eduguard/models/attendance/attendance_session.dart';
import 'package:eduguard/services/attendance_repository.dart';
import 'package:eduguard/viewmodels/academic/students_view_model.dart';
import 'package:eduguard/viewmodels/attendance/attendance_view_model.dart';
import 'package:eduguard/views/attendance/attendance_history_view.dart';
import 'package:eduguard/views/attendance/attendance_view.dart';

void main() {
  final sampleClass = AcademicClass.sampleClasses.first;
  final sampleStudents = SampleStudents.forClass(sampleClass.id);

  group('Attendance Models', () {
    test('AttendanceRecord serializa e desserializa corretamente', () {
      const record = AttendanceRecord(
        studentId: 'aluno-01',
        studentName: 'Ana Clara',
        isPresent: true,
        observation: 'Chegou no horário',
      );

      final json = record.toJson();
      final fromJson = AttendanceRecord.fromJson(json);

      expect(fromJson.studentId, record.studentId);
      expect(fromJson.studentName, record.studentName);
      expect(fromJson.isPresent, isTrue);
      expect(fromJson.observation, 'Chegou no horário');
    });

    test('AttendanceSession calcula presenças, faltas e porcentagem com precisão', () {
      final date = DateTime(2026, 10, 23);
      final records = [
        const AttendanceRecord(studentId: '1', studentName: 'A', isPresent: true),
        const AttendanceRecord(studentId: '2', studentName: 'B', isPresent: true),
        const AttendanceRecord(studentId: '3', studentName: 'C', isPresent: false),
        const AttendanceRecord(studentId: '4', studentName: 'D', isPresent: true),
      ];

      final session = AttendanceSession(
        id: AttendanceSession.generateId('turma-01', date),
        classId: 'turma-01',
        date: date,
        records: records,
        updatedAt: DateTime.now(),
      );

      expect(session.totalStudents, 4);
      expect(session.presentCount, 3);
      expect(session.absentCount, 1);
      expect(session.attendanceRate, 75.0);
      expect(session.formattedDate, '23/10/2026');
    });
  });

  group('AttendanceRepository', () {
    late AttendanceRepository repository;

    setUp(() {
      repository = AttendanceRepository(populateSamples: false);
    });

    test('salva sessão e evita duplicados para a mesma turma e data', () async {
      final date = DateTime(2026, 10, 23, 14, 30); // com horário
      final records1 = [
        const AttendanceRecord(studentId: '1', studentName: 'A', isPresent: true),
      ];

      final session1 = AttendanceSession(
        id: 'temp-id-1',
        classId: 'turma-01',
        date: date,
        records: records1,
        updatedAt: DateTime.now(),
      );

      await repository.saveSession(session1);

      // Segunda chamada no mesmo dia com alteração
      final records2 = [
        const AttendanceRecord(studentId: '1', studentName: 'A', isPresent: false),
      ];
      final session2 = AttendanceSession(
        id: 'temp-id-2',
        classId: 'turma-01',
        date: DateTime(2026, 10, 23, 18, 00),
        records: records2,
        updatedAt: DateTime.now(),
      );

      await repository.saveSession(session2);

      final list = await repository.getSessionsForClass('turma-01');
      expect(list.length, 1); // Não duplicou!
      expect(list.first.records.first.isPresent, isFalse); // Atualizou o valor
    });

    test('recupera sessão por data normalizada', () async {
      final date = DateTime(2026, 10, 24);
      final session = AttendanceSession(
        id: 'id',
        classId: 'turma-02',
        date: date,
        records: const [
          AttendanceRecord(studentId: 'x', studentName: 'Y', isPresent: true),
        ],
        updatedAt: DateTime.now(),
      );

      await repository.saveSession(session);

      final retrieved = await repository.getSession(
        'turma-02',
        DateTime(2026, 10, 24, 23, 59),
      );

      expect(retrieved, isNotNull);
      expect(retrieved!.classId, 'turma-02');
    });
  });

  group('AttendanceViewModel', () {
    late AttendanceRepository repository;
    late AttendanceViewModel viewModel;

    setUp(() async {
      repository = AttendanceRepository(populateSamples: false);
      viewModel = AttendanceViewModel(
        academicClass: sampleClass,
        students: sampleStudents,
        repository: repository,
        initialDate: DateTime(2026, 10, 23),
      );
      // Aguarda inicialização
      await Future<void>.delayed(Duration.zero);
    });

    test('inicia nova chamada com todos os estudantes presentes', () {
      expect(viewModel.totalStudentsCount, sampleStudents.length);
      expect(viewModel.presentCount, sampleStudents.length);
      expect(viewModel.absentCount, 0);
      expect(viewModel.attendanceRate, 100.0);
      expect(viewModel.isSaved, isFalse);
    });

    test('permite alterar marcação antes de finalizar', () {
      final firstStudent = sampleStudents.first;
      expect(viewModel.isPresent(firstStudent.id), isTrue);

      viewModel.toggleStudent(firstStudent.id);
      expect(viewModel.isPresent(firstStudent.id), isFalse);
      expect(viewModel.presentCount, sampleStudents.length - 1);
      expect(viewModel.absentCount, 1);
      expect(viewModel.isSaved, isFalse);

      // Testa também o alias toggleStatus
      viewModel.toggleStatus(firstStudent.id);
      expect(viewModel.isPresent(firstStudent.id), isTrue);
    });

    test('markAll marca todos como presentes ou ausentes', () {
      viewModel.markAll(false);
      expect(viewModel.presentCount, 0);
      expect(viewModel.absentCount, sampleStudents.length);
      expect(viewModel.attendanceRate, 0.0);

      viewModel.markAll(true);
      expect(viewModel.presentCount, sampleStudents.length);
      expect(viewModel.absentCount, 0);
      expect(viewModel.attendanceRate, 100.0);
    });

    test('salvar chamada persiste no repositório e permite consulta posterior', () async {
      viewModel.toggleStudent(sampleStudents.first.id); // 1 falta
      viewModel.updateTopic('Introdução ao Flutter');

      await viewModel.saveAttendance();

      expect(viewModel.isSaved, isTrue);
      expect(viewModel.isExistingSession, isTrue);

      // Simula consulta abrindo nova ViewModel para o mesmo dia
      final secondViewModel = AttendanceViewModel(
        academicClass: sampleClass,
        students: sampleStudents,
        repository: repository,
        initialDate: DateTime(2026, 10, 23),
      );
      await Future<void>.delayed(Duration.zero);

      expect(secondViewModel.isExistingSession, isTrue);
      expect(secondViewModel.isSaved, isTrue);
      expect(secondViewModel.isPresent(sampleStudents.first.id), isFalse);
      expect(secondViewModel.topic, 'Introdução ao Flutter');
    });

    test('filtrar estudantes por busca funciona corretamente', () {
      // Matrícula é única; o nome base se repete em turmas com mais de 20 alunos.
      viewModel.updateSearchFilter(sampleStudents.first.registration);
      expect(viewModel.filteredStudents.length, 1);
      expect(viewModel.filteredStudents.first.name, sampleStudents.first.name);

      viewModel.clearSearch();
      expect(viewModel.filteredStudents.length, sampleStudents.length);
    });
  });

  group('Attendance Views Widgets', () {
    testWidgets('exibe elementos da tela de chamada e permite alternar presenças', (tester) async {
      // Tela alta: a barra inferior translúcida não cobre a lista.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = AttendanceRepository(populateSamples: false);
      final viewModel = AttendanceViewModel(
        academicClass: sampleClass,
        students: sampleStudents.take(5).toList(),
        repository: repository,
        initialDate: DateTime(2026, 10, 23),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AttendanceView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica elementos visuais
      expect(find.text('Registro de Frequência'), findsOneWidget);
      expect(find.text(sampleClass.name), findsOneWidget);
      expect(find.text('23/10/2026'), findsOneWidget);
      expect(find.text('5 presentes de 5'), findsOneWidget);
      expect(find.text('Todos Presentes'), findsOneWidget);
      expect(find.text('Todos Ausentes'), findsOneWidget);

      // Marca o primeiro aluno como ausente tocando no botão 'F'
      final fButtons = find.text('F');
      expect(fButtons, findsWidgets);

      await tester.tap(fButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('4 presentes de 5'), findsOneWidget);

      // Toca em Salvar Chamada
      await tester.tap(find.text('Salvar Chamada'));
      await tester.pumpAndSettle();

      expect(find.textContaining('salva com sucesso'), findsOneWidget);
    });

    testWidgets('abre o histórico de chamadas da turma', (tester) async {
      final repository = AttendanceRepository(populateSamples: true);
      final viewModel = AttendanceViewModel(
        academicClass: sampleClass,
        students: sampleStudents.take(5).toList(),
        repository: repository,
        initialDate: DateTime(2026, 10, 23),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AttendanceView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Toca no botão de histórico no AppBar
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceHistoryView), findsOneWidget);
      expect(find.text('Histórico de Chamadas'), findsOneWidget);
      expect(find.textContaining('chamada(s) registrada(s)'), findsOneWidget);
    });
  });
}
