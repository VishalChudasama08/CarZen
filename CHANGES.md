# CarZen UI refresh - what changed

Flutter only (`CarZen_UI_Flutter/`). `Ayush_CarZen_Backend_Python/` is byte-for-byte unchanged (backend code, migrations, `.env`, `Dump20260930.sql`).
No dependency was added to `pubspec.yaml`.

## New
- Design system: `theme/app_theme.dart` (palette, spacing, radii, shadows, all component themes), `AppLogo`, `SurfaceCard`, `PageContainer`/`PageHeader`, `StatusPill`, `NetworkPhoto`/`SkeletonBox`, `PagedController`, `PaginationBar`, `PagedListView`.
- Services: `models/service_models.dart`; `services/service_catalog_api.dart`, `service_request_api.dart`, `address_service.dart`; pages `services_screen`, `book_service_screen`, `my_service_requests_screen`, `service_request_detail_screen`, `service_history_screen`, `admin_services_screen`, `admin_service_requests_screen`; widgets `service_widgets`, `service_sheets`.
- Routes: `/services`, `/services/book`, `/services/requests[/id]`, `/services/history`, `/admin/services`, `/admin/service-requests`.
- Tests: `test/service_models_test.dart` (written, not run - no Flutter SDK was available).
- `CarZen_Demo_Data_Inserts.sql` + `CarZen_Demo_Data_README.md` (insert-only seed, not run).

## Restyled
Navigation (navy bar, phone bottom bar, role-aware), Home, Browse (page-based pagination, result counts), vehicle cards, Car Details, Sell Car landing + car management steps, Login/Register, Profile, Favorites, Orders, Messages, Notifications, Admin Users / Car Approvals / Orders.

## Removed
`pages/integration_unavailable_screen.dart` (the old Services placeholder).

## Behaviour notes found while reading the backend
- `POST /v1/service-requests`: the schema marks `address_id` optional, but the service code reads the address unconditionally and fails without it. The booking form therefore always requires a saved address (and can add one).
- A seller's identity is not exposed publicly (users can only be fetched by themselves or an admin), so Car Details shows a "Listed by a CarZen member" card and points to in-app messaging rather than a name/phone.
- `GET /v1/service/my-cars` returns every non-deleted car the user owns (including marketplace cars), so the booking car picker lists those too.
- Slot availability (`GET /v1/service-slots`) is global, not per car, and the backend does not stop two requests taking one slot.
