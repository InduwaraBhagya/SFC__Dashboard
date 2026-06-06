import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/OLAViolateRecord.dart';

class HoldRecordService {
  final List<OLAViolateRecord> _holdRecords = [];
  final String _baseUrl = dotenv.env['API_BASE_URL'] ??
      (throw Exception('API_BASE_URL not found in .env file'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get userId from secure storage
  Future<int> _getUserId() async {
    final storedUserId = await _storage.read(key: 'userId');
    if (storedUserId == null) throw Exception('UserId not found in storage');
    final userId = int.tryParse(storedUserId);
    if (userId == null) throw Exception('Invalid UserId in storage');
    return userId;
  }

  Future<Map<String, dynamic>> getHoldRecords({
    int? page,
    required int pageSize,
    String? searchTerm,
    int? workgroupId,
  }) async {
    try {
      final userId = await _getUserId();
      final queryParams = <String, String>{
        'page': page?.toString() ?? '1',
        'pageSize': pageSize.toString(),
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
        if (workgroupId != null) 'workgroupId': workgroupId.toString(),
      };
      final uri = Uri.parse('$_baseUrl/api/PlannedEvents/hold/user/$userId')
          .replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('Hold Records API Request URL: $uri');
      }
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (kDebugMode) {
        print('Hold Records API Response Status: ${response.statusCode}');
        print('Hold Records API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords =
            jsonDecode(response.body) as List<dynamic>;
        if (kDebugMode) {
          print('Hold Records Raw count: ${rawRecords.length}');
        }

        final records = rawRecords
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value as Map<String, dynamic>;
              try {
                return OLAViolateRecord.fromJson(item);
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  print('Error parsing hold record at index $index: $e');
                  print('Record data: $item');
                  print('StackTrace: $stackTrace');
                }
                return null;
              }
            })
            .where((r) => r != null)
            .cast<OLAViolateRecord>()
            .toList();

        if (kDebugMode) {
          print('Hold Records Parsed count: ${records.length}');
        }

        _holdRecords.clear();
        _holdRecords.addAll(records);

        return {
          'records': _holdRecords,
          'totalCount': records.length,
          'totalPages': (records.length / pageSize).ceil(),
          'currentPage': page ?? 1,
        };
      } else {
        if (response.statusCode == 404) {
          if (kDebugMode) {
            print('Hold Records API returned 404 — treating as empty result.');
          }
          return {
            'records': [],
            'totalCount': 0,
            'totalPages': 1,
            'currentPage': page ?? 1,
          };
        }
        if (kDebugMode) {
          print('Hold Records API Error Response: ${response.body}');
        }
        throw Exception('Failed to load hold records: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        if (e is io.SocketException) {
          print('Network error fetching hold records: ${e.message}');
        } else {
          print('Error fetching hold records: $e');
        }
      }
      return {
        'records': _holdRecords,
        'totalCount': _holdRecords.length,
        'totalPages': 1,
        'currentPage': 1,
      };
    }
  }

  /// Backwards-compatible alias expected by callers in DashboardHome.
  Future<Map<String, dynamic>> fetchHoldRecords({
    int? page,
    required int pageSize,
    String? searchTerm,
    int? workgroupId,
    bool fetchMultiWorkgroup = false,
  }) async {
    // fetchMultiWorkgroup is accepted for compatibility but ignored here
    return await getHoldRecords(
      page: page,
      pageSize: pageSize,
      searchTerm: searchTerm,
      workgroupId: workgroupId,
    );
  }

  Future<void> addHoldRecord(OLAViolateRecord record) async {
    if (!_holdRecords.any((r) => r.peNumber == record.peNumber)) {
      _holdRecords.add(record);
      if (kDebugMode) {
        print('Added hold record: ${record.peNumber}');
      }
    } else {
      if (kDebugMode) {
        print('Hold record ${record.peNumber} already exists');
      }
      throw Exception('Record already in hold records');
    }
  }

  int getTotalCount() => _holdRecords.length;
}
