import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';
import '../../models/attendance/attendance_record.dart';
import '../../models/attendance/attendance_session.dart';
import '../../services/attendance_repository.dart';
import '../academic/students_view_model.dart';

/// ViewModel responsável pelo fluxo de realização, alteração e consulta da chamada.
class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel({
    required this.academicClass,
    List<Student>? students,
    required this._repository,
    DateTime? initialDate,
  })  : _students = students ?? SampleStudents.forClass(academicClass.id),
        _selectedDate = AttendanceSession.normalizeDate(initialDate ?? DateTime.now()) {
    _initializeForCurrentDate();
  }

  final AcademicClass academicClass;
  final List<Student> _students;
  final AttendanceRepository _repository;

  DateTime _selectedDate;
  final Map<String, bool> _attendanceMap = {};
  final Map<String, String?> _observationMap = {};
  String? _topic;
  bool _isSaved = false;
  bool _isExistingSession = false;
  bool _isLoading = false;
  String _searchFilter = '';
  List<AttendanceSession> _history = [];

  // Getters
  DateTime get selectedDate => _selectedDate;
  bool get isSaved => _isSaved;
  bool get isExistingSession => _isExistingSession;
  bool get isLoading => _isLoading;
  String? get topic => _topic;
  String get searchFilter => _searchFilter;
  List<AttendanceSession> get history => List.unmodifiable(_history);

  String get formattedSelectedDate {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    return '$day/$month/${_selectedDate.year}';
  }

  List<Student> get allStudents => List.unmodifiable(_students);

  List<Student> get filteredStudents {
    if (_searchFilter.trim().isEmpty) {
      return List.unmodifiable(_students);
    }
    final q = _searchFilter.toLowerCase().trim();
    return _students.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.registration.toLowerCase().contains(q);
    }).toList();
  }

  int get totalStudentsCount => _students.length;

  int get presentCount =>
      _students.where((s) => _attendanceMap[s.id] ?? true).length;

  int get absentCount => totalStudentsCount - presentCount;

  double get attendanceRate => totalStudentsCount == 0
      ? 0.0
      : (presentCount / totalStudentsCount) * 100;

  bool isPresent(String studentId) => _attendanceMap[studentId] ?? true;

  String? observation(String studentId) => _observationMap[studentId];

  Future<void> _initializeForCurrentDate() async {
    _isLoading = true;
    notifyListeners();

    await loadForDate(_selectedDate);
    await loadHistory();

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega a chamada para uma data específica
  Future<void> loadForDate(DateTime date) async {
    final normalized = AttendanceSession.normalizeDate(date);
    _selectedDate = normalized;

    final existingSession = await _repository.getSession(
      academicClass.id,
      normalized,
    );

    if (existingSession != null) {
      // Carrega registros existentes salvos
      _isExistingSession = true;
      _isSaved = true;
      _topic = existingSession.topic;
      _attendanceMap.clear();
      _observationMap.clear();

      for (final rec in existingSession.records) {
        _attendanceMap[rec.studentId] = rec.isPresent;
        _observationMap[rec.studentId] = rec.observation;
      }

      // Garante que estudantes novos também apareçam
      for (final s in _students) {
        _attendanceMap.putIfAbsent(s.id, () => true);
      }
    } else {
      // Nova chamada em branco: por padrão todos iniciam como presentes
      _isExistingSession = false;
      _isSaved = false;
      _topic = null;
      _attendanceMap.clear();
      _observationMap.clear();
      for (final s in _students) {
        _attendanceMap[s.id] = true;
      }
    }

    notifyListeners();
  }

  /// Altera a data selecionada da chamada (alias para loadForDate)
  Future<void> changeDate(DateTime date) => loadForDate(date);

  /// Alterna a presença de um estudante individualmente
  void toggleStudent(String studentId) {
    final current = _attendanceMap[studentId] ?? true;
    _attendanceMap[studentId] = !current;
    _isSaved = false;
    notifyListeners();
  }

  /// Alterna o status de presença (alias para toggleStudent)
  void toggleStatus(String studentId) => toggleStudent(studentId);

  /// Define o status de presença de um estudante
  void setStudentPresence(String studentId, bool isPresent) {
    if (_attendanceMap[studentId] == isPresent) return;
    _attendanceMap[studentId] = isPresent;
    _isSaved = false;
    notifyListeners();
  }

  /// Marca todos como presentes ou todos como ausentes
  void markAll(bool isPresent) {
    for (final s in _students) {
      _attendanceMap[s.id] = isPresent;
    }
    _isSaved = false;
    notifyListeners();
  }

  /// Define a justificativa ou observação de um estudante
  void setStudentObservation(String studentId, String? observation) {
    _observationMap[studentId] = observation?.trim().isEmpty == true ? null : observation?.trim();
    _isSaved = false;
    notifyListeners();
  }

  /// Atualiza o tópico da aula
  void updateTopic(String? topic) {
    _topic = topic;
    _isSaved = false;
    notifyListeners();
  }

  /// Atualiza o termo de busca de estudantes
  void updateSearchFilter(String filter) {
    _searchFilter = filter;
    notifyListeners();
  }

  /// Limpa o filtro de busca
  void clearSearch() {
    _searchFilter = '';
    notifyListeners();
  }

  /// Salva a chamada no repositório
  Future<void> saveAttendance() async {
    final records = _students.map((student) {
      return AttendanceRecord(
        studentId: student.id,
        studentName: student.name,
        isPresent: _attendanceMap[student.id] ?? true,
        observation: _observationMap[student.id],
      );
    }).toList();

    final session = AttendanceSession(
      id: AttendanceSession.generateId(academicClass.id, _selectedDate),
      classId: academicClass.id,
      date: _selectedDate,
      records: records,
      updatedAt: DateTime.now(),
      topic: _topic,
    );

    await _repository.saveSession(session);

    _isSaved = true;
    _isExistingSession = true;
    await loadHistory();
    notifyListeners();
  }

  /// Carrega o histórico de chamadas da turma
  Future<void> loadHistory() async {
    _history = await _repository.getSessionsForClass(academicClass.id);
    notifyListeners();
  }
}
