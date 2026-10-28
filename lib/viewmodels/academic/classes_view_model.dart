import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';
import '../../services/classes_repository.dart';

enum ClassesStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class ClassesViewModel extends ChangeNotifier {
  /// Com [repository], as turmas são carregadas e persistidas no repositório
  /// do professor autenticado; sem ele, a lista vive apenas em memória.
  ClassesViewModel({
    List<AcademicClass>? initialClasses,
    ClassesRepository? repository,
  }) : _repository = repository,
       _classes = initialClasses != null
            ? List.of(initialClasses)
            : (repository != null ? [] : List.of(AcademicClass.sampleClasses)) {
    if (repository != null && initialClasses == null) {
      _status = ClassesStatus.loading;
      _loadFromRepository();
    } else if (_classes.isEmpty) {
      _status = ClassesStatus.empty;
    } else {
      _status = ClassesStatus.success;
    }
  }

  final ClassesRepository? _repository;
  List<AcademicClass> _classes;
  bool _isDisposed = false;
  ClassesStatus _status = ClassesStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  ClassesStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Retorna as turmas filtradas pela busca atual
  List<AcademicClass> get filteredClasses {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_classes);
    }
    final query = _searchQuery.toLowerCase().trim();
    return _classes.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.course.toLowerCase().contains(query) ||
          c.code.toLowerCase().contains(query);
    }).toList();
  }

  int get totalClassesCount => _classes.length;

  int get totalStudentsCount =>
      _classes.fold<int>(0, (sum, c) => sum + c.studentsCount);

  /// Atualiza o filtro de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Limpa a busca
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Recarrega as turmas (suporta simulação assíncrona)
  Future<void> loadClasses({
    bool forceError = false,
    bool forceEmpty = false,
  }) async {
    _status = ClassesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simula uma requisição de rede rápida
    await Future.delayed(const Duration(milliseconds: 350));

    if (forceError) {
      _status = ClassesStatus.error;
      _errorMessage =
          'Falha na sincronização com o servidor acadêmico. Verifique sua conexão e tente novamente.';
      notifyListeners();
      return;
    }

    if (forceEmpty) {
      _classes = [];
      _status = ClassesStatus.empty;
      notifyListeners();
      return;
    }

    if (_repository != null) {
      await _loadFromRepository();
      return;
    }

    if (_classes.isEmpty) {
      _classes = List.of(AcademicClass.sampleClasses);
    }

    _status = _classes.isEmpty ? ClassesStatus.empty : ClassesStatus.success;
    notifyListeners();
  }

  Future<void> _loadFromRepository() async {
    try {
      _classes = List.of(await _repository!.getClasses());
      _status = _classes.isEmpty ? ClassesStatus.empty : ClassesStatus.success;
      _errorMessage = null;
    } catch (_) {
      _status = ClassesStatus.error;
      _errorMessage =
          'Não foi possível carregar suas turmas salvas neste dispositivo.';
    }
    _notify();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> _persist() async {
    await _repository?.saveClasses(_classes);
  }

  /// Força o estado de erro para demonstração/testes
  void simulateError([String? message]) {
    _status = ClassesStatus.error;
    _errorMessage = message ??
        'Erro ao carregar a lista de turmas. Não foi possível conectar ao sistema institucional.';
    notifyListeners();
  }

  /// Força o estado vazio para demonstração/testes.
  /// Não altera as turmas persistidas; "Restaurar Turmas" as recarrega.
  void simulateEmpty() {
    _classes = [];
    _status = ClassesStatus.empty;
    notifyListeners();
  }

  /// Restaura as turmas: recarrega as turmas salvas do professor ou, se não
  /// houver nenhuma, cria as turmas de exemplo.
  Future<void> restoreSamples() async {
    _errorMessage = null;
    _searchQuery = '';
    final repository = _repository;
    if (repository != null) {
      final saved = await repository.getClasses();
      _classes = saved.isNotEmpty
          ? List.of(saved)
          : List.of(AcademicClass.sampleClasses);
      if (saved.isEmpty) await _persist();
    } else {
      _classes = List.of(AcademicClass.sampleClasses);
    }
    _status = ClassesStatus.success;
    _notify();
  }

  /// Adiciona uma nova turma
  void addClass(AcademicClass newClass) {
    _classes.insert(0, newClass);
    _status = ClassesStatus.success;
    notifyListeners();
    _persist();
  }

  /// Remove uma turma pelo ID
  void removeClass(String id) {
    _classes.removeWhere((c) => c.id == id);
    if (_classes.isEmpty) {
      _status = ClassesStatus.empty;
    }
    notifyListeners();
    _persist();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
