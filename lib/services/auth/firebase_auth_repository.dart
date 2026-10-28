import 'package:firebase_auth/firebase_auth.dart';

import '../../models/auth/auth_user.dart';
import 'auth_repository.dart';

/// Autenticação real via Firebase Authentication (e-mail e senha).
///
/// As senhas são enviadas diretamente ao Firebase e nunca armazenadas no
/// dispositivo. A sessão é persistida pelo próprio SDK, que a restaura ao
/// reabrir o app.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> userChanges() => _auth.userChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toAuthUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name.trim());
      await user.reload();
      return _toAuthUser(_auth.currentUser ?? user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  static AuthFailure _mapException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return const AuthFailure(
          AuthFailureCode.invalidCredentials,
          'E-mail ou senha incorretos.',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          AuthFailureCode.emailAlreadyInUse,
          'Já existe uma conta com este e-mail.',
        );
      case 'invalid-email':
        return const AuthFailure(
          AuthFailureCode.invalidEmail,
          'O e-mail informado é inválido.',
        );
      case 'weak-password':
        return const AuthFailure(
          AuthFailureCode.weakPassword,
          'A senha é muito fraca. Use ao menos 8 caracteres com letras e números.',
        );
      case 'user-disabled':
        return const AuthFailure(
          AuthFailureCode.userDisabled,
          'Esta conta foi desativada. Procure o administrador.',
        );
      case 'too-many-requests':
        return const AuthFailure(
          AuthFailureCode.tooManyRequests,
          'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
        );
      case 'network-request-failed':
        return const AuthFailure(
          AuthFailureCode.network,
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          AuthFailureCode.operationNotAllowed,
          'Login por e-mail e senha não está habilitado no Firebase.',
        );
      // Authentication ainda não foi ativado no console do projeto Firebase.
      case 'configuration-not-found':
        return const AuthFailure(
          AuthFailureCode.operationNotAllowed,
          'O Firebase Authentication não está configurado neste projeto.',
        );
      default:
        return const AuthFailure(
          AuthFailureCode.unknown,
          'Não foi possível concluir a operação. Tente novamente.',
        );
    }
  }
}
