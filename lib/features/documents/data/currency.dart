/// `GET /documents/currencies` — paginatsiyasiz massiv (MOBILE_APP_TZ.md 4.7-C).
class Currency {
  const Currency({required this.id, required this.name});

  final int id;
  final String name;

  factory Currency.fromJson(Map<String, dynamic> json) =>
      Currency(id: json['id'] as int, name: json['name'] as String? ?? '');

  static const uzs = Currency(id: 1, name: 'UZS');
  static const usd = Currency(id: 2, name: 'USD');
  static const defaults = [uzs, usd];
}
