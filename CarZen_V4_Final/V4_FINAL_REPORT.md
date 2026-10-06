# CarZen V4 - final corrected database

Files
- `carzen_db_v4.sql` - complete standalone dump (28 tables, 717 rows): DROP/CREATE + INSERT for every table. Import into an empty database.
- `backend/uploads/cars/` - the 73 car photos referenced by the SQL (copy into the repo's `backend/uploads/cars/`). **Delete the old `201_...` to `217_...` files first; they are no longer referenced.**
- `PHOTO_CREDITS.csv` - source file of every photo.

Result of the check: 116 consistency checks on the final file -> 0 violations (the same checks found 23 problem groups in the uploaded file). The file loads on an empty database, the 12 accounts (all password `Demo@1234`) log in through the real backend, every image row has an existing file with the right size.

## What was fixed
| Audit item | Fix |
|---|---|
| C-1 cars 1-6 verified by non-admin user 3 | `verified_by_id` -> 12 (admin); admin notifications 1-2 moved to user 12 |
| M-1 cars 1-10 had no photos | 26 photos added (2-3 per car) |
| D-3 media file names carried old ids 201-217 | all 73 files/URLs renamed `<car_id>_<brand>_<model>_<year>_<angle>.jpg`; car 12's white rear photo replaced by a red one |
| M-2 46 models / 3 brands (Skoda, VW, MG) without variants | 86 variants added (ids 75-160, seats match the model) |
| R-6 Nexon EV modelled twice | variant 6 moved to model 82 "Nexon EV" |
| M-4 seller 2 had no contact | contact 5 added |
| R-1 service 8 price conflict | request 15 / item 20 set to 999 (= catalogue); service 8 description restored |
| R-3 active listing with a PROCESSING order | listing 16 -> RESERVED |
| R-5 car 25 horsepower | 82 -> 80 (= variant 38) |
| D-2 15-character VINs (cars 1-10) | 17 characters `CZDEMOVIN000000NN` |
| P-3 used price above new price (listings 12, 16) | ex-showroom of variants 64 and 70 raised to 1,650,000 / 1,560,000 |
| P-2 listing 4 had 0 views | 118 views + 3 view records |
| T-1 doubled apostrophes | notifications 25, 27, orders 4, reports 4 |
| T-2 old names in text | inquiry_messages 2, 6, 10, 12, inquiries 5, notification 11 |
| T-3 wrong request numbers / title | notifications 7, 8, 9, 22, 32, 35, 36, 40, 44, 45, 46; title of 13 |
| T-4 children older than parents | catalogue, users, addresses, services, cars 13/15/17/25/26/27 and V3 data re-dated; order 3, view 4, 9 favourites, 5 old service requests re-dated |
| structure | `alembic_version` table restored (revision 3e8d8588f13c). No other table structure changed. |
| colours matched to the photos | car 1 Speedy Blue, 2 Phantom Black, 7 Sleek Silver, 8 Fiery Red |

## Left unchanged on purpose
- Payment issues (see below).
- Car 17 (sold) is still owned by the seller: the schema has no previous-owner field and ownership transfer is application behaviour.
- Reviews 2-4 have no completed purchase behind them (schema allows it); user 3 stays as a normal user; near-name models (i20/Elite i20, Scorpio/Classic/N, Thar/Roxx, ...) are real separate models.
- Car 1's second photo is a differently coloured Swift (the dataset has only one more distinct 2018+ Swift shot).

## Payment issues to change in the future
1. Service requests 12, 13, 16, 18, 20 are `paid` by `cash` but have no row in `payments` (`service_request_id`).
2. Service request 5 is `completed` but `payment_status = 'unpaid'` (the other completed ones are `paid`).
3. Only 1 completed sale (order 4) has transaction + payment; more completed sales would also need payment rows, and reviews should then point to a `transaction_id`.
4. Order 4 / transaction 1 / payment 1 are cash-only; no online-payment (Razorpay) records exist.

## Photos
Source: India Car Market Images dataset by Atharva Taras (CC BY-SA 4.0), originally scraped web/press photos - stock photos of the model, not of one physical car. Use for this demo/college project with credit; not for commercial use.
