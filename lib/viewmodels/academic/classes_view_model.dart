import 'package:flutter/foundation.dart';

import '../../models/academic/academic_class.dart';

enum ClassesStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class ClassesViewModel extends ChangeNotifier {
  ClassesViewModel({
    List<AcademicClass>? initialClasses,
  }) : _classes = initialClasses != null
            ? List.of(initialClasses)
            : List.of(AcademicClass.sampleClasses) {
    if (_classes.isEmpty) {
      _status = ClassesStatus.empty;
    } else {
      _status = ClassesStatus.success;
    }
  }

  List<AcademicClass> _classes;
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

    if (_classes.isEmpty) {
      _classes = List.of(AcademicClass.sampleClasses);
    }

    _status = _classes.isEmpty ? ClassesStatus.empty : ClassesStatus.success;
    notifyListeners();
  }

  /// Força o estado de erro para demonstração/testes
  void simulateError([String? message]) {
    _status = ClassesStatus.error;
    _errorMessage = message ??
        'Erro ao carregar a lista de turmas. Não foi possível conectar ao sistema institucional.';
    notifyListeners();
  }

  /// Força o estado vazio para demonstração/testes
  void simulateEmpty() {
    _classes = [];
    _status = ClassesStatus.empty;
    notifyListeners();
  }

  /// Restaura as turmas de exemplo
  void restoreSamples() {
    _classes = List.of(AcademicClass.sampleClasses);
    _status = ClassesStatus.success;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// Adiciona uma nova turma
  void addClass(AcademicClass newClass) {
    _classes.insert(0, newClass);
    _status = ClassesStatus.success;
    notifyListeners();
  }

  /// Remove uma turma pelo ID
  void removeClass(String id) {
    _classes.removeWhere((c) => c.id == id);
    if (_classes.isEmpty) {
      _status = ClassesStatus.empty;
    }
    notifyListeners();
  }
}
