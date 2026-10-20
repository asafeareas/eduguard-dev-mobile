import 'package:flutter_test/flutter_test.dart';

import 'package:eduguard/app.dart';

void main() {
  testWidgets('exibe a identidade do EduGuard na tela inicial', (tester) async {
    await tester.pumpWidget(const EduGuardApp());

    expect(find.text('EduGuard'), findsWidgets);
    expect(find.text('Gestão acadêmica para docentes'), findsOneWidget);
    expect(find.text('Versão 1.0.0'), findsOneWidget);
  });
}
