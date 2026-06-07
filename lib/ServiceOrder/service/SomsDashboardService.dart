import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SomsDashboardService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchMetrics() async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      // Read selected workgroup name from secure storage
      final workgroupName = await _storage.read(key: 'soms_selected_workgroup_name');
      
      if (workgroupName == null) {
         return {
            'urgent': 0, 'inProgress': 0, 'olaViolated': 0, 'hold': 0, 'dormant': 0,
            'activeTeamMembers': 0, 'recentActivities': {'olaLeft': 0, 'totalTasks': 0}
         };
      }

      final String fullApiUrl = '$apiUrl/api/somsdashboard/metrics/${Uri.encodeComponent(workgroupName)}';
      
      // Read auth token
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching SOMS dashboard metrics: $e');
    }
  }

  Future<List<dynamic>> fetchRecords(String category) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final workgroupName = await _storage.read(key: 'soms_selected_workgroup_name');
      
      if (workgroupName == null) {
         return [];
      }

      final String fullApiUrl = '$apiUrl/api/somsdashboard/records/${Uri.encodeComponent(workgroupName)}/${Uri.encodeComponent(category)}';
      
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching SOMS dashboard records: $e');
    }
  }

  Future<String?> getSelectedWorkgroupName() async {
      return await _storage.read(key: 'soms_selected_workgroup_name');
  }
}
