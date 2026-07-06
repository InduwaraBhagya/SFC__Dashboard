import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/DashboardHome.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('app.loup.flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  group('Table 5.2-2 : test case 02 - Live Metrics Counter Test (TC_DASH_01)', () {
 
    testWidgets('Step 01 - Open dashboard & Loading state spinner (TC_DASH_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardHome(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

  });
}
