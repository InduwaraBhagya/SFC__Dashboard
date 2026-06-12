import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  Future<List<Map<String, dynamic>>> getUrgentRequests() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/urgentrequests');
      print('API Request URL: $url'); 
      final response = await http.get(url);

      print('API Status Code: ${response.statusCode}'); 
      print('Raw API Response: ${response.body}'); 

      if (response.statusCode == 200) {
        final dynamic result = jsonDecode(response.body);
        print('Parsed JSON: $result');

        final List<dynamic> rawRecords = result['\$values'] ?? [];
        print('Raw records count: ${rawRecords.length}'); 

        final List<Map<String, dynamic>> records = rawRecords.map((r) {
          try {
            return {
              'Id': r['id']?.toString() ?? 'N/A', 
              'PENumber': r['peNumber']?.toString() ?? 'N/A', 
              'TaskSeq': r['taskSeq']?.toString() ?? 'N/A', 
              'Task': r['task']?.toString() ?? 'N/A', 
            };
          } catch (e, stackTrace) {
            print('Error parsing record: $e');
            print('Record data: $r');
            print('StackTrace: $stackTrace');
            return null;
          }
        }).where((r) => r != null).cast<Map<String, dynamic>>().toList();

        print('Parsed records count: ${records.length}'); 
        return records;
      } else {
        print('API Error Response: ${response.body}'); 
        throw Exception('Failed to load urgent requests: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching urgent requests: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<bool> markAsUrgent(int id) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$id/markurgent');
      print('API Request URL for mark urgent: $url'); 
      final response = await http.post(url);

      print('Mark Urgent Status Code: ${response.statusCode}'); 
      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error Response for mark urgent: ${response.body}'); 
        throw Exception('Failed to mark task as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error marking task as urgent: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }

  Future<bool> rejectUrgent(int id) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$id/rejecturgent');
      print('API Request URL for reject urgent: $url'); 
      final response = await http.post(url);

      print('Reject Urgent Status Code: ${response.statusCode}'); 
      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error Response for reject urgent: ${response.body}'); 
        throw Exception('Failed to reject task as urgent: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error rejecting task as urgent: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }
}