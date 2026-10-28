import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/app.dart';
import 'package:eduguard/models/academic/academic_class.dart';
import 'package:eduguard/models/attendance/attendance_record.dart';
import 'package:eduguard/models/attendance/attendance_session.dart';
import 'package:eduguard/services/academic_data_scope.dart';
import 'package:eduguard/services/auth/auth_repository.dart';
import 'package:eduguard/services/storage/key_value_store.dart';
import 'package:eduguard/viewmodels/auth/auth_validators.dart';
import 'package:eduguard/views/auth/login_view.dart';
import 'package:eduguard/views/auth/register_view.dart';
import 'package:eduguard/views/home/home_view.dart';
import 'package:eduguard/views/profile/profile_view.dart';

import 'support/fake_auth_repository.dart';

const _newClass = AcademicClass(
  id: 'turma-nova',
  name: 'Banco de Dados I',
  course: 'Sistemas de Informação',
  code: 'SI-210',
  studentsCount: 30,
  semester: '2026/2',
  shift: 'Noturno',
  room: 'Sala 101',
  nextClass: 'Em breve',
);

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('AuthValidators', () {
    test('valida nome completo', () {
      expect(AuthValidators.name(''), isNotNull);
      expect(AuthValidators.name('Ana'), 'Informe nome e sobrenome');
      expect(AuthValidators.name('Ana Souza'), isNull);
    });

    test('valida formato do e-mail', () {
      expect(AuthValidators.email(''), 'Informe seu e-mail');
      expect(AuthValidators.email('ana@'), 'E-mail inválido');
      expect(AuthValidators.email('ana.souza@escola'), 'E-mail inválido');
      expect(AuthValidators.email(' ana.souza@escola.edu.br '), isNull);
    });

    test('exige senha forte no cadastro', () {
      expect(AuthValidators.newPassword(''), 'Crie uma senha');
      expect(AuthValidators.newPassword('abc123'), contains('8 caracteres'));
      expect(AuthValidators.newPassword('abcdefgh'), 'Combine letras e números');
      expect(AuthValidators.newPassword('12345678'), 'Combine letras e números');
      expect(AuthValidators.newPassword('senhaSegura1'), isNull);
    });

    test('confirmação precisa coincidir com a senha', () {
      expect(AuthValidators.confirmPassword('', 'senha123'), isNotNull);
      expect(
        AuthValidators.confirmPassword('senha124', 'senha123'),
        'As senhas não coincidem',
      );
      expect(AuthValidators.confirmPassword('senha123', 'senha123'), isNull);
    });
  });

  group('Isolamento e persistência dos dados acadêmicos', () {
    test('cada professor acessa apenas os próprios dados', () async {
      final store = InMemoryKeyValueStore();
      final teacherA = AcademicDataScope(ownerId: 'uid-a', store: store);
      final teacherB = AcademicDataScope(ownerId: 'uid-b', store: store);

      final classesA = await teacherA.classes.getClasses();
      await teacherA.classes.saveClasses([_newClass, ...classesA]);

      final classesB = await teacherB.classes.getClasses();
      expect(classesB.map((c) => c.id), isNot(contains(_newClass.id)));
      expect(
        (await teacherA.classes.getClasses()).first.id,
        _newClass.id,
      );

      // Todas as chaves ficam sob o namespace do UID do professor.
      expect(
        store.values.keys.every(
          (k) =>
              k.startsWith('eduguard.v1.uid-a.') ||
              k.startsWith('eduguard.v1.uid-b.'),
        ),
        isTrue,
      );
    });

    test('dados sobrevivem a uma nova sessão do mesmo professor', () async {
      final store = InMemoryKeyValueStore();
      // Fora do intervalo das chamadas de exemplo criadas no primeiro acesso.
      final date = DateTime(2025, 3, 10);
      final session = AttendanceSession(
        id: AttendanceSession.generateId('turma-01', date),
        classId: 'turma-01',
        date: date,
        records: const [
          AttendanceRecord(
            studentId: 'aluno-1',
            studentName: 'Ana',
            isPresent: false,
          ),
        ],
        updatedAt: date,
        topic: 'Revisão',
      );

      final firstSession = AcademicDataScope(ownerId: 'uid-a', store: store);
      await firstSession.attendance.saveSession(session);

      // Simula reabrir o app: novo escopo, mesmo armazenamento.
      final reopened = AcademicDataScope(ownerId: 'uid-a', store: store);
      final restored = await reopened.attendance.getSession('turma-01', date);
      expect(restored, isNotNull);
      expect(restored!.topic, 'Revisão');
      expect(restored.records.single.isPresent, isFalse);

      // Outro professor não enxerga a chamada.
      final other = AcademicDataScope(ownerId: 'uid-b', store: store);
      expect(await other.attendance.getSession('turma-01', date), isNull);
    });
  });

  group('Fluxo de autenticação', () {
    late FakeAuthRepository auth;
    late InMemoryKeyValueStore store;

    setUp(() {
      auth = FakeAuthRepository();
      store = InMemoryKeyValueStore();
      auth.addAccount(
        email: 'ana.souza@escola.edu.br',
        password: 'senhaSegura1',
        name: 'Ana Souza',
      );
    });

    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(EduGuardApp(authRepository: auth, store: store));
      await tester.pumpAndSettle();
    }

    Future<void> login(
      WidgetTester tester, {
      String email = 'ana.souza@escola.edu.br',
      String password = 'senhaSegura1',
    }) async {
      await tester.enterText(_field('E-mail'), email);
      await tester.enterText(_field('Senha'), password);
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Entrar'));
    }

    testWidgets('sem sessão, o app abre na tela de login', (tester) async {
      await pumpApp(tester);

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
    });

    testWidgets('valida campos obrigatórios antes de enviar', (tester) async {
      await pumpApp(tester);

      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Entrar'));

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('exibe erro claro para credenciais inválidas', (tester) async {
      await pumpApp(tester);

      await login(tester, password: 'senhaErrada1');

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
    });

    testWidgets('login direciona ao dashboard do professor', (tester) async {
      await pumpApp(tester);

      await login(tester);

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text('Ana Souza'), findsOneWidget);
    });

    testWidgets('cadastro valida o formulário e abre o dashboard', (
      tester,
    ) async {
      await pumpApp(tester);
      await _tapVisible(tester, find.widgetWithText(TextButton, 'Criar conta'));
      expect(find.byType(RegisterView), findsOneWidget);

      await tester.enterText(_field('Nome completo'), 'Bruno Lima');
      await tester.enterText(_field('E-mail'), 'bruno.lima@escola.edu.br');
      await tester.enterText(_field('Senha'), 'senhaSegura1');
      await tester.enterText(_field('Confirmar senha'), 'outraSenha1');
      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, 'Criar conta'),
      );
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      await tester.enterText(_field('Confirmar senha'), 'senhaSegura1');
      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, 'Criar conta'),
      );

      expect(find.byType(RegisterView), findsNothing);
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text('Bruno Lima'), findsOneWidget);
    });

    testWidgets('cadastro informa e-mail já utilizado', (tester) async {
      await pumpApp(tester);
      await _tapVisible(tester, find.widgetWithText(TextButton, 'Criar conta'));

      await tester.enterText(_field('Nome completo'), 'Ana Souza');
      await tester.enterText(_field('E-mail'), 'ana.souza@escola.edu.br');
      await tester.enterText(_field('Senha'), 'senhaSegura1');
      await tester.enterText(_field('Confirmar senha'), 'senhaSegura1');
      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, 'Criar conta'),
      );

      expect(find.text('Já existe uma conta com este e-mail.'), findsOneWidget);
      expect(find.byType(RegisterView), findsOneWidget);
    });

    testWidgets('mantém a sessão ativa ao reabrir o app', (tester) async {
      await tester.pumpWidget(
        EduGuardApp(
          authRepository: FakeAuthRepository(signedInUser: testTeacher),
          store: store,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      expect(find.byType(HomeView), findsOneWidget);
    });

    testWidgets('logout volta ao login sem apagar os dados do professor', (
      tester,
    ) async {
      await pumpApp(tester);
      await login(tester);

      final scope = AcademicScope.of(tester.element(find.byType(HomeView)));
      final classes = await scope.classes.getClasses();
      await scope.classes.saveClasses([_newClass, ...classes]);

      // Abre o perfil e encerra a sessão
      await _tapVisible(tester, find.byTooltip('Perfil do professor'));
      expect(find.byType(ProfileView), findsOneWidget);
      expect(find.text('ana.souza@escola.edu.br'), findsOneWidget);

      await _tapVisible(tester, find.text('Sair da conta'));
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sair'));

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(ProfileView), findsNothing);
      expect(auth.currentUser, isNull);

      // Ao entrar novamente, a turma criada continua disponível.
      await login(tester);
      final restored = await AcademicScope.of(
        tester.element(find.byType(HomeView)),
      ).classes.getClasses();
      expect(restored.first.id, _newClass.id);
    });

    testWidgets('outro professor não vê as turmas do anterior', (
      tester,
    ) async {
      auth.addAccount(
        email: 'bruno.lima@escola.edu.br',
        password: 'senhaSegura1',
        name: 'Bruno Lima',
      );
      await pumpApp(tester);
      await login(tester);

      final scopeA = AcademicScope.of(tester.element(find.byType(HomeView)));
      await scopeA.classes.saveClasses([_newClass]);
      await auth.signOut();
      await tester.pumpAndSettle();

      await login(tester, email: 'bruno.lima@escola.edu.br');
      final scopeB = AcademicScope.of(tester.element(find.byType(HomeView)));

      expect(scopeB.ownerId, isNot(scopeA.ownerId));
      final classesB = await scopeB.classes.getClasses();
      expect(classesB.map((c) => c.id), isNot(contains(_newClass.id)));
      expect(find.text(_newClass.name), findsNothing);
    });

    testWidgets('mostra mensagem de rede ao falhar a conexão', (tester) async {
      await pumpApp(tester);
      auth.nextFailure = const AuthFailure(
        AuthFailureCode.network,
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );

      await login(tester);

      expect(find.textContaining('Sem conexão'), findsOneWidget);
      expect(find.byType(LoginView), findsOneWidget);
    });
  });
}
