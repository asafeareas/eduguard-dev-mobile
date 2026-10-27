import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';
import '../../models/grades/assessment.dart';
import '../../models/grades/grade_record.dart';
import '../../services/grades_repository.dart';
import '../academic/students_view_model.dart';

enum GradesStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

/// ViewModel responsável pelo lançamento, validação, edição e consulta de notas de uma turma.
class GradesViewModel extends ChangeNotifier {
  GradesViewModel({
    required this.academicClass,
    List<Student>? students,
    GradesRepository? repository,
  })  : _students = students ?? SampleStudents.forClass(academicClass.id),
        _repository = repository ?? GradesRepository.instance {
    loadAssessments();
  }

  final AcademicClass academicClass;
  final List<Student> _students;
  final GradesRepository _repository;

  GradesStatus _status = GradesStatus.initial;
  String? _errorMessage;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _isDisposed = false;
  String _searchFilter = '';
  List<Assessment> _assessments = [];
  String? _selectedAssessmentId;
  int _inputsVersion = 0;

  /// Texto digitado por estudante na avaliação selecionada
  final Map<String, String> _inputs = {};

  /// Mensagens de validação por estudante na avaliação selecionada
  final Map<String, String> _errors = {};

  /// Notas salvas da turma: assessmentId -> (studentId -> nota)
  final Map<String, Map<String, double>> _savedGrades = {};

  // Getters
  GradesStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  String get searchFilter => _searchFilter;
  List<Assessment> get assessments => List.unmodifiable(_assessments);

  /// Incrementado sempre que as notas digitadas são recarregadas do repositório,
  /// permitindo que a interface recrie os campos de entrada.
  int get inputsVersion => _inputsVersion;

  Assessment? get selectedAssessment {
    for (final a in _assessments) {
      if (a.id == _selectedAssessmentId) return a;
    }
    return null;
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

  String scoreInput(String studentId) => _inputs[studentId] ?? '';

  String? scoreError(String studentId) => _errors[studentId];

  bool get hasErrors => _errors.isNotEmpty;

  int get errorCount => _errors.length;

  /// Notas válidas digitadas na avaliação selecionada
  Map<String, double> get _validScores {
    final result = <String, double>{};
    for (final s in _students) {
      if (_errors.containsKey(s.id)) continue;
      final score = parseScore(_inputs[s.id] ?? '');
      if (score != null) result[s.id] = score;
    }
    return result;
  }

  int get launchedCount => _validScores.length;

  int get pendingCount => totalStudentsCount - launchedCount - errorCount;

  /// Média da turma na avaliação selecionada (considerando as notas digitadas)
  double? get currentAverage {
    final scores = _validScores.values;
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Indica se a avaliação selecionada já possui notas salvas
  bool get isExistingLaunch =>
      _savedGrades[_selectedAssessmentId]?.isNotEmpty ?? false;

  bool get canSave =>
      selectedAssessment != null && !_isSaving && !hasErrors && _hasUnsavedChanges;

  /// Converte o texto digitado em nota, aceitando vírgula ou ponto decimal.
  static double? parseScore(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  /// Valida o texto digitado conforme a escala da avaliação selecionada.
  /// Retorna `null` quando válido (campo vazio significa nota não lançada).
  String? validateScoreInput(String input) {
    final assessment = selectedAssessment;
    if (assessment == null) return 'Selecione uma avaliação';

    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final score = parseScore(trimmed);
    if (score == null || !score.isFinite) return 'Nota inválida';
    if (score < Assessment.minScore) return 'Nota não pode ser negativa';
    if (score > assessment.maxScore) {
      return 'Máximo ${Assessment.formatScore(assessment.maxScore)}';
    }

    final decimals = trimmed.replaceAll(',', '.').split('.');
    if (decimals.length > 1 &&
        decimals.last.length > Assessment.maxDecimalPlaces) {
      return 'Use até ${Assessment.maxDecimalPlaces} casas decimais';
    }
    return null;
  }

  /// Atualiza a nota digitada para um estudante, validando-a imediatamente
  void setScoreInput(String studentId, String input) {
    _inputs[studentId] = input;
    final error = validateScoreInput(input);
    if (error == null) {
      _errors.remove(studentId);
    } else {
      _errors[studentId] = error;
    }
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Descarta as alterações não salvas, restaurando as notas registradas
  void discardChanges() {
    _fillInputsFromSaved();
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

  /// Carrega as avaliações e notas registradas da turma
  Future<void> loadAssessments() async {
    _status = GradesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _assessments = List.of(
        await _repository.getAssessmentsForClass(academicClass.id),
      );
      await _loadSavedGrades();
    } catch (_) {
      _status = GradesStatus.error;
      _errorMessage =
          'Não foi possível carregar as avaliações da turma. Tente novamente.';
      notifyListeners();
      return;
    }

    if (_assessments.isEmpty) {
      _selectedAssessmentId = null;
      _status = GradesStatus.empty;
    } else {
      if (selectedAssessment == null) {
        _selectedAssessmentId = _assessments.first.id;
      }
      _fillInputsFromSaved();
      _status = GradesStatus.success;
    }
    notifyListeners();
  }

  /// Seleciona a avaliação para lançamento, carregando as notas já registradas
  void selectAssessment(String assessmentId) {
    if (!_assessments.any((a) => a.id == assessmentId)) return;
    _selectedAssessmentId = assessmentId;
    _fillInputsFromSaved();
    notifyListeners();
  }

  /// Cadastra uma nova avaliação na turma e a seleciona para lançamento
  Future<bool> createAssessment({
    required String title,
    required AssessmentType type,
    required double maxScore,
    required double weight,
    required DateTime date,
  }) async {
    final assessment = Assessment(
      id: Assessment.generateId(academicClass.id),
      classId: academicClass.id,
      title: title.trim(),
      type: type,
      maxScore: maxScore,
      weight: weight,
      date: DateTime(date.year, date.month, date.day),
    );

    try {
      await _repository.saveAssessment(assessment);
    } catch (_) {
      return false;
    }

    _selectedAssessmentId = assessment.id;
    await loadAssessments();
    return true;
  }

  /// Salva as notas da avaliação selecionada.
  /// Retorna `false` se houver notas inválidas ou falha na persistência.
  Future<bool> saveGrades() async {
    final assessment = selectedAssessment;
    if (assessment == null || hasErrors || _isSaving) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final scores = _validScores;
    final now = DateTime.now();
    final records = _students
        .where((s) => scores.containsKey(s.id))
        .map(
          (s) => GradeRecord(
            studentId: s.id,
            studentName: s.name,
            classId: academicClass.id,
            assessmentId: assessment.id,
            score: scores[s.id]!,
            updatedAt: now,
          ),
        )
        .toList();

    try {
      await _repository.saveGrades(assessment.id, records);
      await _loadSavedGrades();
      _fillInputsFromSaved();
      return true;
    } catch (_) {
      _errorMessage = 'Falha ao salvar as notas. Suas alterações foram mantidas.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Consulta de resultados

  /// Nota salva de um estudante em uma avaliação
  double? savedScore(String assessmentId, String studentId) =>
      _savedGrades[assessmentId]?[studentId];

  /// Quantidade de notas salvas em uma avaliação
  int savedCount(String assessmentId) => _savedGrades[assessmentId]?.length ?? 0;

  /// Média salva da turma em uma avaliação
  double? savedAverage(String assessmentId) {
    final scores = _savedGrades[assessmentId]?.values;
    if (scores == null || scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Média ponderada do estudante, normalizada para a escala 0 a 10,
  /// considerando apenas as avaliações com nota lançada.
  double? weightedAverage(String studentId) {
    var weightedSum = 0.0;
    var totalWeight = 0.0;
    for (final a in _assessments) {
      final score = savedScore(a.id, studentId);
      if (score == null) continue;
      weightedSum += (score / a.maxScore) * 10 * a.weight;
      totalWeight += a.weight;
    }
    if (totalWeight == 0) return null;
    return weightedSum / totalWeight;
  }

  Future<void> _loadSavedGrades() async {
    final grades = await _repository.getGradesForClass(academicClass.id);
    _savedGrades.clear();
    for (final g in grades) {
      _savedGrades.putIfAbsent(g.assessmentId, () => {})[g.studentId] =
          g.score;
    }
  }

  void _fillInputsFromSaved() {
    _inputs.clear();
    _errors.clear();
    _hasUnsavedChanges = false;
    _inputsVersion++;
    final saved = _savedGrades[_selectedAssessmentId] ?? const {};
    for (final s in _students) {
      final score = saved[s.id];
      _inputs[s.id] = score == null ? '' : Assessment.formatScore(score);
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
