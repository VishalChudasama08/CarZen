import 'package:flutter/foundation.dart';
import 'package:carzen_flutter/models/pagination.dart';

typedef PageFetcher<T> = Future<PaginatedList<T>> Function(int page, int limit);

/// Drives one server-paginated list: keeps the current page, the items and
/// the backend's real [PaginationMeta], and guards against out-of-order
/// responses. The [fetch] callback closes over the active search / filters /
/// sort, so changing a filter is "update state, then [reset]" and changing
/// page keeps every filter intact.
class PagedController<T> extends ChangeNotifier {
  PagedController({required this.fetch, this.limit = 10});

  PageFetcher<T> fetch;
  final int limit;

  List<T> items = const [];
  PaginationMeta? meta;
  Object? error;
  bool loading = false;
  bool initialized = false;
  int page = 1;

  int _request = 0;
  bool _disposed = false;

  bool get hasData => items.isNotEmpty;

  /// True only for the very first load (nothing to show yet).
  bool get isFirstLoad => loading && !initialized;

  Future<void> load({int? page}) async {
    final target = page ?? this.page;
    final request = ++_request;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await fetch(target, limit);
      if (_disposed || request != _request) return;
      // The page vanished (items were deleted/cancelled): step back to the last real page.
      if (result.data.isEmpty && target > 1 && result.pagination.totalPages < target) {
        await load(page: result.pagination.totalPages);
        return;
      }
      this.page = result.pagination.page;
      items = result.data;
      meta = result.pagination;
    } catch (e) {
      if (_disposed || request != _request) return;
      error = e;
    }
    loading = false;
    initialized = true;
    notifyListeners();
  }

  /// Reload the page the user is on.
  Future<void> refresh() => load(page: page);

  /// Back to page 1 (after search/filter/sort changes).
  Future<void> reset() => load(page: 1);

  void goTo(int target) {
    if (target < 1 || (meta != null && target > meta!.totalPages)) return;
    load(page: target);
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
