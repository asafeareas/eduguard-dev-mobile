import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/models/academic/academic_class.dart';
import 'package:eduguard/viewmodels/academic/students_view_model.dart';
import 'package:eduguard/views/academic/student_detail_view.dart';
import 'package:eduguard/views/academic/students_view.dart';

void main() {
  test(
    'cada turma recebe estudantes vinculados ao seu próprio identificador',
    () {
      final classes = AcademicClass.sampleClasses;
      final first = StudentsViewModel(academicClass: classes[0]);
      final second = StudentsViewModel(academicClass: classes[1]);

      expect(first.students, hasLength(classes[0].studentsCount));
      expect(second.students, hasLength(classes[1].studentsCount));
      expect(
        first.students.every((student) => student.classId == classes[0].id),
        isTrue,
      );
      expect(
        second.students.every((student) => student.classId == classes[1].id),
        isTrue,
      );
      expect(first.students.first.id, isNot(second.students.first.id));
    },
  );

  testWidgets('abre detalhes do estudante selecionado a partir da turma', (
    tester,
  ) async {
    final academicClass = AcademicClass.sampleClasses[1];
    final viewModel = StudentsViewModel(academicClass: academicClass);

    await tester.pumpWidget(
      MaterialApp(home: StudentsView(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text(academicClass.name), findsOneWidget);
    expect(
      find.text(
        '${academicClass.code} • ${academicClass.studentsCount} estudantes',
      ),
      findsOneWidget,
    );
    expect(find.text(viewModel.students.first.name), findsOneWidget);

    await tester.tap(find.text(viewModel.students.first.name));
    await tester.pumpAndSettle();

    expect(find.byType(StudentDetailView), findsOneWidget);
    expect(find.text('Detalhes do estudante'), findsOneWidget);
    expect(find.text(viewModel.students.first.email), findsOneWidget);
    expect(find.text(academicClass.name), findsOneWidget);
  });
}
