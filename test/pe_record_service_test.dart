import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sfc_dashboard/PlannedEvent/service/PERecordService.dart';
import 'package:sfc_dashboard/PlannedEvent/model/PERecord.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {

    dotenv.testLoad(fileInput: '''
API_BASE_URL=https://test.api.com
ACCESS_TOKEN=test_mock_token
''');
  });

  group('PERecordService Tests', () {
    test('fetchPERecords returns records successfully', () async {
   
      final mockClient = MockClient((request) async {
        expect(request.url.toString(),
            'https://test.api.com/api/PERecordsApi/filter?page=1&pageSize=20');
        expect(request.headers['Authorization'], 'Bearer test_mock_token');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'values': [
                {
                  'id': 1,
                  'peNumber': 'PE-1001',
                  'peTitle': 'Test Planned Event',
                  'status': 'Planned'
                }
              ]
            },
            'pagination': {'totalRecords': 1, 'currentPage': 1, 'totalPages': 1}
          }),
          200,
        );
      });

      final service = PERecordService(client: mockClient);

      final result = await service.fetchPERecords(page: 1, pageSize: 20);

      expect(result['records'], isA<List<PERecord>>());
      expect(result['totalCount'], 1);
      expect(result['currentPage'], 1);

      final records = result['records'] as List<PERecord>;
      expect(records.length, 1);
      expect(records.first.peNumber, 'PE-1001');
      expect(records.first.peTitle, 'Test Planned Event');
    });

    test('createPERecord returns success response', () async {
     
      final mockClient = MockClient((request) async {
        expect(request.url.toString(),
            'https://test.api.com/api/PlannedEventsApi');
        expect(request.method, 'POST');
        return http.Response(
          jsonEncode({'success': true, 'message': 'PE created successfully'}),
          200,
        );
      });

      final service = PERecordService(client: mockClient);

      final result = await service.createPERecord({'peTitle': 'New Test PE'});

  
      expect(result['success'], true);
      expect(result['data']['message'], 'PE created successfully');
    });

    test('fetchPERecordByNumber returns a single record', () async {
    
      const peNumber = 'PE-1002';
      final mockClient = MockClient((request) async {
        expect(request.url.toString(),
            'https://test.api.com/api/PERecordsApi/filter?page=1&pageSize=10&searchCategory=PE%20Number&searchValue=PE-1002');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'values': [
                {'id': 2, 'peNumber': 'PE-1002', 'peTitle': 'Specific PE'}
              ]
            }
          }),
          200,
        );
      });

      final service = PERecordService(client: mockClient);

     
      final record = await service.fetchPERecordByNumber(peNumber);

      expect(record, isNotNull);
      expect(record!.peNumber, 'PE-1002');
      expect(record.peTitle, 'Specific PE');
    });

    test('fetchPERecords handles API errors gracefully', () async {
   
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = PERecordService(client: mockClient);

      final result = await service.fetchPERecords();

      expect(result['records'], isEmpty);
      expect(result['totalCount'], 0);
    });
  });
}
