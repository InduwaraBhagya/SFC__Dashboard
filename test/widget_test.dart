
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sfc_dashboard/PlannedEvent/PlannedEventMain.dart';

void main() {
  testWidgets('PlannedEventMain loads successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlannedEventMain(
          userId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets);
  });
}

