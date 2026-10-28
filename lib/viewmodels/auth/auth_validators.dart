/// Regras de validação dos formulários de autenticação.
abstract final class AuthValidators {
  static const int minPasswordLength = 8;
  static const int minNameLength = 3;

  static final RegExp _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome completo';
    if (v.length < minNameLength) return 'Nome muito curto';
    if (v.split(RegExp(r'\s+')).length < 2) {
      return 'Informe nome e sobrenome';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    if (!_emailPattern.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  /// Senha do login: apenas obrigatória (as regras valem para o cadastro).
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha';
    return null;
  }

  /// Senha do cadastro: ao menos 8 caracteres, com letras e números.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Crie uma senha';
    if (v.length < minPasswordLength) {
      return 'Use ao menos $minPasswordLength caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Combine letras e números';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirme sua senha';
    if (value != password) return 'As senhas não coincidem';
    return null;
  }
}
