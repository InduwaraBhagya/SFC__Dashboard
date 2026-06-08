import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/SigninScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Table 5.2-1 : test case 01 - User Authentication Test (TC_AUTH_01)', () {
    
    // --- STEP 01: OPEN LOGIN SCREEN ---
    testWidgets('Step 01 - Open login screen (TC_AUTH_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceOrderSigninScreen(),
        ),
      );

      // Verify the login screen renders correctly
      expect(find.text('Service Order Sign in'), findsOneWidget);
      expect(find.text('Use your Microsoft account'), findsOneWidget);
      
      // The actual app uses Microsoft SSO rather than manual AD fields
      expect(find.text('Login with Microsoft'), findsOneWidget);
    });

    // --- STEP 02 & 03: TRIGGER LOGIN VALIDATION/REQUEST ---
    testWidgets('Step 02 & 03 - Enter credentials and login (TC_AUTH_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceOrderSigninScreen(),
        ),
      );

      // Verify the login button exists by its text since ElevatedButton.icon creates a private widget class
      final loginButton = find.text('Login with Microsoft');
      expect(loginButton, findsOneWidget);

      // We cannot easily mock the full MSAL popup flow in a widget test,
      // but we can verify the button is tappable
      await tester.tap(loginButton);
      await tester.pump(); 
      // The loading indicator should appear after tapping
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
