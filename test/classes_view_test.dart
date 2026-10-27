import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/theme/app_theme.dart';
import 'package:eduguard/viewmodels/academic/classes_view_model.dart';
import 'package:eduguard/views/academic/classes_view.dart';
import 'package:eduguard/widgets/class_card.dart';
import 'package:eduguard/widgets/empty_state_view.dart';
import 'package:eduguard/widgets/error_state_view.dart';

Widget createTestableWidget({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: child,
  );
}

void main() {
  group('ClassesView & ClassCard Widget Tests', () {
    testWidgets('exibe informações das turmas cadastradas (nome, curso, estudantes)',
        (tester) async {
      final viewModel = ClassesViewModel();

      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica título da tela
      expect(find.text('Turmas Cadastradas'), findsOneWidget);

      // Verifica primeira turma de exemplo
      expect(find.text('Engenharia de Software II'), findsOneWidget);
      expect(find.text('Ciência da Computação'), findsOneWidget);
      expect(find.text('38 alunos'), findsOneWidget);
      expect(find.text('CC-401'), findsOneWidget);

      // Verifica contagem de cards
      expect(find.byType(ClassCard), findsWidgets);
    });

    testWidgets('exibe mensagem amigável quando não houver turmas (Empty State)',
        (tester) async {
      final viewModel = ClassesViewModel(initialClasses: []);

      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('Nenhuma turma cadastrada'), findsOneWidget);
      expect(find.text('Cadastrar primeira turma'), findsOneWidget);
    });

    testWidgets('exibe mensagem e botão de recarga quando ocorrer erro (Error State)',
        (tester) async {
      final viewModel = ClassesViewModel();
      viewModel.simulateError('Falha no servidor institucional.');

      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Falha ao sincronizar turmas'), findsOneWidget);
      expect(find.text('Falha no servidor institucional.'), findsOneWidget);
      expect(find.text('Recarregar turmas'), findsOneWidget);
    });

    testWidgets('filtra as turmas em tempo real ao digitar no campo de busca',
        (tester) async {
      final viewModel = ClassesViewModel();

      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Digita no campo de busca
      await tester.enterText(find.byType(TextField), 'Flutter');
      await tester.pumpAndSettle();

      expect(find.text('Desenvolvimento Mobile com Flutter'), findsOneWidget);
      expect(find.text('Engenharia de Software II'), findsNothing);
    });

    testWidgets('funciona sem overflow em telas estreitas (320px) e grandes (800px)',
        (tester) async {
      final viewModel = ClassesViewModel();

      // Testa tela pequena (iPhone SE antigo / 320 x 568)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClassesView), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Testa tela grande (Tablet / 800 x 1200)
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(
        createTestableWidget(
          child: ClassesView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClassesView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
