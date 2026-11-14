import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';
import '../../services/students_repository.dart';

class StudentsViewModel extends ChangeNotifier {
  StudentsViewModel({
    required this.academicClass,
    List<Student>? students,
    StudentsRepository? repository,
    this.onStudentsCountChanged,
  })  : _repository = repository,
        _students = students != null
            ? List.of(students)
            : (repository != null
                ? []
                : List.of(SampleStudents.forClass(academicClass.id))) {
    if (repository != null && students == null) {
      _isLoading = true;
      _loadFromRepository();
    } else {
      _isLoading = false;
    }
  }

  final AcademicClass academicClass;
  final StudentsRepository? _repository;
  final ValueChanged<int>? onStudentsCountChanged;
  List<Student> _students;
  bool _isLoading = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalStudentsCount =>
      _students.where((s) => s.classId == academicClass.id).length;

  List<Student> get students {
    final classStudents =
        _students.where((student) => student.classId == academicClass.id);
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(classStudents.toList());
    }
    final query = _searchQuery.toLowerCase().trim();
    return List.unmodifiable(
      classStudents.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.registration.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query);
      }).toList(),
    );
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> _loadFromRepository() async {
    if (_repository == null) return;
    final loaded = await _repository!.getStudentsForClass(academicClass.id);
    _students = List.of(loaded);
    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona um novo estudante na turma
  Future<void> addStudent({
    required String name,
    required String registration,
    required String email,
  }) async {
    final newStudent = Student(
      id: '${academicClass.id}-aluno-${DateTime.now().millisecondsSinceEpoch}',
      classId: academicClass.id,
      name: name.trim(),
      registration: registration.trim(),
      email: email.trim(),
      attendance: 100,
      averageGrade: 0.0,
    );

    _students.insert(0, newStudent);
    notifyListeners();
    onStudentsCountChanged?.call(totalStudentsCount);
    await _repository?.saveStudent(newStudent);
  }

  /// Atualiza os dados de um estudante existente
  Future<void> updateStudent(Student updatedStudent) async {
    final index = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      notifyListeners();
      await _repository?.saveStudent(updatedStudent);
    }
  }

  /// Remove um estudante pelo ID
  Future<void> removeStudent(String id) async {
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
    onStudentsCountChanged?.call(totalStudentsCount);
    await _repository?.deleteStudent(id);
  }

  Student? studentById(String id) {
    for (final student in _students) {
      if (student.id == id && student.classId == academicClass.id) {
        return student;
      }
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
