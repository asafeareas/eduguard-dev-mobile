import 'package:flutter/foundation.dart';

import '../../services/auth/auth_repository.dart';

/// ViewModel da tela de login.
///
/// O redirecionamento ao dashboard acontece automaticamente quando o
/// [AuthRepository] emite o professor autenticado.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isDisposed = false;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Retorna `true` se o login foi concluído.
  Future<bool> signIn({required String email, required String password}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _notify();

    try {
      await _authRepository.signIn(email: email, password: password);
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
