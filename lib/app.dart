import 'package:flutter/material.dart';

import 'services/academic_data_scope.dart';
import 'services/auth/auth_repository.dart';
import 'services/auth/firebase_auth_repository.dart';
import 'services/storage/key_value_store.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth/auth_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/profile/profile_view.dart';
import 'widgets/icon_tile.dart';

class EduGuardApp extends StatefulWidget {
  const EduGuardApp({
    super.key,
    this.authRepository,
    this.store,
    this.populateSamples = true,
  });

  /// Padrão: [FirebaseAuthRepository]. Testes injetam implementações falsas.
  final AuthRepository? authRepository;

  /// Padrão: [SharedPreferencesStore].
  final KeyValueStore? store;

  /// Se verdadeiro, professores novos recebem turmas de exemplo próprias.
  final bool populateSamples;

  @override
  State<EduGuardApp> createState() => _EduGuardAppState();
}

class _EduGuardAppState extends State<EduGuardApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthViewModel _auth = AuthViewModel(
    authRepository: widget.authRepository ?? FirebaseAuthRepository(),
    store: widget.store ?? SharedPreferencesStore(),
    populateSamples: widget.populateSamples,
  );

  HomeViewModel? _homeViewModel;
  String? _sessionOwner;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    super.dispose();
  }

  /// Ao entrar, sair ou trocar de professor, descarta as telas abertas
  /// para que nenhuma rota mantenha dados da sessão anterior.
  void _onAuthChanged() {
    final owner = _auth.user?.uid;
    if (owner == _sessionOwner) {
      final teacher = _auth.teacher;
      if (teacher != null) _homeViewModel?.updateTeacher(teacher);
      return;
    }
    _sessionOwner = owner;
    _homeViewModel = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  HomeViewModel _homeViewModelFor(AcademicDataScope scope) {
    final current = _homeViewModel;
    if (current != null && current.teacher.id == scope.ownerId) {
      return current;
    }
    // A HomeView anterior descarta o ViewModel antigo ao ser desmontada.
    return _homeViewModel = HomeViewModel(
      teacher: _auth.teacher!,
      classesRepository: scope.classes,
    );
  }

  void _openProfile() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileView(authViewModel: _auth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        final scope = _auth.dataScope;

        return MaterialApp(
          title: 'EduGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          navigatorKey: _navigatorKey,
          // O escopo fica acima do Navigator para alcançar todas as rotas.
          builder: (context, child) => scope == null
              ? child!
              : AcademicScope(scope: scope, child: child!),
          home: switch (_auth.status) {
            AuthStatus.unknown => const _SplashView(),
            AuthStatus.unauthenticated => LoginView(
              authRepository: _auth.authRepository,
            ),
            AuthStatus.authenticated => HomeView(
              key: ValueKey(scope!.ownerId),
              viewModel: _homeViewModelFor(scope),
              onProfileTap: _openProfile,
            ),
          },
        );
      },
    );
  }
}

/// Exibida enquanto o Firebase restaura a sessão salva.
class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTile(icon: Icons.shield_outlined, size: 64, filled: true),
            SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                strokeCap: StrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
