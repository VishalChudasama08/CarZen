# CarZen — Home Page (Flutter)

Home page UI for the CarZen used-car marketplace, built with Flutter and Material 3.

## Run it

```
flutter pub get
flutter run
```

## Structure

```
lib/
  main.dart                 # App entry point
  theme/app_theme.dart      # Colors, text styles, ThemeData (Material 3)
  models/car.dart           # Car, CarBrand, CarCategory models (JSON-ready)
  data/dummy_cars.dart      # Placeholder data — swap for API calls
  widgets/
    custom_app_bar.dart     # Logo, location, notification/profile icons
    hero_banner.dart        # Hero image + "Find Your Perfect Car" + CTA
    car_search_bar.dart     # Brand/model search field
    quick_filter_chips.dart # Brand / Price / Fuel / Transmission chips
    car_card.dart           # Featured/latest car card
    brand_list.dart         # Popular brands row
    category_list.dart      # SUV / Sedan / Hatchback / ... row
    section_header.dart     # "Title ... See all" row
  screens/home_screen.dart  # Composes everything above
```

## Connecting to the backend later

Every place the UI needs real data is marked with a `// TODO:` comment in
`home_screen.dart`:

- Replace `dummyCars`, `popularBrands`, `carCategories` (from `data/dummy_cars.dart`)
  with responses from your teammate's API, e.g. `GET /api/cars/featured`,
  `GET /api/brands`, `GET /api/categories`.
- `Car.fromJson(json)` already matches a listing object shaped like:
  ```json
  {
    "id": "1",
    "name": "Creta SX",
    "brand": "Hyundai",
    "year": 2022,
    "price": 1450000,
    "location": "Ahmedabad",
    "imageUrl": "https://...",
    "fuelType": "Petrol",
    "transmission": "Automatic",
    "isFavorite": false
  }
  ```
  so once the backend returns this shape, just call
  `Car.fromJson(item)` on each list item instead of using the dummy list.
- `_handleSearch`, `_toggleFavorite`, and the quick-filter `onChanged`
  callbacks in `home_screen.dart` are where you'll fire the actual
  search/filter/favorite API requests.
- Add an `ApiService`/`http` (or `dio`) client in a new `lib/services/`
  folder when the backend endpoints are ready.
