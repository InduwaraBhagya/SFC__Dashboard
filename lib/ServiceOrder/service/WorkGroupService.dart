import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/WorkGroupModel.dart';

class WorkGroupService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  Future<List<WorkGroupDetails>> fetchWorkGroups() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      final response = await http.get(Uri.parse('$baseUrl/api/somsworkgroups'), headers: headers);

      print('fetchWorkGroups - URL: $baseUrl/api/somsworkgroups');
      print('fetchWorkGroups - Response status: ${response.statusCode}');
      // print('fetchWorkGroups - Response body: ${response.body}'); // Commented out to prevent massive logs

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> workGroups;
        if (data is List) {
          workGroups = data;
        } else if (data is Map<String, dynamic>) {
          workGroups = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return workGroups.map((json) {
          try {
            return WorkGroupDetails.fromJson(json);
          } catch (e) {
            print('Error parsing WorkGroupDetails: $e for JSON: $json');
            throw Exception('Failed to parse work group: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Work groups endpoint not found. Please verify the API URL.');
      } else {
        throw Exception(
            'Failed to load work groups: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching work groups: $e');
      rethrow;
    }
  }

  Future<List<WorkGroupDetails>> fetchWorkGroupDetails(
      String selectedWorkGroup) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/WorkGroups/$selectedWorkGroup'));

      print(
          'fetchWorkGroupDetails - URL: $baseUrl/api/WorkGroups/$selectedWorkGroup');
      print('fetchWorkGroupDetails - Response status: ${response.statusCode}');
      print('fetchWorkGroupDetails - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> details;
        if (data is List) {
          details = data;
        } else if (data is Map<String, dynamic>) {
          details = data[r'$values'] ?? [];
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
        return details.map((json) {
          try {
            return WorkGroupDetails.fromJson(json);
          } catch (e) {
            print('Error parsing WorkGroupDetails: $e for JSON: $json');
            throw Exception('Failed to parse work group details: $e');
          }
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception(
            'Work group details endpoint not found. Please verify the API URL.');
      } else {
        throw Exception(
            'Failed to load work group details: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching work group details: $e');
      rethrow;
    }
  }

  Future<bool> createWorkGroup(String name) async {
    try {
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/somsworkgroups'),
        headers: headers,
        body: json.encode({'WG_Name': name}),
      );

      print('createWorkGroup status: ${response.statusCode}');
      print('createWorkGroup body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating work group: $e');
      return false;
    }
  }

  Future<bool> updateWorkGroup(int id, String name) async {
    try {
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/somsworkgroups/$id'),
        headers: headers,
        body: json.encode({'id': id, 'WG_Name': name}),
      );

      print('updateWorkGroup status: ${response.statusCode}');
      print('updateWorkGroup body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating work group: $e');
      return false;
    }
  }

  Future<bool> deleteWorkGroup(int id) async {
    try {
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.delete(
        Uri.parse('$baseUrl/api/somsworkgroups/$id'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting work group: $e');
      return false;
    }
  }
}
