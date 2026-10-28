import 'dart:async';

import 'package:eduguard/app.dart';
import 'package:eduguard/models/auth/auth_user.dart';
import 'package:eduguard/services/auth/auth_repository.dart';
import 'package:eduguard/services/storage/key_value_store.dart';

/// Dublê de teste do [AuthRepository]: reproduz o comportamento do Firebase
/// (contas únicas por e-mail, credenciais inválidas, sessão observável)
/// sem rede. Usado apenas em testes.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? signedInUser}) : _current = signedInUser;

  final _changes = StreamController<AuthUser?>.broadcast();
  final Map<String, ({String password, AuthUser user})> _accounts = {};
  AuthUser? _current;
  int _nextUid = 1;

  /// Quando definido, a próxima operação falha com este erro.
  AuthFailure? nextFailure;

  /// Cria uma conta já existente (sem iniciar sessão).
  AuthUser addAccount({
    required String email,
    required String password,
    String? name,
  }) {
    final user = AuthUser(
      uid: 'uid-${_nextUid++}',
      email: email,
      displayName: name,
    );
    _accounts[email.toLowerCase()] = (password: password, user: user);
    return user;
  }

  @override
  Stream<AuthUser?> userChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _throwIfFailureQueued();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure(
        AuthFailureCode.invalidCredentials,
        'E-mail ou senha incorretos.',
      );
    }
    _emit(account.user);
    return account.user;
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _throwIfFailureQueued();
    if (_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthFailure(
        AuthFailureCode.emailAlreadyInUse,
        'Já existe uma conta com este e-mail.',
      );
    }
    final user = addAccount(
      email: email.trim(),
      password: password,
      name: name.trim(),
    );
    _emit(user);
    return user;
  }

  @override
  Future<void> signOut() async => _emit(null);

  void _emit(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }

  void _throwIfFailureQueued() {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
  }
}

const testTeacher = AuthUser(
  uid: 'uid-teste',
  email: 'carlos.eduardo@eduguard.edu.br',
  displayName: 'Prof. Carlos Eduardo',
);

/// App completo com um professor já autenticado e armazenamento em memória.
EduGuardApp buildSignedInApp({
  AuthUser user = testTeacher,
  KeyValueStore? store,
}) {
  return EduGuardApp(
    authRepository: FakeAuthRepository(signedInUser: user),
    store: store ?? InMemoryKeyValueStore(),
  );
}
