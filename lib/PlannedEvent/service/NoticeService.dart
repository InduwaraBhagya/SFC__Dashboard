import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/Notice.dart';

class NoticeService {
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env file');
    }
    return url;
  }

  final String? accessToken;

  NoticeService({
    this.accessToken,
  });

  Future<List<Notice>> getActiveNotices() async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi');
      if (kDebugMode) {
        print('Get Active Notices API Request URL: $uri');
      }

      final token = accessToken ??
          await const FlutterSecureStorage().read(key: 'access_token');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get Active Notices API Response Status: ${response.statusCode}');
        print('Get Active Notices API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final dynamic data = jsonData['data'];
        List<Notice> notices;

        if (data is List) {
          // Handle list of notices (e.g., [{"id": 1, ...}, {"id": 2, ...}])
          notices = data
              .map((json) => Notice.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map) {
          // Handle single notice object
          notices = [Notice.fromJson(data as Map<String, dynamic>)];
        } else {
          notices = [];
        }

        return notices;
      } else {
        if (kDebugMode) {
          print('Get Active Notices API Error Response: ${response.body}');
        }
        throw Exception(
            'Failed to load active notices: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching active notices: $e');
      }
      throw Exception('Error fetching active notices: $e');
    }
  }

  Future<Notice?> getNoticeById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/NoticesApi/$id');
      if (kDebugMode) {
        print('Get Notice by ID API Request URL: $uri');
      }

      final token = accessToken ??
          await const FlutterSecureStorage().read(key: 'access_token');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get Notice by ID API Response Status: ${response.statusCode}');
        print('Get Notice by ID API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Notice.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        if (kDebugMode) {
          print('Get Notice by ID API Error Response: ${response.body}');
        }
        throw Exception('Failed to load notice: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notice by ID: $e');
      }
      throw Exception('Error fetching notice by ID: $e');
    }
  }

  Future<bool> createNotice(Map<String, dynamic> payload) async {
    try {
      final token = accessToken ??
          await const FlutterSecureStorage().read(key: 'access_token');
      final uri = Uri.parse('$baseUrl/api/notices');
      final response = await http.post(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error creating notice: $e');
      return false;
    }
  }

  Future<bool> togglePinNotice(
      int id, bool isPinned, int userId, String userName,
      [Map<String, dynamic>? extra]) async {
    try {
      final token = accessToken ??
          await const FlutterSecureStorage().read(key: 'access_token');
      final uri = Uri.parse('$baseUrl/api/notices/$id/pin');
      final body = {
        'isPinned': isPinned,
        'userId': userId,
        'userName': userName,
        if (extra != null) ...extra,
      };
      final response = await http.patch(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error toggling pin: $e');
      return false;
    }
  }

  Future<bool> deleteNotice(int id, int userId, String userName,
      [Map<String, dynamic>? extra]) async {
    try {
      final token = accessToken ??
          await const FlutterSecureStorage().read(key: 'access_token');
      final uri = Uri.parse('$baseUrl/api/notices/$id');
      final body = {
        'userId': userId,
        'userName': userName,
        if (extra != null) ...extra,
      };
      final response = await http.delete(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error deleting notice: $e');
      return false;
    }
  }
}
