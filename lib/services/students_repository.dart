import 'dart:convert';

import '../models/academic/academic_class.dart';
import '../models/academic/student.dart';
import '../viewmodels/academic/students_view_model.dart';
import 'storage/key_value_store.dart';

/// Repositório de Estudantes do professor autenticado.
///
/// Persiste os estudantes no [KeyValueStore] sob o escopo do docente.
/// Permite carregar, cadastrar, atualizar e remover estudantes por turma.
class StudentsRepository {
  StudentsRepository({
    KeyValueStore? store,
    bool populateSamples = true,
    this.storageKey = 'students',
  }) : _store = store {
    if (store == null) {
      if (populateSamples) _populateDefaultSamples();
      _ready = Future.value();
    } else {
      _ready = _restore(populateSamples);
    }
  }

  final KeyValueStore? _store;
  final String storageKey;
  final List<Student> _students = [];
  late final Future<void> _ready;

  /// Retorna todos os alunos vinculados a uma turma específica.
  Future<List<Student>> getStudentsForClass(String classId) async {
    await _ready;
    return List.unmodifiable(
      _students.where((s) => s.classId == classId).toList(),
    );
  }

  /// Adiciona ou substitui um estudante.
  Future<void> saveStudent(Student student) async {
    await _ready;
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      _students[index] = student;
    } else {
      _students.insert(0, student);
    }
    await _persist();
  }

  /// Remove um estudante pelo seu identificador.
  Future<void> deleteStudent(String studentId) async {
    await _ready;
    _students.removeWhere((s) => s.id == studentId);
    await _persist();
  }

  void _populateDefaultSamples() {
    for (final ac in AcademicClass.sampleClasses) {
      _students.addAll(SampleStudents.forClass(ac.id));
    }
  }

  Future<void> _restore(bool populateSamples) async {
    final raw = await _store!.read(storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _students.addAll(
        list.map((e) => Student.fromJson(e as Map<String, dynamic>)),
      );
      return;
    }
    // Primeiro acesso: popula os alunos de exemplo e persiste.
    if (populateSamples) {
      _populateDefaultSamples();
      await _persist();
    }
  }

  Future<void> _persist() async {
    await _store?.write(
      storageKey,
      jsonEncode(_students.map((s) => s.toJson()).toList()),
    );
  }
}

