/// Represents a single car listing.
///
/// The field names intentionally mirror what a typical REST listing
/// endpoint (e.g. `GET /api/cars`) would return, so `Car.fromJson` can be
/// swapped in for [dummyCars] with no changes to the UI layer once the
/// backend (built by the teammate) exposes real endpoints.
class Car {
  final String id;
  final String name;
  final String brand;
  final int year;
  final double price;
  final String location;
  final String imageUrl;
  final String fuelType;
  final String transmission;
  final bool isFavorite;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.year,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.fuelType,
    required this.transmission,
    this.isFavorite = false,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'].toString(),
      name: json['name'] as String,
      brand: json['brand'] as String,
      year: json['year'] as int,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      fuelType: json['fuelType'] as String,
      transmission: json['transmission'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'year': year,
        'price': price,
        'location': location,
        'imageUrl': imageUrl,
        'fuelType': fuelType,
        'transmission': transmission,
        'isFavorite': isFavorite,
      };

  Car copyWith({bool? isFavorite}) => Car(
        id: id,
        name: name,
        brand: brand,
        year: year,
        price: price,
        location: location,
        imageUrl: imageUrl,
        fuelType: fuelType,
        transmission: transmission,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  /// e.g. "₹8.5L" for 850000
  String get formattedPrice {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(price % 100000 == 0 ? 0 : 1)}L';
    }
    return '₹${price.toStringAsFixed(0)}';
  }
}

/// Simple model for the "Popular Brands" section.
class CarBrand {
  final String name;
  final String logoUrl;

  const CarBrand({required this.name, required this.logoUrl});
}

/// Simple model for the "Categories" section (SUV, Sedan, Hatchback, etc).
class CarCategory {
  final String name;
  final String imageUrl;

  const CarCategory({required this.name, required this.imageUrl});
}
