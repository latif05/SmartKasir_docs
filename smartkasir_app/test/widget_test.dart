import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartkasir_app/main.dart';
import 'package:smartkasir_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login screen renders', (tester) async {
    await AuthService.ensureInitialized();
    await tester.pumpWidget(const SmartKasirApp());
    await tester.pump();

    expect(find.text('SmartKasir'), findsWidgets);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
