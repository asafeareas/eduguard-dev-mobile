import 'dart:convert';

import '../models/academic/academic_class.dart';
import '../models/grades/assessment.dart';
import '../models/grades/grade_record.dart';
import '../viewmodels/academic/students_view_model.dart';
import 'storage/key_value_store.dart';

/// Repositório de Notas.
///
/// Armazena avaliações e notas, garantindo que cada nota esteja vinculada a um
/// estudante, a uma turma e a uma avaliação existente. Com um [KeyValueStore]
/// (escopado ao professor), persiste os dados localmente entre sessões; sem ele,
/// mantém tudo apenas em memória (útil em testes).
class GradesRepository {
  GradesRepository({
    bool populateSamples = true,
    KeyValueStore? store,
    this.storageKey = 'grades',
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
  late final Future<void> _ready;

  /// Armazenamento em memória: assessment.id -> Assessment
  final Map<String, Assessment> _assessments = {};

  /// Armazenamento em memória: grade.id -> GradeRecord
  final Map<String, GradeRecord> _grades = {};

  /// Retorna as avaliações de uma turma, ordenadas pela data de aplicação
  Future<List<Assessment>> getAssessmentsForClass(String classId) async {
    await _ready;
    final list = _assessments.values
        .where((a) => a.classId == classId)
        .toList();

    list.sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(list);
  }

  /// Salva ou atualiza uma avaliação.
  Future<void> saveAssessment(Assessment assessment) async {
    await _ready;
    if (assessment.title.trim().isEmpty) {
      throw ArgumentError('A avaliação precisa de um título.');
    }
    if (assessment.maxScore <= Assessment.minScore) {
      throw ArgumentError('A nota máxima deve ser maior que zero.');
    }
    if (assessment.weight <= 0) {
      throw ArgumentError('O peso da avaliação deve ser maior que zero.');
    }
    _assessments[assessment.id] = assessment;
    await _persist();
  }

  /// Retorna as notas lançadas em uma avaliação
  Future<List<GradeRecord>> getGradesForAssessment(String assessmentId) async {
    await _ready;
    return List.unmodifiable(
      _grades.values.where((g) => g.assessmentId == assessmentId),
    );
  }

  /// Retorna todas as notas lançadas em uma turma
  Future<List<GradeRecord>> getGradesForClass(String classId) async {
    await _ready;
    return List.unmodifiable(
      _grades.values.where((g) => g.classId == classId),
    );
  }

  /// Substitui as notas de uma avaliação pelas informadas.
  /// Estudantes sem registro na lista passam a ficar sem nota lançada.
  /// Rejeita notas fora da escala ou vinculadas a outra turma/avaliação.
  Future<void> saveGrades(
    String assessmentId,
    List<GradeRecord> records,
  ) async {
    await _ready;
    final assessment = _assessments[assessmentId];
    if (assessment == null) {
      throw StateError('Avaliação não encontrada.');
    }

    for (final record in records) {
      if (record.assessmentId != assessment.id ||
          record.classId != assessment.classId) {
        throw ArgumentError(
          'Nota de ${record.studentName} não pertence à avaliação selecionada.',
        );
      }
      if (!assessment.isValidScore(record.score)) {
        throw ArgumentError(
          'Nota de ${record.studentName} fora da escala ${assessment.scaleLabel}.',
        );
      }
    }

    final now = DateTime.now();
    _grades.removeWhere((_, g) => g.assessmentId == assessmentId);
    for (final record in records) {
      _grades[record.id] = record.copyWith(updatedAt: now);
    }
    await _persist();
  }

  /// Limpa todos os registros (útil para testes unitários)
  void clear() {
    _assessments.clear();
    _grades.clear();
    _store?.delete(storageKey);
  }

  Future<void> _restore(bool populateSamples) async {
    final raw = await _store!.read(storageKey);
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final item in data['assessments'] as List<dynamic>) {
        final a = Assessment.fromJson(item as Map<String, dynamic>);
        _assessments[a.id] = a;
      }
      for (final item in data['grades'] as List<dynamic>) {
        final g = GradeRecord.fromJson(item as Map<String, dynamic>);
        _grades[g.id] = g;
      }
      return;
    }
    // Primeiro acesso do professor: cria uma cópia própria dos exemplos.
    if (populateSamples) {
      _populateDefaultSamples();
      await _persist();
    }
  }

  Future<void> _persist() async {
    await _store?.write(
      storageKey,
      jsonEncode({
        'assessments': _assessments.values.map((a) => a.toJson()).toList(),
        'grades': _grades.values.map((g) => g.toJson()).toList(),
      }),
    );
  }

  /// Popula avaliações de exemplo e notas da primeira avaliação de cada turma
  void _populateDefaultSamples() {
    final now = DateTime.now();
    for (final ac in AcademicClass.sampleClasses) {
      final samples = [
        Assessment(
          id: 'aval-${ac.id}-p1',
          classId: ac.id,
          title: 'Prova 1',
          type: AssessmentType.exam,
          maxScore: 10,
          weight: 4,
          date: _daysAgo(now, 14),
        ),
        Assessment(
          id: 'aval-${ac.id}-trabalho',
          classId: ac.id,
          title: 'Trabalho Prático',
          type: AssessmentType.assignment,
          maxScore: 5,
          weight: 2,
          date: _daysAgo(now, 3),
        ),
        Assessment(
          id: 'aval-${ac.id}-p2',
          classId: ac.id,
          title: 'Prova 2',
          type: AssessmentType.exam,
          maxScore: 10,
          weight: 4,
          date: _daysAgo(now, -20),
        ),
      ];
      for (final a in samples) {
        _assessments[a.id] = a;
      }

      // Notas determinísticas apenas para a Prova 1
      final first = samples.first;
      final students = SampleStudents.forClass(ac.id);
      for (var i = 0; i < students.length; i++) {
        final s = students[i];
        final record = GradeRecord(
          studentId: s.id,
          studentName: s.name,
          classId: ac.id,
          assessmentId: first.id,
          score: 4 + ((i * 7 + 3) % 13) / 2,
          updatedAt: first.date,
        );
        _grades[record.id] = record;
      }
    }
  }
}

/// Data de exemplo sem horário, [days] dias antes de [from] (negativo = futuro).
DateTime _daysAgo(DateTime from, int days) {
  final d = from.subtract(Duration(days: days));
  return DateTime(d.year, d.month, d.day);
}
