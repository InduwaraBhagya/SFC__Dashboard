import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'AuthService.dart';

class DataManagementService {
  final AuthService _authService = AuthService();

  Future<List<dynamic>> fetchEntities() async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/datamanagement/entities';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching entities from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Entities response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Fetched ${data.length} entities');
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load entities: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchEntities: $e');
      throw Exception('Error fetching entities: $e');
    }
  }

  Future<List<dynamic>> fetchTableRecords(String tableName) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/datamanagement/records/$tableName';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching records for $tableName from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Records response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load records: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchTableRecords: $e');
      return []; // Return empty list on error
    }
  }

  Future<Map<String, dynamic>> fetchRecordDetails(String tableName, String id) async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/datamanagement/recordDetails/$tableName/$id';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching record details for $tableName ID $id from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Record details response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load record details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchRecordDetails: $e');
      return {}; // Return empty map on error
    }
  }

  Future<List<dynamic>> fetchRelationships() async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL is not configured in .env');
      }

      final String fullApiUrl = '$apiUrl/api/datamanagement/relationships';
      final headers = await _authService.getAuthenticatedHeaders();
      
      print('Fetching relationships from: $fullApiUrl');
      final response = await http.get(Uri.parse(fullApiUrl), headers: headers);
      print('Relationships response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Failed to load relationships: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchRelationships: $e');
      throw Exception('Error fetching relationships: $e');
    }
  }
}
