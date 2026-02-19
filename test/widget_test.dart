import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(SecureVaultApp, isNotNull);
  });
}
