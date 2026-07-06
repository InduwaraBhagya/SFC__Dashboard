import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/SigninScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Table 5.2-1 : test case 01 - User Authentication Test (TC_AUTH_01)', () {
   
    testWidgets('Step 01 - Open login screen (TC_AUTH_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceOrderSigninScreen(),
        ),
      );

      expect(find.text('Service Order Sign in'), findsOneWidget);
      expect(find.text('Use your Microsoft account'), findsOneWidget);
   
      expect(find.text('Login with Microsoft'), findsOneWidget);
    });

   
    testWidgets('Step 02 & 03 - Enter credentials and login (TC_AUTH_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceOrderSigninScreen(),
        ),
      );

  
      final loginButton = find.text('Login with Microsoft');
      expect(loginButton, findsOneWidget);

     
      await tester.tap(loginButton);
      await tester.pump(); 
     
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
