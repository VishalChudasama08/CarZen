/// Lightweight view-model for the "Popular Brands" strip on Home. It is built
/// from real `CatalogBrand` records returned by `GET /v1/car-brands`.
class CarBrand {
  final String name;
  final String logoUrl;

  const CarBrand({required this.name, required this.logoUrl});
}
