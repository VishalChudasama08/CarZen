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

## Design system, Services and pagination (UI refresh)

* **Design system** - `lib/theme/app_theme.dart` holds the palette (`AppColors`), spacing (`AppSpacing`), radii (`AppRadii`), shadows and every component theme. Shared building blocks live in `lib/widgets/`: `AppLogo`, `SurfaceCard`, `PageContainer` / `PageHeader`, `StatusPill`, `NetworkPhoto` / `SkeletonBox`, and the state views in `state_views.dart` (loading, empty, error + retry, `ApiErrorView` for 401/403/404/network/role errors).
* **Navigation** - `carzen_nav_bar.dart`: navy top bar with inline links on wide screens, a grouped menu sheet plus `CarZenBottomBar` on phones. Roles are only `user` and `admin`; admins get Users, Car Approvals, Orders, Service Catalog and Service Requests instead of Buy / Sell / Services.
* **Services (customer)** - `/services` catalog (public, search, pagination), `/services/book` (services -> car -> date & time -> address -> notes; protected), `/services/requests` and `/services/requests/{id}` (track / cancel), `/services/history`. API wrappers: `service_catalog_api.dart`, `service_request_api.dart`, `address_service.dart`.
* **Services (admin)** - `/admin/services` (create, edit, activate / deactivate, delete) and `/admin/service-requests` (accept, reject, schedule, start, complete, cancel). Only actions backed by real endpoints are shown.
* **Addresses** - the backend reads `address_id` when a service request is created (the schema marks it optional but the code fails without it), so the booking form always asks for a saved address and can add one.
* **Pagination** - `PagedController` + `PaginationBar` (numbered pages on wide screens, Prev / "Page x of y" / Next on phones) drive Browse, services, service requests, history, orders, messages, notifications, car approvals and "My cars". Search, filters and sort are kept when the page changes. Endpoints that return plain lists (favourites, saved addresses, service cars, admin users) are not paginated.
* **Payment** is intentionally not implemented. `payment_status` values are shown as information only and no `/v1/payments` or service payment routes are called.
* **Demo data** - see `../CarZen_Demo_Data_README.md`.
