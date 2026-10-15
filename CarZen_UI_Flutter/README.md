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
* **Demo data** - see `../CarZen_Demo_Data_README.md`.

## CarZen V4 Upgrade (Web + Android + iOS)

### 1. Overview & Multiplatform Support
CarZen V4 upgrades the frontend to integrate with the V4 FastAPI backend across **Web, Android, and iOS**:
- **Platform-Aware API Config**: `ApiConfig.baseUrl` dynamically resolves `--dart-define=API_BASE_URL`, defaulting to `http://10.0.2.2:8000` on Android (emulator) and `http://127.0.0.1:8000` on Web/iOS.
- **Responsive Design**: All screens support phone (360px), tablet (768px), and desktop (1280px+) without overflow, using `Breakpoints`, responsive cards, and dynamic navigation.
- **Universal Back Navigation**: `CarZenNavBar` and `PageBackButton` supply visible back buttons on deep links and sub-routes using `fallbackRoute`.

### 2. Clean, Readable Slugs & Routes
- Car details: `/cars/{title-slug}-{id}` (e.g. `/cars/toyota-fortuner-42`) with trailing numeric ID resolution. Legacy `/cars/42` links automatically alias.
- Book service: Clean `/services/book` URL; pre-selected service IDs passed via route arguments instead of query parameters.
- Service requests: `/services/requests/request-{id}` with support for legacy `/services/requests/{id}`.
- Admin portal: `/admin` loads the new Admin Dashboard, with Car Moderation mapped to `/admin/cars`.

### 3. Payment Flow & Razorpay Integration
A platform-agnostic `PaymentLauncher` drives the payment lifecycle:
- **Web**: Directly invokes Razorpay Checkout (`checkout.js`) loaded via HTML script tag.
- **Mobile (Android/iOS)**: Launches an in-app `webview_flutter` modal executing Razorpay checkout with a bidirectional JavaScript channel bridge (`RazorpayBridge`) communicating payment completion back to Flutter.
- **₹50,000 Account Limit**: Configured in `PaymentLimits.maxOnlineInr = 50000`. Amounts above ₹50,000 guide the user to cash/counter or bank transfer arrangements.
- **Service Request Billing & Payment**:
  - `POST /service-requests/{id}/pay-online`: Creates Razorpay order and returns order details.
  - `POST /service-requests/{id}/verify-online`: Verifies cryptographic signature and updates status to `paid`.
  - `POST /service-requests/{id}/pay-cash`: Switches customer method to workshop counter payment.
  - `POST /admin/service-requests/{id}/confirm-cash`: Admin records receipt of counter cash.
- **Car Order Payments**: Wireframes purchase payments on `MyOrdersScreen` and `AdminOrdersScreen` via `POST /payments` and `POST /payments/{id}/verify`.

### 4. Backend Gaps (Ayush) & Defensive Architecture
Every known backend limitation is defensively handled and documented in code with `// TODO(Ayush):`:
- **Gap A (`lib/models/listing_models.dart`, `lib/pages/car_details_screen.dart`)**: Buyer-side listing APIs return only `seller_id`. Frontend renders a defensive Seller Information card with an inquiry fallback.
- **Gap B (`lib/widgets/admin_user_dialogs.dart`)**: Blocking/deleting users does not automatically archive listings. Admin confirmation dialog displays explicit advisory.
- **Gap C (`lib/pages/admin_cars_screen.dart`)**: Admin car list endpoint returns `owner_id` only. Details fetched lazily to display seller and brand.
- **Gap D (`lib/pages/admin_users_screen.dart`)**: `/admin/users` returns unpaginated list. Paginated client-side (10/page) with full-text search.
- **Gap E (`lib/pages/admin_dashboard_screen.dart`)**: No aggregated metrics endpoint. Assembled via parallel list requests.
- **Gap F (`lib/services/order_service.dart`)**: Razorpay online ceiling of ₹50,000 versus vehicle purchase totals.
- **Gap G (`lib/services/car_service.dart`)**: Primary photo persistence on `PATCH .../primary`. First photo automatically marked as primary.
- **Gap H**: Service providers manage work orders centrally through the admin portal.

