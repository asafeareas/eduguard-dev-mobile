import 'package:flutter/material.dart';

import '../../services/auth/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth/auth_validators.dart';
import '../../viewmodels/auth/login_view_model.dart';
import '../../viewmodels/auth/register_view_model.dart';
import '../../widgets/inline_message.dart';
import '../../widgets/password_field.dart';
import 'auth_layout.dart';
import 'register_view.dart';

/// Tela de login do professor (e-mail e senha).
class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel = LoginViewModel(
    authRepository: widget.authRepository,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _viewModel.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    // Em caso de sucesso, o AuthViewModel redireciona ao dashboard.
  }

  void _openRegister() {
    _viewModel.clearError();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterView(
          viewModel: RegisterViewModel(authRepository: widget.authRepository),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isSubmitting = _viewModel.isSubmitting;

        return AuthLayout(
          title: 'Bem-vindo(a) de volta',
          subtitle:
              'Entre com seu e-mail institucional para acessar suas turmas.',
          form: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_viewModel.errorMessage != null) ...[
                    InlineMessage(message: _viewModel.errorMessage!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  TextFormField(
                    controller: _emailController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => _viewModel.clearError(),
                    validator: AuthValidators.email,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PasswordField(
                    controller: _passwordController,
                    label: 'Senha',
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _viewModel.clearError(),
                    onFieldSubmitted: (_) => _submit(),
                    validator: AuthValidators.loginPassword,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                    ),
                    child: SubmitButtonChild(
                      label: 'Entrar',
                      isLoading: isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
          footer: AuthFooterLink(
            question: 'Ainda não tem conta?',
            actionLabel: 'Criar conta',
            onPressed: isSubmitting ? null : _openRegister,
          ),
        );
      },
    );
  }
}
