import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/auth/auth_user.dart';
import '../../models/teacher/teacher_profile.dart';
import '../../services/academic_data_scope.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/storage/key_value_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado global da sessão do professor.
///
/// Observa o [AuthRepository] (que restaura a sessão ao reabrir o app) e
/// cria um [AcademicDataScope] isolado para cada professor autenticado.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required this._authRepository,
    required this._store,
    this.populateSamples = true,
  }) {
    _subscription = _authRepository.userChanges().listen(_onUserChanged);
  }

  final AuthRepository _authRepository;
  final KeyValueStore _store;

  /// Se verdadeiro, professores novos recebem turmas de exemplo próprias.
  final bool populateSamples;

  late final StreamSubscription<AuthUser?> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  AcademicDataScope? _dataScope;
  bool _isSigningOut = false;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  bool get isSigningOut => _isSigningOut;

  AuthRepository get authRepository => _authRepository;

  /// Dados acadêmicos do professor autenticado (nulo sem sessão).
  AcademicDataScope? get dataScope => _dataScope;

  TeacherProfile? get teacher =>
      _user == null ? null : TeacherProfile.fromAuthUser(_user!);

  void _onUserChanged(AuthUser? user) {
    if (user?.uid != _dataScope?.ownerId) {
      // Troca de professor: descarta o escopo anterior da memória.
      _dataScope = user == null
          ? null
          : AcademicDataScope(
              ownerId: user.uid,
              store: _store,
              populateSamples: populateSamples,
            );
    }
    _user = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  /// Encerra a sessão sem apagar os dados acadêmicos persistidos.
  Future<void> signOut() async {
    _isSigningOut = true;
    notifyListeners();
    try {
      await _authRepository.signOut();
    } finally {
      _isSigningOut = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
