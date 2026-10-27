import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/models/academic/academic_class.dart';
import 'package:eduguard/models/grades/assessment.dart';
import 'package:eduguard/models/grades/grade_record.dart';
import 'package:eduguard/services/grades_repository.dart';
import 'package:eduguard/viewmodels/academic/students_view_model.dart';
import 'package:eduguard/viewmodels/grades/grades_view_model.dart';
import 'package:eduguard/views/grades/grade_results_view.dart';
import 'package:eduguard/views/grades/grades_view.dart';

class _FailingGradesRepository extends GradesRepository {
  _FailingGradesRepository() : super(populateSamples: false);

  @override
  Future<List<Assessment>> getAssessmentsForClass(String classId) async {
    throw Exception('offline');
  }
}

void main() {
  final sampleClass = AcademicClass.sampleClasses.first;
  final students = SampleStudents.forClass(sampleClass.id).take(3).toList();

  Assessment buildAssessment({
    String id = 'aval-teste',
    double maxScore = 10,
    double weight = 1,
  }) {
    return Assessment(
      id: id,
      classId: sampleClass.id,
      title: 'Prova $id',
      type: AssessmentType.exam,
      maxScore: maxScore,
      weight: weight,
      date: DateTime(2026, 10, 20),
    );
  }

  group('Grade Models', () {
    test('Assessment valida nota dentro da escala', () {
      final a = buildAssessment(maxScore: 5);
      expect(a.isValidScore(0), isTrue);
      expect(a.isValidScore(5), isTrue);
      expect(a.isValidScore(5.01), isFalse);
      expect(a.isValidScore(-1), isFalse);
      expect(a.scaleLabel, '0 a 5');
    });

    test('formatScore usa vírgula e remove zeros à direita', () {
      expect(Assessment.formatScore(7.5), '7,5');
      expect(Assessment.formatScore(10), '10');
      expect(Assessment.formatScore(8.25), '8,25');
    });

    test('GradeRecord e Assessment serializam corretamente', () {
      final record = GradeRecord(
        studentId: 's1',
        studentName: 'Ana',
        classId: sampleClass.id,
        assessmentId: 'aval-1',
        score: 8.5,
        updatedAt: DateTime(2026, 10, 20),
      );
      expect(GradeRecord.fromJson(record.toJson()), record);

      final a = buildAssessment(maxScore: 5, weight: 2);
      final fromJson = Assessment.fromJson(a.toJson());
      expect(fromJson.maxScore, 5);
      expect(fromJson.weight, 2);
      expect(fromJson.type, AssessmentType.exam);
    });
  });

  group('GradesRepository', () {
    late GradesRepository repository;

    setUp(() {
      repository = GradesRepository(populateSamples: false);
    });

    test('substitui notas da avaliação sem duplicar registros', () async {
      final a = buildAssessment();
      await repository.saveAssessment(a);

      GradeRecord grade(double score) => GradeRecord(
        studentId: students.first.id,
        studentName: students.first.name,
        classId: sampleClass.id,
        assessmentId: a.id,
        score: score,
        updatedAt: DateTime.now(),
      );

      await repository.saveGrades(a.id, [grade(6)]);
      await repository.saveGrades(a.id, [grade(9)]);

      final saved = await repository.getGradesForAssessment(a.id);
      expect(saved.length, 1);
      expect(saved.first.score, 9);
    });

    test('rejeita nota fora da escala ou de outra turma', () async {
      final a = buildAssessment(maxScore: 5);
      await repository.saveAssessment(a);

      final outOfScale = GradeRecord(
        studentId: 's1',
        studentName: 'Ana',
        classId: sampleClass.id,
        assessmentId: a.id,
        score: 7,
        updatedAt: DateTime.now(),
      );
      expect(
        () => repository.saveGrades(a.id, [outOfScale]),
        throwsArgumentError,
      );
      expect(
        () => repository.saveGrades(a.id, [
          outOfScale.copyWith(score: 4, classId: 'outra-turma'),
        ]),
        throwsArgumentError,
      );
      expect(await repository.getGradesForAssessment(a.id), isEmpty);
    });

    test('rejeita avaliação com escala inválida', () {
      expect(
        () => repository.saveAssessment(buildAssessment(maxScore: 0)),
        throwsArgumentError,
      );
    });
  });

  group('GradesViewModel', () {
    late GradesRepository repository;
    late GradesViewModel viewModel;

    setUp(() async {
      repository = GradesRepository(populateSamples: false);
      await repository.saveAssessment(buildAssessment(id: 'p1'));
      await repository.saveAssessment(
        buildAssessment(id: 'trab', maxScore: 5, weight: 3),
      );
      viewModel = GradesViewModel(
        academicClass: sampleClass,
        students: students,
        repository: repository,
      );
      await Future<void>.delayed(Duration.zero);
    });

    test('carrega avaliações e seleciona a primeira', () {
      expect(viewModel.status, GradesStatus.success);
      expect(viewModel.assessments.length, 2);
      expect(viewModel.selectedAssessment?.id, 'p1');
      expect(viewModel.launchedCount, 0);
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('valida notas conforme a escala da avaliação', () {
      expect(viewModel.validateScoreInput(''), isNull);
      expect(viewModel.validateScoreInput('7,5'), isNull);
      expect(viewModel.validateScoreInput('10'), isNull);
      expect(viewModel.validateScoreInput('10,5'), isNotNull);
      expect(viewModel.validateScoreInput('abc'), isNotNull);
      expect(viewModel.validateScoreInput('1,2,3'), isNotNull);
      expect(viewModel.validateScoreInput('7,555'), isNotNull);

      viewModel.selectAssessment('trab');
      expect(viewModel.validateScoreInput('5'), isNull);
      expect(viewModel.validateScoreInput('6'), isNotNull);
    });

    test('impede salvar com nota inválida', () async {
      viewModel.setScoreInput(students[0].id, '11');
      expect(viewModel.hasErrors, isTrue);
      expect(viewModel.canSave, isFalse);
      expect(await viewModel.saveGrades(), isFalse);
      expect(await repository.getGradesForAssessment('p1'), isEmpty);
    });

    test('salva, consulta e edita notas vinculadas a estudante, turma e avaliação',
        () async {
      viewModel.setScoreInput(students[0].id, '8,5');
      viewModel.setScoreInput(students[1].id, '6');
      expect(viewModel.launchedCount, 2);
      expect(viewModel.pendingCount, 1);
      expect(viewModel.currentAverage, closeTo(7.25, 0.001));

      expect(await viewModel.saveGrades(), isTrue);
      expect(viewModel.hasUnsavedChanges, isFalse);
      expect(viewModel.isExistingLaunch, isTrue);

      final saved = await repository.getGradesForAssessment('p1');
      expect(saved.length, 2);
      final first = saved.firstWhere((g) => g.studentId == students[0].id);
      expect(first.classId, sampleClass.id);
      expect(first.assessmentId, 'p1');
      expect(first.score, 8.5);

      // Consulta
      expect(viewModel.savedScore('p1', students[0].id), 8.5);
      expect(viewModel.scoreInput(students[0].id), '8,5');

      // Edição: altera uma nota e remove outra
      viewModel.setScoreInput(students[0].id, '9');
      viewModel.setScoreInput(students[1].id, '');
      expect(await viewModel.saveGrades(), isTrue);
      expect(viewModel.savedScore('p1', students[0].id), 9);
      expect(viewModel.savedScore('p1', students[1].id), isNull);
      expect(viewModel.savedCount('p1'), 1);
    });

    test('notas são isoladas por avaliação', () async {
      viewModel.setScoreInput(students[0].id, '8');
      await viewModel.saveGrades();

      viewModel.selectAssessment('trab');
      expect(viewModel.scoreInput(students[0].id), '');
      viewModel.setScoreInput(students[0].id, '4');
      await viewModel.saveGrades();

      expect(viewModel.savedScore('p1', students[0].id), 8);
      expect(viewModel.savedScore('trab', students[0].id), 4);
    });

    test('calcula média ponderada normalizada para 0 a 10', () async {
      viewModel.setScoreInput(students[0].id, '8'); // 8/10, peso 1
      await viewModel.saveGrades();
      viewModel.selectAssessment('trab');
      viewModel.setScoreInput(students[0].id, '5'); // 10/10, peso 3
      await viewModel.saveGrades();

      expect(viewModel.weightedAverage(students[0].id), closeTo(9.5, 0.001));
      expect(viewModel.weightedAverage(students[1].id), isNull);
    });

    test('descarta alterações não salvas', () async {
      viewModel.setScoreInput(students[0].id, '7');
      await viewModel.saveGrades();
      viewModel.setScoreInput(students[0].id, '3');
      expect(viewModel.hasUnsavedChanges, isTrue);

      viewModel.discardChanges();
      expect(viewModel.scoreInput(students[0].id), '7');
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('cadastra nova avaliação e a seleciona', () async {
      final created = await viewModel.createAssessment(
        title: 'Seminário Final',
        type: AssessmentType.presentation,
        maxScore: 20,
        weight: 2,
        date: DateTime(2026, 11, 10),
      );
      expect(created, isTrue);
      expect(viewModel.assessments.length, 3);
      expect(viewModel.selectedAssessment?.title, 'Seminário Final');
      expect(viewModel.validateScoreInput('20'), isNull);
    });

    test('exibe estado vazio sem avaliações e estado de erro em falha', () async {
      final emptyVm = GradesViewModel(
        academicClass: sampleClass,
        students: students,
        repository: GradesRepository(populateSamples: false),
      );
      await Future<void>.delayed(Duration.zero);
      expect(emptyVm.status, GradesStatus.empty);

      final errorVm = GradesViewModel(
        academicClass: sampleClass,
        students: students,
        repository: _FailingGradesRepository(),
      );
      await Future<void>.delayed(Duration.zero);
      expect(errorVm.status, GradesStatus.error);
      expect(errorVm.errorMessage, isNotNull);
    });
  });

  group('GradesView', () {
    Future<GradesViewModel> pumpGradesView(
      WidgetTester tester, {
      GradesRepository? repository,
    }) async {
      final repo = repository ?? GradesRepository(populateSamples: false);
      if (repository == null) {
        await repo.saveAssessment(buildAssessment(id: 'p1'));
      }
      final vm = GradesViewModel(
        academicClass: sampleClass,
        students: students,
        repository: repo,
      );
      await tester.pumpWidget(MaterialApp(home: GradesView(viewModel: vm)));
      await tester.pumpAndSettle();
      return vm;
    }

    testWidgets('exibe estudantes da turma e a avaliação selecionada',
        (tester) async {
      await pumpGradesView(tester);

      expect(find.text('Lançamento de Notas'), findsOneWidget);
      expect(find.text('Prova p1'), findsOneWidget);
      expect(find.text(students.first.name), findsOneWidget);
      expect(find.text('0 de 3 notas lançadas'), findsOneWidget);
    });

    testWidgets('mostra erro de validação ao digitar nota fora da escala',
        (tester) async {
      await pumpGradesView(tester);

      await tester.enterText(find.byType(TextFormField).first, '12');
      await tester.pump();

      expect(find.text('Máximo 10'), findsOneWidget);
      expect(find.text('1 nota(s) inválida(s)'), findsOneWidget);
    });

    testWidgets('salva notas e exibe confirmação', (tester) async {
      final vm = await pumpGradesView(tester);

      await tester.enterText(find.byType(TextFormField).first, '9,5');
      await tester.pump();
      await tester.tap(find.text('Salvar Notas'));
      await tester.pumpAndSettle();

      expect(vm.savedScore('p1', students.first.id), 9.5);
      expect(find.textContaining('salvas com sucesso'), findsOneWidget);
      expect(find.text('Atualizar Notas'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando não há avaliações', (tester) async {
      final vm = GradesViewModel(
        academicClass: sampleClass,
        students: students,
        repository: GradesRepository(populateSamples: false),
      );
      await tester.pumpWidget(MaterialApp(home: GradesView(viewModel: vm)));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma avaliação cadastrada'), findsOneWidget);
    });

    testWidgets('exibe estado de erro com opção de recarregar', (tester) async {
      await pumpGradesView(tester, repository: _FailingGradesRepository());

      expect(find.text('Falha ao carregar notas'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('consulta resultados salvos', (tester) async {
      final vm = await pumpGradesView(tester);
      vm.setScoreInput(students.first.id, '8');
      await vm.saveGrades();

      await tester.tap(find.byTooltip('Consultar Resultados'));
      await tester.pumpAndSettle();

      expect(find.byType(GradeResultsView), findsOneWidget);
      expect(find.text('Prova p1: 8/10'), findsOneWidget);
    });
  });
}
