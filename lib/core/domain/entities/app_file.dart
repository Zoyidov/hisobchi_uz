/// `POST /files/upload` javobi — URL faqat 1 soat amal qiladi, shuning uchun
/// lokal bazada saqlanmaydi, faqat `id` cache kaliti sifatida ishlatiladi
/// (MOBILE_APP_TZ.md 4.9).
class AppFile {
  const AppFile({required this.id, required this.url, this.name});

  final int id;
  final String url;
  final String? name;

  factory AppFile.fromJson(Map<String, dynamic> json) => AppFile(
        id: json['id'] as int,
        url: json['url'] as String? ?? '',
        name: json['name'] as String?,
      );
}
