import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// Backend summa/pul qiymatlarini har doim `Decimal`ga parse qiladi —
/// `double` bilan pul hisoblash TAQIQLANADI (MOBILE_APP_TZ.md 4.8).
Decimal parseMoney(dynamic value) {
  if (value == null) return Decimal.zero;
  if (value is Decimal) return value;
  if (value is num) return Decimal.parse(value.toString());
  if (value is String && value.isNotEmpty) {
    return Decimal.tryParse(value) ?? Decimal.zero;
  }
  return Decimal.zero;
}

/// Backendga yuboriladigan raqamli qiymat (nuqta bilan, guruh ajratgichsiz).
String moneyToApi(Decimal value) => value.toString();

/// `freezed`/`json_serializable` modellarida `Decimal` maydonlar uchun.
class MoneyConverter implements JsonConverter<Decimal, dynamic> {
  const MoneyConverter();

  @override
  Decimal fromJson(dynamic json) => parseMoney(json);

  @override
  dynamic toJson(Decimal object) => object.toString();
}

class NullableMoneyConverter implements JsonConverter<Decimal?, dynamic> {
  const NullableMoneyConverter();

  @override
  Decimal? fromJson(dynamic json) => json == null ? null : parseMoney(json);

  @override
  dynamic toJson(Decimal? object) => object?.toString();
}
