import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/RegularRecord.dart';

class RegularRecordService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchRegularRecords({
    String? workgroupName,
    String? searchTerm,
    required int page,
    required int pageSize,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? (throw Exception('API_BASE_URL not found in .env file'));
      
      final token = await _storage.read(key: 'access_token');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final wgName = workgroupName ?? await _storage.read(key: 'soms_selected_workgroup_name');
      if (wgName == null) {
        return {'records': [], 'totalCount': 0, 'totalPages': 1, 'currentPage': 1};
      }

      final uri = Uri.parse('$baseUrl/api/somsdashboard/records/${Uri.encodeComponent(wgName)}/inprogress');
      print('API Request URL: $uri');
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> rawRecords = jsonDecode(response.body);
        
        final records = rawRecords.map((item) {
          try {
            final mapItem = item as Map<String, dynamic>;
            if (mapItem.containsKey('plannedEvent') && mapItem['plannedEvent'] != null) {
              final plannedEvent = mapItem['plannedEvent'] as Map<String, dynamic>;
              mapItem['serviceRequiredDate'] = plannedEvent['serviceRequiredDate'];
              mapItem['pendingTaskName'] = plannedEvent['pendingTaskName'];
              mapItem['pendingWg'] = plannedEvent['pendingWg'];
            }
              mapItem['contractorName'] = mapItem['customer'];
              mapItem['soNumber'] = mapItem['soId'];
            return RegularRecord.fromJson(mapItem);
          } catch (e) {
            print('Error parsing regular record: $e');
            return null;
          }
        }).where((r) => r != null).cast<RegularRecord>().toList();

        return {
          'records': records,
          'totalCount': records.length,
          'currentPage': 1,
          'totalPages': 1,
        };
      } else {
        throw Exception('Failed to load regular records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching regular records: $e');
      return {'records': [], 'totalCount': 0, 'currentPage': 1, 'totalPages': 1};
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