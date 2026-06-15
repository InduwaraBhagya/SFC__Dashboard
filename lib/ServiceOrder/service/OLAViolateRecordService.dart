import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/OLAViolateRecord.dart';

class OLAViolateRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchOLAViolateRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
    String? workgroupId,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final wgName = workgroupId ??
          await _storage.read(key: 'soms_selected_workgroup_name');
      if (wgName == null) {
        return {
          'records': [],
          'totalCount': 0,
          'totalPages': 1,
          'currentPage': 1
        };
      }

      final url = Uri.parse(
          '$baseUrl/api/somsdashboard/records/${Uri.encodeComponent(wgName)}/olaViolated');
      print('API Request URL (OLA): $url');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords = jsonDecode(response.body);

        final List<OLAViolateRecord> records = rawRecords
            .map((r) {
              try {
                return OLAViolateRecord.fromJson(r as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing OLA record: $e');
                return null;
              }
            })
            .where((r) => r != null)
            .cast<OLAViolateRecord>()
            .toList();

        return {
          'records': records,
          'totalCount': records.length,
          'totalPages': 1,
          'currentPage': 1,
        };
      } else {
        throw Exception('Failed to load OLA records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching OLA records: $e');
      return {
        'records': [],
        'totalCount': 0,
        'totalPages': 1,
        'currentPage': 1
      };
    }
  }

  Future<OLAViolateRecord?> fetchPlannedEventDetails(int recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final url = Uri.parse('$baseUrl/PETasks/$recordId');
      print('API Request URL for details: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        print('API Response Body for details: ${response.body}');

        // Dereference JSON to handle $id/$ref
        result = dereferenceJson(result);
        print('Dereferenced JSON: $result');

        // Handle different possible JSON structures
        Map<String, dynamic> recordData;
        if (result['records']?['\$values'] != null &&
            result['records']['\$values'].isNotEmpty) {
          recordData = result['records']['\$values'][0];
        } else if (result['data'] != null) {
          recordData = result['data'];
        } else if (result['\$values'] != null &&
            result['\$values'].isNotEmpty) {
          recordData = result['\$values'][0];
        } else
          recordData = result;

        print('Extracted record data: $recordData');
        try {
          final record = OLAViolateRecord.fromJson(recordData);
          print('Parsed OLAViolateRecord: ${record.toJson()}');
          print('peTask: ${record.peTask?.toJson()}');
          print('plannedEvent: ${record.plannedEvent?.toJson()}');
          print('additionalData: ${record.additionalData}');
          return record;
        } catch (e, stackTrace) {
          print('Error parsing record details: $e');
          print('Record data: $recordData');
          print('StackTrace: $stackTrace');
          return null;
        }
      } else {
        print('API Error Response for details: ${response.body}');
        throw Exception(
            'Failed to load record details: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching record details: $e');
      print('StackTrace: $stackTrace');

      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('$baseUrl/api/PETasks/$recordId');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        dynamic result = jsonDecode(response.body);
        result = dereferenceJson(result);

        Map<String, dynamic> recordData;
        if (result['records']?['\$values'] != null &&
            result['records']['\$values'].isNotEmpty) {
          recordData = result['records']['\$values'][0];
        } else if (result['data'] != null) {
          recordData = result['data'];
        } else {
          recordData = result;
        }

        return OLAViolateRecord.fromJson(recordData);
      }
      return null;
    } catch (e) {
      print('Error fetching record details: $e');

      return null;
    }
  }

  Future<bool> requestMarkOLARecordUrgent(String recordId) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ??
          (throw Exception('API_BASE_URL not found in .env file'));
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('$baseUrl/api/PETasks/$recordId/requesturgent');
      final response = await http.post(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  dynamic dereferenceJson(dynamic data) {
    final refs = <String, dynamic>{};
    final resolvedRefs = <String, bool>{};

    void collectRefs(dynamic item) {
      if (item is Map<String, dynamic> && item.containsKey('\$id')) {
        refs[item['\$id']] = item;
      }
      if (item is Map) {
        for (var value in item.values) {
          collectRefs(value);
        }
      } else if (item is List) {
        for (var subItem in item) {
          collectRefs(subItem);
        }
      }
    }

    dynamic resolve(dynamic item, {int depth = 0, Set<String>? seenRefs}) {
      const maxDepth = 100;
      seenRefs ??= {};
      if (depth > maxDepth) return item;
      if (item is Map<String, dynamic> && item.containsKey('\$ref')) {
        final refId = item['\$ref'];
        if (seenRefs.contains(refId)) return refs[refId] ?? item;
        if (refs.containsKey(refId) && !resolvedRefs.containsKey(refId)) {
          resolvedRefs[refId] = true;
          seenRefs.add(refId);
          final resolved =
              resolve(refs[refId], depth: depth + 1, seenRefs: seenRefs);
          seenRefs.remove(refId);
          return resolved;
        }
        return item;
      }
      if (item is Map<String, dynamic>) {
        final resolvedMap = <String, dynamic>{};
        for (var entry in item.entries) {
          resolvedMap[entry.key] =
              resolve(entry.value, depth: depth + 1, seenRefs: seenRefs);
        }
        return resolvedMap;
      } else if (item is List) {
        return item
            .map((subItem) =>
                resolve(subItem, depth: depth + 1, seenRefs: seenRefs))
            .toList();
      }
      return item;
    }

    collectRefs(data);
    return resolve(data);
  }
}
