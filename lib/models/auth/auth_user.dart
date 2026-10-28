/// Professor autenticado, independente do provedor de autenticação.
///
/// Contém apenas os dados mínimos necessários para identificar a sessão;
/// senhas e tokens nunca passam por este modelo.
class AuthUser {
  const AuthUser({required this.uid, required this.email, this.displayName});

  /// Identificador único e imutável do professor (UID do Firebase).
  final String uid;
  final String email;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(uid, email, displayName);
}
