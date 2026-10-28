import 'package:flutter_test/flutter_test.dart';

import 'support/fake_auth_repository.dart';

void main() {
  testWidgets('exibe a identidade do EduGuard na tela inicial', (tester) async {
    await tester.pumpWidget(buildSignedInApp());
    await tester.pumpAndSettle();

    expect(find.text('EduGuard'), findsWidgets);
    expect(find.text('Gestão acadêmica para docentes'), findsOneWidget);
    expect(find.text('Versão 1.0.0'), findsOneWidget);
  });
}
