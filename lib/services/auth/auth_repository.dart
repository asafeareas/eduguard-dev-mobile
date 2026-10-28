import '../../models/auth/auth_user.dart';

/// Contrato de autenticação usado pelos ViewModels.
///
/// A implementação de produção é [FirebaseAuthRepository]; testes usam
/// implementações falsas sem depender de rede.
abstract interface class AuthRepository {
  /// Emite o professor autenticado (ou `null`) sempre que a sessão ou o
  /// perfil mudam, incluindo a restauração da sessão ao reabrir o app.
  Stream<AuthUser?> userChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  });

  /// Encerra apenas a sessão; os dados acadêmicos do professor são mantidos.
  Future<void> signOut();
}

/// Falhas de autenticação já traduzidas para mensagens exibíveis ao usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  final AuthFailureCode code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}

enum AuthFailureCode {
  invalidCredentials,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  operationNotAllowed,
  unknown,
}
