import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/auth/auth_validators.dart';
import '../../viewmodels/auth/register_view_model.dart';
import '../../widgets/inline_message.dart';
import '../../widgets/password_field.dart';
import 'auth_layout.dart';

/// Tela de cadastro de professor.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.viewModel.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    // Em caso de sucesso, o AuthViewModel abre o dashboard do novo professor.
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final isSubmitting = vm.isSubmitting;

        return AuthLayout(
          showBack: true,
          title: 'Criar conta',
          subtitle:
              'Cadastre-se para gerenciar suas turmas, frequências e notas.',
          form: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (vm.errorMessage != null) ...[
                    InlineMessage(message: vm.errorMessage!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  TextFormField(
                    controller: _nameController,
                    enabled: !isSubmitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    onChanged: (_) => vm.clearError(),
                    validator: AuthValidators.name,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _emailController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => vm.clearError(),
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
                    autofillHints: const [AutofillHints.newPassword],
                    helperText:
                        'Mínimo de ${AuthValidators.minPasswordLength} caracteres, com letras e números.',
                    onChanged: (_) => vm.clearError(),
                    validator: AuthValidators.newPassword,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PasswordField(
                    controller: _confirmController,
                    label: 'Confirmar senha',
                    enabled: !isSubmitting,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) => AuthValidators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                    ),
                    child: SubmitButtonChild(
                      label: 'Criar conta',
                      isLoading: isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
          footer: AuthFooterLink(
            question: 'Já tem uma conta?',
            actionLabel: 'Entrar',
            onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}
