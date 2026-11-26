import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Listing reports: the reporter's own list and admin moderation.
class ReportService {
  ReportService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<PaginatedList<ReportRecord>> mine({int page = 1, int limit = 10}) async {
    final json = await _client.get('/reports/my', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ReportRecord.fromJson);
  }

  Future<PaginatedList<ReportRecord>> adminList({int page = 1, int limit = 10, String? status}) async {
    final json = await _client.get('/admin/reports', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ReportRecord.fromJson);
  }

  Future<ReportRecord> adminSetStatus(int id, String status, {String? note}) async {
    final json = await _client.patch('/admin/reports/$id/status', body: {
      'status': status,
      if (note != null && note.trim().isNotEmpty) 'admin_note': note.trim(),
    });
    return ReportRecord.fromJson(json as Map<String, dynamic>);
  }
}
