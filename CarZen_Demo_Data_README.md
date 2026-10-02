# CarZen demo data - how to use `CarZen_Demo_Data_Inserts.sql`

The file contains **only `INSERT IGNORE INTO ...` statements** (102 of them). No UPDATE, DELETE, ALTER, CREATE, DROP or TRUNCATE.
The original `Dump20260930.sql` is untouched. **Nothing has been run against any database** - you run it yourself.

## When to run it
1. Import `Dump20260930.sql` (or already have the database it creates).
2. Apply the backend migrations exactly as you normally do (`alembic upgrade head`). The dump is already at revision `3e8d8588f13c`; the seed only needs the tables that dump contains, including the service tables.
3. **Then** run `CarZen_Demo_Data_Inserts.sql` against the same database, e.g.
   `mysql -u <user> -p <database_name> < CarZen_Demo_Data_Inserts.sql`
4. Start the backend and the Flutter app.

Running it before the tables exist will fail. Running it twice is safe: every row has a fixed id in the 101-199 range (the dump's highest ids are users 4, cars 3, listings 2, orders 4, notifications 27), so a second run skips the rows that are already there.

`INSERT IGNORE` turns errors into warnings, so after running, check the counts below - a smaller number means some rows were skipped (for example a phone number or email you already used).

## Demo logins (password for all: `Demo@1234`)
| Role  | Email                        | Use it to see |
|-------|------------------------------|---------------|
| user  | riya.patel@carzendemo.com    | favourites, orders, enquiries, service bookings in every state, service history |
| user  | arjun.mehta@carzendemo.com   | the seller side: 8 cars (6 listed, 1 pending approval, 1 rejected), orders and enquiries received |
| admin | neha.admin@carzendemo.com    | car approvals, orders, service catalogue, service-request management |

The password hashes are real bcrypt (`$2b$12$...`) produced with passlib's `CryptContext(schemes=["bcrypt"])`, the same call as `hash_password()` in `core/security.py`, and were verified to match `Demo@1234`.

## What is inserted (expected rows)
users 3 - car_brands 4 - car_models 4 - car_variants 6 - addresses 3 - cars 10 - car_features 12 - listings 6 - favorites 3 - orders 3 - inquiries 2 - inquiry_messages 4 - services 9 - service_records 2 - service_items 4 - service_requests 7 - service_request_items 9 - notifications 11

* **Marketplace:** 5 cars are published, verified and `ACTIVE` (they appear on Home and Browse together with the dump's own active listing); 1 listing is `RESERVED` (hidden from public lists by the backend). Car 107 is `pending_approval` and car 108 is `rejected` with a reason, for the admin approval screen and the seller's view.
* **Services:** 9 services (8 active, 1 inactive - the inactive one shows only in the admin catalogue). Seven service requests for Riya, one in each state: requested, accepted, scheduled, in progress, completed (linked to a service record), cancelled, rejected. Two service-history records.
* **Cars for service booking:** cars 109 and 110 belong to Riya with status `approved`, the same status the backend gives cars added through `POST /v1/service/my-cars`.
* **Existing data:** nothing in the dump is modified. The dump's existing users keep their passwords; the demo accounts are new.

## Limitations (please read)
* **No photos.** Car photos are files served by the backend from its uploads folder, and a SQL file cannot create files. I did not insert guessed image URLs. Seeded cars and services therefore show the app's navy placeholder. To show real photos: log in as `arjun.mehta@carzendemo.com`, open Sell Car -> a car -> Photos & Media, and upload images (or set `image_url` on services from the admin Service Catalog screen).
* **Payment is not seeded.** Orders and service requests have `payment_status` `UNPAID` / `unpaid` and no payment rows; the app shows that status as information only.
* **Dates.** Service request dates are around 2 - 15 October 2026. The backend only rejects *new* requests in the past, so these rows display fine whenever you run the file.

