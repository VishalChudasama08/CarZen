/// Mirrors `PaginationMeta` from `cars_schema.py`.
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        page: json['page'] as int,
        limit: json['limit'] as int,
        total: json['total'] as int,
        totalPages: json['total_pages'] as int,
      );
}

/// Mirrors the backend's generic `PaginatedResponse[T]` — every list
/// endpoint (`GET /v1/cars`, `/v1/listings`, `/v1/car-brands`, etc.)
/// returns this same `{data, pagination}` shape.
class PaginatedList<T> {
  final List<T> data;
  final PaginationMeta pagination;

  const PaginatedList({required this.data, required this.pagination});

  factory PaginatedList.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final rawData = (json['data'] as List<dynamic>? ?? []);
    return PaginatedList(
      data: rawData.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}
