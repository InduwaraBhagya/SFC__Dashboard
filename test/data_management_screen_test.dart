import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/DataManagementScreen.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/ManageEntitiesScreen.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('app.loup.flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  group('Table 5.2-5 : test case 05 - Schema Meta-Reflection Test (TC_DATA_01)', () {
    
    
    final mockUser = {'UserId': 1, 'Name': 'Admin User'};

    testWidgets('Step 01 - Load entity schema list via Data Management Panel (TC_DATA_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DataManagementScreen(user: mockUser, onBack: () {}),
        ),
      );

      expect(find.text('Data Management System'), findsWidgets);
      expect(find.text('Manage Entities'), findsOneWidget);
      expect(find.text('Search Data'), findsOneWidget);
      expect(find.text('Manage Relationships'), findsOneWidget);

   
      await tester.pumpWidget(
        MaterialApp(
          home: ManageEntitiesScreen(user: mockUser),
        ),
      );

    
      expect(find.text('CUSTOM ENTITIES + DATABASE TABLES'), findsOneWidget);
      expect(find.text('Entities'), findsOneWidget);
     
      expect(find.byType(Scaffold), findsWidgets);
    });

  });
}
