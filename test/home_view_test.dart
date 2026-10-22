import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/app.dart';
import 'package:eduguard/viewmodels/home_view_model.dart';
import 'package:eduguard/views/academic/classes_view.dart';
import 'package:eduguard/views/home/home_view.dart';
import 'package:eduguard/widgets/academic_feature_button.dart';
import 'package:eduguard/widgets/stat_card.dart';

void main() {
  group('HomeView (Tela Inicial do Professor) Tests', () {
    testWidgets('exibe informações do professor e botões das funcionalidades acadêmicas',
        (tester) async {
      final viewModel = HomeViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica cabeçalho do professor
      expect(find.text('Prof. Carlos Eduardo'), findsOneWidget);
      expect(find.text('EduGuard'), findsWidgets);
      expect(find.text('Gestão acadêmica para docentes'), findsOneWidget);

      // Verifica botões de funcionalidades acadêmicas
      expect(find.text('Minhas Turmas'), findsOneWidget);
      expect(find.text('Frequência dos Estudantes'), findsOneWidget);
      expect(find.text('Lançamento de Notas'), findsOneWidget);
      expect(find.text('Grade de Horários'), findsOneWidget);

      // Verifica estatísticas rápidas
      expect(find.byType(StatCard), findsWidgets);
      expect(find.byType(AcademicFeatureButton), findsWidgets);
    });

    testWidgets('navega para a tela de turmas ao clicar no botão "Minhas Turmas"',
        (tester) async {
      await tester.pumpWidget(const EduGuardApp());
      await tester.pumpAndSettle();

      // Clica no botão de funcionalidade "Minhas Turmas"
      final turmasButton = find.widgetWithText(AcademicFeatureButton, 'Minhas Turmas');
      expect(turmasButton, findsOneWidget);
      await tester.tap(turmasButton);
      await tester.pumpAndSettle();

      // Confirma que a ClassesView foi aberta
      expect(find.byType(ClassesView), findsOneWidget);
      expect(find.text('Turmas Cadastradas'), findsOneWidget);
    });

    testWidgets('renderiza sem overflow em múltiplos formatos de tela',
        (tester) async {
      // Tela compacta (320 x 480)
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const EduGuardApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Tela intermediária (412 x 915)
      tester.view.physicalSize = const Size(412, 915);
      await tester.pumpWidget(const EduGuardApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
