import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/AddNoticeScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Table 5.2-4 : test case 04 - Notice Announcement Test (TC_NOTI_01)', () {
    

    testWidgets('Step 01 - Open Add Notice screen (TC_NOTI_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddNoticeScreen(),
        ),
      );

    
      expect(find.text('Create New Notice'), findsOneWidget);
      expect(find.text('Notice Title *'), findsOneWidget);
      expect(find.text('Notice Message *'), findsOneWidget);
    });

   
    testWidgets('Step 02 - Submit empty form fields and fire validators (TC_NOTI_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddNoticeScreen(),
        ),
      );

      final createButton = find.text('Create Notice');
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pump(); 

    
      expect(find.text('Field required'), findsWidgets); 
    });

    
    testWidgets('Step 03 - Enter values & submit form (TC_NOTI_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddNoticeScreen(),
        ),
      );

      final titleField = find.byWidgetPredicate((widget) => widget is TextFormField).first;
      await tester.enterText(titleField, 'Fiber Cut Alert');
     
    
      final createButton = find.text('Create Notice');
      await tester.tap(createButton);
      await tester.pump();
    
      expect(find.text('Field required'), findsOneWidget); 
    });
  });
}
