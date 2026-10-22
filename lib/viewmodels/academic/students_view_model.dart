import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';

class StudentsViewModel extends ChangeNotifier {
  StudentsViewModel({required this.academicClass, List<Student>? students})
    : _students = students ?? SampleStudents.forClass(academicClass.id);

  final AcademicClass academicClass;
  final List<Student> _students;

  List<Student> get students => List.unmodifiable(
    _students.where((student) => student.classId == academicClass.id),
  );

  Student? studentById(String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }
}

/// Gera uma relação de estudantes determinística para cada turma de exemplo.
class SampleStudents {
  SampleStudents._();

  static const _names = [
    'Ana Clara Souza',
    'Bruno Martins Lima',
    'Camila Rodrigues Alves',
    'Daniel Costa Ribeiro',
    'Eduarda Ferreira Santos',
    'Felipe Oliveira Nunes',
    'Giovana Mendes Rocha',
    'Henrique Carvalho Dias',
    'Isabela Moreira Pinto',
    'João Pedro Barros',
    'Larissa Teixeira Melo',
    'Mateus Gomes Freitas',
    'Natália Azevedo Cunha',
    'Otávio Cardoso Reis',
    'Paula Cristina Duarte',
    'Rafael Monteiro Lopes',
    'Sofia Batista Campos',
    'Thiago Fernandes Costa',
    'Vitória Almeida Moraes',
    'William Silva Prado',
  ];

  static List<Student> forClass(String classId) {
    final classIndex = AcademicClass.sampleClasses.indexWhere(
      (item) => item.id == classId,
    );
    if (classIndex < 0) return const [];
    final academicClass = AcademicClass.sampleClasses[classIndex];

    return List.generate(academicClass.studentsCount, (index) {
      final name = _names[index % _names.length];
      final suffix = index >= _names.length ? ' ${index + 1}' : '';
      final number = (classIndex + 1) * 1000 + index + 1;
      return Student(
        id: '$classId-aluno-${index + 1}',
        classId: classId,
        name: '$name$suffix',
        registration: '2026${number.toString().padLeft(5, '0')}',
        email: 'aluno$number@exemplo.edu.br',
        attendance: 78 + ((index * 7 + classIndex * 3) % 23),
        averageGrade: 5 + ((index * 13 + classIndex * 9) % 50) / 10,
      );
    });
  }
}
