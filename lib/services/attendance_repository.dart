import 'dart:convert';

import '../models/academic/academic_class.dart';
import '../models/attendance/attendance_record.dart';
import '../models/attendance/attendance_session.dart';
import '../viewmodels/academic/students_view_model.dart';
import 'storage/key_value_store.dart';

/// Repositório de Frequência.
///
/// Armazena chamadas e previne duplicações na mesma data. Com um [KeyValueStore]
/// (escopado ao professor), persiste os dados localmente entre sessões; sem ele,
/// mantém tudo apenas em memória (útil em testes).
class AttendanceRepository {
  AttendanceRepository({
    bool populateSamples = true,
    KeyValueStore? store,
    this.storageKey = 'attendance',
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

  /// Cache em memória: session.id -> AttendanceSession
  final Map<String, AttendanceSession> _sessions = {};

  /// Salva ou atualiza uma sessão de chamada.
  /// Previne duplicidade: se já existir chamada para a mesma turma e data, ela é atualizada.
  Future<void> saveSession(AttendanceSession session) async {
    await _ready;
    final normalizedDate = AttendanceSession.normalizeDate(session.date);
    final key = AttendanceSession.generateId(session.classId, normalizedDate);

    final cleanSession = session.copyWith(
      id: key,
      date: normalizedDate,
      updatedAt: DateTime.now(),
    );

    _sessions[key] = cleanSession;
    await _persist();
  }

  /// Recupera a chamada de uma turma em uma data específica
  Future<AttendanceSession?> getSession(String classId, DateTime date) async {
    await _ready;
    final key = AttendanceSession.generateId(classId, date);
    return _sessions[key];
  }

  /// Retorna todas as chamadas salvas de uma turma específica, ordenadas da mais recente para a mais antiga
  Future<List<AttendanceSession>> getSessionsForClass(String classId) async {
    await _ready;
    final list = _sessions.values
        .where((s) => s.classId == classId)
        .toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  /// Remove uma sessão de chamada
  Future<bool> deleteSession(String classId, DateTime date) async {
    await _ready;
    final key = AttendanceSession.generateId(classId, date);
    final removed = _sessions.remove(key);
    if (removed != null) await _persist();
    return removed != null;
  }

  /// Limpa todos os registros (útil para testes unitários)
  void clear() {
    _sessions.clear();
    _store?.delete(storageKey);
  }

  Future<void> _restore(bool populateSamples) async {
    final raw = await _store!.read(storageKey);
    if (raw != null) {
      for (final item in jsonDecode(raw) as List<dynamic>) {
        final session =
            AttendanceSession.fromJson(item as Map<String, dynamic>);
        _sessions[session.id] = session;
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
      jsonEncode(_sessions.values.map((s) => s.toJson()).toList()),
    );
  }

  /// Popula chamadas de exemplo para que o professor possa consultar o histórico imediatamente
  void _populateDefaultSamples() {
    final now = DateTime.now();
    for (final ac in AcademicClass.sampleClasses) {
      final students = SampleStudents.forClass(ac.id);
      if (students.isEmpty) continue;

      // Cria 2 chamadas de datas anteriores
      final dates = [
        now.subtract(const Duration(days: 7)),
        now.subtract(const Duration(days: 2)),
      ];

      for (var i = 0; i < dates.length; i++) {
        final d = dates[i];
        final records = students.map((s) {
          // Determina presença determinística
          final isPresent = ((s.id.hashCode + i * 3) % 10) >= 2;
          return AttendanceRecord(
            studentId: s.id,
            studentName: s.name,
            isPresent: isPresent,
          );
        }).toList();

        final session = AttendanceSession(
          id: AttendanceSession.generateId(ac.id, d),
          classId: ac.id,
          date: AttendanceSession.normalizeDate(d),
          records: records,
          updatedAt: d.add(const Duration(hours: 2)),
          topic: i == 0 ? 'Aula Inaugural e Ementa' : 'Conceitos Fundamentais',
        );

        _sessions[session.id] = session;
      }
    }
  }
}
