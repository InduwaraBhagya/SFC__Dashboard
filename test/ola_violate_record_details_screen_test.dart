import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfc_dashboard/ServiceOrder/screens/OLAViolateRecordDetailsScreen.dart';
import 'package:sfc_dashboard/ServiceOrder/model/OLAViolateRecord.dart';

void main() {
  // Ensure Flutter bindings are active for test runs
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create a structured mock record to feed into the details screen
  final mockRecord = OLAViolateRecord(
    id: 101,
    peNumber: 'PE-2026-999',
    customer: 'SLT Enterprise Hub Kandy',
    cusType: 'Corporate',
    accountManager: 'Mr. Binuwara Silva',
    serviceCategory: 'FTTH-PRO',
    serviceType: 'Internet & Voice',
    orderType: 'New Installation',
    soId: 'SO-TEST-12345',
    soCreateDate: '2026-05-18 10:00:00',
    woId: 'WO-TEST-54321',
    woStatus: 'In-Progress',
    region: 'Central',
    province: 'Central Province',
    rtom: 'RTOM-KANDY',
    locationAAddress: '12 Colombo Rd, Kandy, Sri Lanka',
    plannedEvent: PlannedEvent(
      serviceRequiredDate: '2026-05-20',
      pendingTaskName: 'Fiber Jointing',
      pendingWg: 'OPMC-KANDY',
      woComments: 'Urgent priority customer line',
    ),
    peTask: PETask(
      task: 'Splice Fiber at LEA Joint',
      estimatedTime: '2 hours',
      taskStatus: 'Pending',
    ),
  );

  group('Table 5.2-2 : test case 01 - OLA Record Details Render Test (TC_SOMS_01)', () {
    
    // --- STEP 01: OPEN REGISTRATION PAGE / LOAD DETAILS ---
    testWidgets('Step 01 - Open OLA Violate Details Page (TC_SOMS_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OLAViolateRecordDetailsScreen(record: mockRecord),
        ),
      );

      // Verify page is loaded successfully without layout crashes
      expect(find.byType(OLAViolateRecordDetailsScreen), findsOneWidget);
    });

    // --- STEP 02: INSPECT SOMS SYSTEM HEADERS ---
    testWidgets('Step 02 - Inspect SOMS system headers (TC_SOMS_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OLAViolateRecordDetailsScreen(record: mockRecord),
        ),
      );

      // Verify system header title exists and correct banners display
      expect(find.text('SERVICE ORDER MANAGEMENT SYSTEM'), findsOneWidget);
      expect(find.text('SO ID'), findsOneWidget);
      expect(find.text('Search SO ID'), findsOneWidget);
    });

    // --- STEP 03: VERIFY SERVICE METADATA CELLS ---
    testWidgets('Step 03 - Verify service metadata cells (TC_SOMS_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OLAViolateRecordDetailsScreen(record: mockRecord),
        ),
      );

      // Verify that specific parameters display correct bound values
      expect(find.text('SO_ID'), findsOneWidget);
      expect(find.text('SO-TEST-12345'), findsOneWidget);

      expect(find.text('SERVICE_CATEGORY'), findsOneWidget);
      expect(find.text('FTTH-PRO'), findsOneWidget);

      expect(find.text('SO_CREATE_DATE'), findsOneWidget);
      expect(find.text('2026-05-18 10:00:00'), findsOneWidget);
    });

    // --- STEP 04: VERIFY CUSTOMER DETAILS MATRIX ---
    testWidgets('Step 04 - Verify customer details matrix (TC_SOMS_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OLAViolateRecordDetailsScreen(record: mockRecord),
        ),
      );

      // Verify that the customer card displays corporate profile name
      expect(find.text('CUSTOMER'), findsOneWidget);
      expect(find.text('SLT Enterprise Hub Kandy'), findsOneWidget);

      expect(find.text('ACCOUNT_MANAGER'), findsOneWidget);
      expect(find.text('Mr. Binuwara Silva'), findsOneWidget);
    });

    // --- STEP 05: VERIFY TASKS LIST DATA TABLE ---
    testWidgets('Step 05 - Verify tasks list data table (TC_SOMS_01)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OLAViolateRecordDetailsScreen(record: mockRecord),
        ),
      );

      // Verify primary columns inside the dynamic DataTable part
      expect(find.text('TASK'), findsOneWidget);
      expect(find.text('WORKGROUP'), findsOneWidget);
      expect(find.text('OLA'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('TIME SPENT'), findsOneWidget);
    });
  });
}
