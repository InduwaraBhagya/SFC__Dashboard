import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/OLAViolateRecord.dart';

class UrgentRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchUrgentRecords({
    int? page,
    String? searchTerm,
    required int pageSize,
    String? workgroupId, // Accepting name or ID
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final wgName = workgroupId ?? await _storage.read(key: 'soms_selected_workgroup_name');
      if (wgName == null) {
        return {'records': [], 'totalCount': 0, 'totalPages': 1, 'currentPage': 1};
      }

      final url = Uri.parse('$baseUrl/api/somsdashboard/records/${Uri.encodeComponent(wgName)}/urgent');
      print('API Request URL (Urgent): $url');
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords = jsonDecode(response.body);
        
        final List<OLAViolateRecord> records = rawRecords.map((r) {
          try {
            return OLAViolateRecord.fromJson(r as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing record: $e');
            return null;
          }
        }).where((r) => r != null).cast<OLAViolateRecord>().toList();

        return {
          'records': records,
          'totalCount': records.length,
          'totalPages': 1,
          'currentPage': 1,
        };
      } else {
        throw Exception('Failed to load urgent records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching urgent records: $e');
      return {'records': [], 'totalCount': 0, 'totalPages': 1, 'currentPage': 1};
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
        for (var value in item.values) collectRefs(value);
      } else if (item is List) {
        for (var subItem in item) collectRefs(subItem);
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
          final resolved = resolve(refs[refId], depth: depth + 1, seenRefs: seenRefs);
          seenRefs.remove(refId);
          return resolved;
        }
        return item;
      }
      if (item is Map<String, dynamic>) {
        final resolvedMap = <String, dynamic>{};
        for (var entry in item.entries) {
          resolvedMap[entry.key] = resolve(entry.value, depth: depth + 1, seenRefs: seenRefs);
        }
        return resolvedMap;
      } else if (item is List) {
        return item.map((subItem) => resolve(subItem, depth: depth + 1, seenRefs: seenRefs)).toList();
      }
      return item;
    }

    collectRefs(data);
    return resolve(data);
  }
}