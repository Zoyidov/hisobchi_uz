/// Backendning `simplePaginate` formati — `total`/`last_page` yo'q, faqat
/// `links.next` orqali "keyingi sahifa bormi" aniqlanadi (MOBILE_APP_TZ.md 4.7-A).
class SimplePage<T> {
  const SimplePage({required this.items, required this.hasNext});

  final List<T> items;
  final bool hasNext;

  factory SimplePage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = (json['data'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    final links = json['links'] as Map<String, dynamic>?;
    return SimplePage(items: data, hasNext: links?['next'] != null);
  }

  static const empty = SimplePage(items: [], hasNext: false);
}

/// Backendning standart `paginate` formati (Activity Log) — MOBILE_APP_TZ.md 4.7-B.
class StandardPage<T> {
  const StandardPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasNext => currentPage < lastPage;

  factory StandardPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = (json['data'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>? ?? const {};
    return StandardPage(
      items: data,
      currentPage: pagination['current_page'] as int? ?? 1,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? data.length,
    );
  }
}
