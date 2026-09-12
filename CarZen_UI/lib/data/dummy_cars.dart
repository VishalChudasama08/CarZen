import '../models/car.dart';

/// Placeholder data so the UI can be built and demoed before the backend
/// (in progress, built by the teammate) is ready. Replace the call sites
/// of this list with a real API call — e.g. `ApiService.fetchFeaturedCars()`
/// — once the endpoints exist; the [Car] model already matches the shape
/// a JSON response should have.
final List<Car> dummyCars = [
  const Car(
    id: '1',
    name: 'Creta SX',
    brand: 'Hyundai',
    year: 2022,
    price: 1450000,
    location: 'Ahmedabad',
    imageUrl: 'https://images.unsplash.com/photo-1568844293986-8d0400bd4745?w=800',
    fuelType: 'Petrol',
    transmission: 'Automatic',
  ),
  const Car(
    id: '2',
    name: 'City ZX',
    brand: 'Honda',
    year: 2021,
    price: 1150000,
    location: 'Surat',
    imageUrl: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800',
    fuelType: 'Petrol',
    transmission: 'Manual',
    isFavorite: true,
  ),
  const Car(
    id: '3',
    name: 'Swift VXI',
    brand: 'Maruti Suzuki',
    year: 2023,
    price: 725000,
    location: 'Vadodara',
    imageUrl: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
    fuelType: 'Petrol',
    transmission: 'Manual',
  ),
  const Car(
    id: '4',
    name: '3 Series',
    brand: 'BMW',
    year: 2020,
    price: 3650000,
    location: 'Ahmedabad',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
    fuelType: 'Diesel',
    transmission: 'Automatic',
  ),
  const Car(
    id: '5',
    name: 'Thar LX',
    brand: 'Mahindra',
    year: 2022,
    price: 1550000,
    location: 'Rajkot',
    imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800',
    fuelType: 'Diesel',
    transmission: 'Manual',
  ),
];

final List<CarBrand> popularBrands = [
  const CarBrand(name: 'Maruti Suzuki', logoUrl: 'https://logo.clearbit.com/marutisuzuki.com'),
  const CarBrand(name: 'Hyundai', logoUrl: 'https://logo.clearbit.com/hyundai.com'),
  const CarBrand(name: 'Honda', logoUrl: 'https://logo.clearbit.com/honda.com'),
  const CarBrand(name: 'Tata', logoUrl: 'https://logo.clearbit.com/tatamotors.com'),
  const CarBrand(name: 'Mahindra', logoUrl: 'https://logo.clearbit.com/mahindra.com'),
  const CarBrand(name: 'BMW', logoUrl: 'https://logo.clearbit.com/bmw.com'),
  const CarBrand(name: 'Toyota', logoUrl: 'https://logo.clearbit.com/toyota.com'),
  const CarBrand(name: 'Kia', logoUrl: 'https://logo.clearbit.com/kia.com'),
];

final List<CarCategory> carCategories = [
  const CarCategory(
    name: 'SUV',
    imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=400',
  ),
  const CarCategory(
    name: 'Sedan',
    imageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=400',
  ),
  const CarCategory(
    name: 'Hatchback',
    imageUrl: 'https://images.unsplash.com/photo-1622551864990-9a4d5f4a6c78?w=400',
  ),
  const CarCategory(
    name: 'Luxury',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
  ),
  const CarCategory(
    name: 'Electric',
    imageUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400',
  ),
];

const List<String> quickFilterBrands = ['Any Brand', 'Maruti', 'Hyundai', 'Honda', 'Tata', 'Mahindra'];
const List<String> quickFilterPrices = ['Any Price', 'Under 5L', '5L - 10L', '10L - 20L', '20L+'];
const List<String> quickFilterFuel = ['Any Fuel', 'Petrol', 'Diesel', 'Electric', 'CNG'];
const List<String> quickFilterTransmission = ['Any', 'Manual', 'Automatic'];
