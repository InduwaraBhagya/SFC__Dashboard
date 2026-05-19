import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'AuthService.dart';

class ProjectService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  final AuthService _authService = AuthService();

  Future<List<dynamic>> fetchProjects() async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/projects';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching projects from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Projects response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Fetched ${data.length} projects');
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchProjects: $e');
      throw Exception('Error fetching projects: $e');
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) return false;

      final String fullApiUrl = '$apiUrl/api/projects/$id';
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.delete(Uri.parse(fullApiUrl), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<Map<String, dynamic>> fetchProjectDetails(int id) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/projects/$id/details';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching details for project $id from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Project details response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load project details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchProjectDetails: $e');
      throw Exception('Error fetching project details: $e');
    }
  }

  Future<bool> createProject(String name) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) throw Exception('API_BASE_URL not set');

      final String fullApiUrl = '$apiUrl/api/projects';
      final headers = await _authService.getAuthenticatedHeaders();
      
      final response = await http.post(
        Uri.parse(fullApiUrl),
        headers: headers,
        body: jsonEncode({'projectName': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Create project error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in createProject: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchPETasks(String peNumber) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) throw Exception('API_BASE_URL not set');

      final String fullApiUrl = '$apiUrl/api/PETasksApi/by-pe/$peNumber';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching tasks for PE $peNumber from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Fetch tasks error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in fetchPETasks: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchServiceOrders(String query) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) throw Exception('API_BASE_URL not set');

      final String fullApiUrl = '$apiUrl/api/SomsDashboardApi/GetPlannedEvents?search=$query';
      final headers = await _authService.getAuthenticatedHeaders();
      
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> addSOToProject(int projectId, int plannedEventId) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) throw Exception('API_BASE_URL not set');

      final String fullApiUrl = '$apiUrl/api/projects/$projectId/add-so/$plannedEventId';
      final headers = await _authService.getAuthenticatedHeaders();
      
      final response = await http.post(Uri.parse(fullApiUrl), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
