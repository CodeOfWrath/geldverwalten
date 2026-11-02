import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geldverwalten/core/di/injection_container.dart';
import 'package:geldverwalten/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.init();
  });

  testWidgets('Depensia splash & onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DepensiaApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Splash Screen renders 'Dépensia'
    expect(find.text('Dépensia'), findsOneWidget);

    // Fast-forward animation & navigation timer
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify Onboarding Page buttons 'Commencer' and 'Se connecter'
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
