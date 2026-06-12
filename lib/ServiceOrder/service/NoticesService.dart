import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoticesService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> fetchNotices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/notices'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true ? body['data'] as List<dynamic> : [];
      }
      return [];
    } catch (e) {
      print('Error fetching notices: $e');
      return [];
    }
  }

  Future<dynamic> createNotice({
    required String title,
    required String description,
    required int createdBy,
    required String createdUserName,
    bool isPinned = false,
    DateTime? startDate,
    DateTime? expireDate,
    bool isActive = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notices'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'createdBy': createdBy,
          'createdUserName': createdUserName,
          'isPinned': isPinned,
          'startDate': startDate?.toIso8601String(),
          'expireDate': expireDate?.toIso8601String(),
          'isActive': isActive,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'HTTP Error ${response.statusCode}', 'detail': response.body};
        }
      }
    } catch (e) {
      print('Error creating notice: $e');
      rethrow; 
    }
  }

  Future<dynamic> updateNotice({
    required int id,
    required String title,
    required String description,
    required int updatedBy,
    required String updatedUserName,
    DateTime? startDate,
    DateTime? expireDate,
    bool isActive = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/notices/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'updatedBy': updatedBy,
          'updatedUserName': updatedUserName,
          'startDate': startDate?.toIso8601String(),
          'expireDate': expireDate?.toIso8601String(),
          'isActive': isActive,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'HTTP Error ${response.statusCode}', 'detail': response.body};
        }
      }
    } catch (e) {
      print('Error updating notice: $e');
      return false;
    }
  }

  Future<dynamic> deleteNotice(int id, int updatedBy, String updatedUserName) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/notices/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'updatedBy': updatedBy,
          'updatedUserName': updatedUserName,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'HTTP Error ${response.statusCode}', 'detail': response.body};
        }
      }
    } catch (e) {
      print('Error deleting notice: $e');
      return false;
    }
  }

  Future<dynamic> togglePin(int id, bool isPinned, int updatedBy, String updatedUserName) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/notices/$id/pin'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'isPinned': isPinned,
          'updatedBy': updatedBy,
          'updatedUserName': updatedUserName,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'HTTP Error ${response.statusCode}', 'detail': response.body};
        }
      }
    } catch (e) {
      print('Error toggling pin: $e');
      return false;
    }
  }
}
