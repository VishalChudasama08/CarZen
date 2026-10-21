/// Helpers for reading numbers out of backend JSON.
///
/// FastAPI serialises every `Decimal` field (prices, mileage, engine cc,
/// horsepower, order amounts...) as a JSON **string** such as `"1680000.00"`,
/// so a plain `json['x'] as num` throws at runtime. These helpers accept
/// either a JSON number or a numeric string.
num? parseNumOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

/// Same as [parseNumOrNull] for fields the backend guarantees are present.
/// Throws a [FormatException] (instead of a confusing cast error) when the
/// value is missing or not numeric.
num parseNum(Object? value) {
  final parsed = parseNumOrNull(value);
  if (parsed == null) {
    throw FormatException('Expected a numeric value from the server but got: $value');
  }
  return parsed;
}
