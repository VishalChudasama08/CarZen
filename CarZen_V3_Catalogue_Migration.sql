-- CarZen V3 Catalogue Migration
-- Fixes Brand -> Model -> Variant so Add Car does not depend on existing listings.
-- Safe to re-run: inserts only missing models/variants. Existing cars are untouched.

START TRANSACTION;

-- =========================
-- MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Punch' name,'tata-punch' slug,'SUV' body_type,5 seats,'Compact SUV from Tata Motors.' description UNION ALL
 SELECT 'Harrier','tata-harrier','SUV',5,'Mid-size SUV from Tata Motors.' UNION ALL
 SELECT 'Safari','tata-safari','SUV',6,'Three-row SUV from Tata Motors.' UNION ALL
 SELECT 'Tiago','tata-tiago','HATCHBACK',5,'Compact hatchback from Tata Motors.' UNION ALL
 SELECT 'Altroz','tata-altroz','HATCHBACK',5,'Premium hatchback from Tata Motors.' UNION ALL
 SELECT 'Tigor','tata-tigor','SEDAN',5,'Compact sedan from Tata Motors.' UNION ALL
 SELECT 'Sierra','tata-sierra','SUV',5,'SUV model from Tata Motors.' UNION ALL
 SELECT 'Curvv','tata-curvv','SUV',5,'SUV coupe-style model from Tata Motors.'
) x ON b.slug='tata-motors'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Amaze' name,'honda-amaze' slug,'SEDAN' body_type,5 seats,'Compact sedan from Honda.' description UNION ALL
 SELECT 'Elevate','honda-elevate','SUV',5,'Mid-size SUV from Honda.' UNION ALL
 SELECT 'City Hatchback','honda-city-hatchback','HATCHBACK',5,'Hatchback model in the City family.'
) x ON b.slug='honda'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Venue' name,'hyundai-venue' slug,'SUV' body_type,5 seats,'Compact SUV from Hyundai.' description UNION ALL
 SELECT 'i20','hyundai-i20','HATCHBACK',5,'Premium hatchback from Hyundai.' UNION ALL
 SELECT 'Verna','hyundai-verna','SEDAN',5,'Mid-size sedan from Hyundai.' UNION ALL
 SELECT 'Tucson','hyundai-tucson','SUV',5,'Premium SUV from Hyundai.' UNION ALL
 SELECT 'Alcazar','hyundai-alcazar','SUV',7,'Three-row SUV from Hyundai.'
) x ON b.slug='hyundai'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Baleno' name,'maruti-baleno' slug,'HATCHBACK' body_type,5 seats,'Premium hatchback from Maruti Suzuki.' description UNION ALL
 SELECT 'Dzire','maruti-dzire','SEDAN',5,'Compact sedan from Maruti Suzuki.' UNION ALL
 SELECT 'Brezza','maruti-brezza','SUV',5,'Compact SUV from Maruti Suzuki.' UNION ALL
 SELECT 'Fronx','maruti-fronx','SUV',5,'Compact crossover SUV from Maruti Suzuki.' UNION ALL
 SELECT 'Grand Vitara','maruti-grand-vitara','SUV',5,'SUV from Maruti Suzuki.'
) x ON b.slug='maruti-suzuki'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- VARIANTS
-- =========================
-- Tata Sierra: the key catalogue entry for the reported Add Car problem.
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.engine_cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Pure' variant_name,'PETROL' fuel_type,'MANUAL' transmission,1199.00 engine_cc,118.00 hp,5 seats,1100000.00 price UNION ALL
 SELECT 'Adventure','PETROL','MANUAL',1199.00,118.00,5,1300000.00 UNION ALL
 SELECT 'Accomplished+','PETROL','DCT',1199.00,118.00,5,1600000.00
) x ON m.slug='tata-sierra'
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Tata Punch
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.engine_cc,x.hp,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Pure' variant_name,'PETROL' fuel_type,'MANUAL' transmission,1199.00 engine_cc,87.00 hp,650000.00 price UNION ALL
 SELECT 'Adventure AMT','PETROL','AMT',1199.00,87.00,800000.00 UNION ALL
 SELECT 'Creative+','PETROL','AMT',1199.00,87.00,950000.00
) x ON m.slug='tata-punch'
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Tata Harrier
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'DIESEL',x.transmission,1956.00,168.00,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Pure' variant_name,'MANUAL' transmission,1500000.00 price UNION ALL
 SELECT 'Adventure+','AUTOMATIC',2000000.00
) x ON m.slug='tata-harrier'
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Tata Safari
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'DIESEL',x.transmission,1956.00,168.00,6,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Pure' variant_name,'MANUAL' transmission,1600000.00 price UNION ALL
 SELECT 'Adventure+','AUTOMATIC',2100000.00
) x ON m.slug='tata-safari'
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Tata Tiago / Altroz / Tigor
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'PETROL',x.transmission,1199.00,84.00,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'XE' variant_name,'MANUAL' transmission,550000.00 price,'tata-tiago' slug UNION ALL
 SELECT 'XZA AMT','AMT',700000.00,'tata-tiago' UNION ALL
 SELECT 'Pure','MANUAL',700000.00,'tata-altroz' UNION ALL
 SELECT 'XZ+ Petrol DCA','DCT',950000.00,'tata-altroz' UNION ALL
 SELECT 'XE','MANUAL',600000.00,'tata-tigor' UNION ALL
 SELECT 'XZA+','AMT',750000.00,'tata-tigor'
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Tata Curvv
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'PETROL',x.transmission,1199.00,118.00,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Pure+' variant_name,'MANUAL' transmission,1000000.00 price UNION ALL
 SELECT 'Creative+','DCT',1400000.00
) x ON m.slug='tata-curvv'
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Honda Amaze / Elevate
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'PETROL',x.transmission,x.cc,x.hp,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'S' variant_name,'MANUAL' transmission,1199.00 cc,89.00 hp,800000.00 price,'honda-amaze' slug UNION ALL
 SELECT 'VX CVT','CVT',1199.00,89.00,1000000.00,'honda-amaze' UNION ALL
 SELECT 'SV','MANUAL',1498.00,119.00,1200000.00,'honda-elevate' UNION ALL
 SELECT 'ZX CVT','CVT',1498.00,119.00,1600000.00,'honda-elevate'
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Hyundai Venue / i20 / Verna
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'PETROL',x.transmission,x.cc,x.hp,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'S' variant_name,'MANUAL' transmission,1197.00 cc,81.00 hp,800000.00 price,'hyundai-venue' slug UNION ALL
 SELECT 'SX(O) DCT','DCT',998.00,118.00,1300000.00,'hyundai-venue' UNION ALL
 SELECT 'Sportz','MANUAL',1197.00,87.00,750000.00,'hyundai-i20' UNION ALL
 SELECT 'Asta(O) IVT','CVT',1197.00,87.00,1000000.00,'hyundai-i20' UNION ALL
 SELECT 'EX','MANUAL',1497.00,113.00,1100000.00,'hyundai-verna' UNION ALL
 SELECT 'SX(O) DCT','DCT',1482.00,158.00,1700000.00,'hyundai-verna'
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- Maruti Baleno / Dzire / Brezza
INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,'PETROL',x.transmission,1197.00,x.hp,5,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'Sigma' variant_name,'MANUAL' transmission,88.00 hp,700000.00 price,'maruti-baleno' slug UNION ALL
 SELECT 'Alpha AMT','AMT',88.00,950000.00,'maruti-baleno' UNION ALL
 SELECT 'VXi','MANUAL',80.00,700000.00,'maruti-dzire' UNION ALL
 SELECT 'ZXi AMT','AMT',80.00,850000.00,'maruti-dzire' UNION ALL
 SELECT 'LXi','MANUAL',102.00,850000.00,'maruti-brezza' UNION ALL
 SELECT 'ZXi AT','AUTOMATIC',102.00,1200000.00,'maruti-brezza'
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

-- =========================
-- ADDITIONAL INDIA-MARKET BRANDS
-- =========================
-- These are the 7 brands requested for V3 catalogue expansion.
-- Ford is retained as a historical/used-car catalogue because Ford ended
-- local manufacturing in India; its models remain relevant to used-car data.

INSERT INTO car_brands (name,slug,country,logo_url,description,is_active,created_at,updated_at,deleted_at)
SELECT x.name,x.slug,x.country,NULL,x.description,1,NOW(),NOW(),NULL
FROM (
 SELECT 'Toyota' name,'toyota' slug,'Japan' country,'Japanese automobile manufacturer with a broad India passenger-vehicle range.' description UNION ALL
 SELECT 'Mahindra','mahindra','India','Indian manufacturer known for SUVs, utility vehicles and electric vehicles.' UNION ALL
 SELECT 'Kia','kia','South Korea','South Korean automobile manufacturer with SUVs, MPVs and electric vehicles in India.' UNION ALL
 SELECT 'Skoda','skoda','Czech Republic','Czech automobile manufacturer offering sedans and SUVs in India.' UNION ALL
 SELECT 'Ford','ford','United States','American automobile manufacturer; India catalogue retained for historical and used-car listings.' UNION ALL
 SELECT 'Volkswagen','volkswagen','Germany','German automobile manufacturer offering sedans, SUVs and performance models in India.' UNION ALL
 SELECT 'MG','mg','United Kingdom','MG brand offering feature-rich SUVs, EVs and MPVs in India.'
) x
WHERE NOT EXISTS (SELECT 1 FROM car_brands b WHERE b.slug=x.slug);

-- =========================
-- TOYOTA MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Glanza' name,'toyota-glanza' slug,'HATCHBACK' body_type,5 seats,'Premium hatchback sold by Toyota in India.' description UNION ALL
 SELECT 'Urban Cruiser Taisor','toyota-urban-cruiser-taisor','SUV',5,'Compact crossover SUV from Toyota.' UNION ALL
 SELECT 'Rumion','toyota-rumion','MUV',7,'Seven-seat MPV from Toyota.' UNION ALL
 SELECT 'Urban Cruiser Hyryder','toyota-urban-cruiser-hyryder','SUV',5,'Mid-size SUV with petrol and strong-hybrid options.' UNION ALL
 SELECT 'Innova Crysta','toyota-innova-crysta','MUV',7,'Diesel MPV from Toyota.' UNION ALL
 SELECT 'Innova Hycross','toyota-innova-hycross','MUV',7,'Premium MPV with petrol and hybrid powertrains.' UNION ALL
 SELECT 'Fortuner','toyota-fortuner','SUV',7,'Body-on-frame SUV from Toyota.' UNION ALL
 SELECT 'Hilux','toyota-hilux','PICKUP',5,'Lifestyle pickup truck from Toyota.' UNION ALL
 SELECT 'Camry','toyota-camry','SEDAN',5,'Premium hybrid sedan from Toyota.' UNION ALL
 SELECT 'Vellfire','toyota-vellfire','MUV',7,'Luxury MPV from Toyota.' UNION ALL
 SELECT 'Land Cruiser 300','toyota-land-cruiser-300','SUV',5,'Premium full-size SUV from Toyota.'
) x ON b.slug='toyota'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- MAHINDRA MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'XUV 3XO' name,'mahindra-xuv-3xo' slug,'SUV' body_type,5 seats,'Compact SUV from Mahindra.' description UNION ALL
 SELECT 'Thar','mahindra-thar','SUV',4,'Lifestyle off-road SUV from Mahindra.' UNION ALL
 SELECT 'Thar Roxx','mahindra-thar-roxx','SUV',5,'Five-door lifestyle SUV from Mahindra.' UNION ALL
 SELECT 'Bolero','mahindra-bolero','SUV',7,'Rugged utility SUV from Mahindra.' UNION ALL
 SELECT 'Bolero Neo','mahindra-bolero-neo','SUV',7,'Compact body-on-frame SUV from Mahindra.' UNION ALL
 SELECT 'Scorpio Classic','mahindra-scorpio-classic','SUV',7,'Rugged seven-seat SUV from Mahindra.' UNION ALL
 SELECT 'Scorpio-N','mahindra-scorpio-n','SUV',7,'Modern body-on-frame SUV from Mahindra.' UNION ALL
 SELECT 'XUV700','mahindra-xuv700','SUV',7,'Premium family SUV from Mahindra.' UNION ALL
 SELECT 'XUV400','mahindra-xuv400','SUV',5,'Electric SUV from Mahindra.' UNION ALL
 SELECT 'BE 6','mahindra-be-6','SUV',5,'Electric SUV from Mahindra.' UNION ALL
 SELECT 'XEV 9e','mahindra-xev-9e','SUV',5,'Premium electric SUV from Mahindra.' UNION ALL
 SELECT 'Marazzo','mahindra-marazzo','MUV',7,'Seven-seat MPV from Mahindra.'
) x ON b.slug='mahindra'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- KIA MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Sonet' name,'kia-sonet' slug,'SUV' body_type,5 seats,'Compact SUV from Kia.' description UNION ALL
 SELECT 'Seltos','kia-seltos','SUV',5,'Mid-size SUV from Kia.' UNION ALL
 SELECT 'Carens','kia-carens','MUV',7,'Three-row family MPV from Kia.' UNION ALL
 SELECT 'Carens Clavis','kia-carens-clavis','MUV',7,'Updated three-row MPV from Kia.' UNION ALL
 SELECT 'Carnival','kia-carnival','MUV',7,'Premium MPV from Kia.' UNION ALL
 SELECT 'EV6','kia-ev6','SUV',5,'Premium electric crossover from Kia.' UNION ALL
 SELECT 'EV9','kia-ev9','SUV',6,'Large electric SUV from Kia.'
) x ON b.slug='kia'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- SKODA MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Kylaq' name,'skoda-kylaq' slug,'SUV' body_type,5 seats,'Compact SUV from Skoda.' description UNION ALL
 SELECT 'Kushaq','skoda-kushaq','SUV',5,'Mid-size SUV from Skoda.' UNION ALL
 SELECT 'Slavia','skoda-slavia','SEDAN',5,'Mid-size sedan from Skoda.' UNION ALL
 SELECT 'Kodiaq','skoda-kodiaq','SUV',7,'Premium seven-seat SUV from Skoda.' UNION ALL
 SELECT 'Octavia RS','skoda-octavia-rs','SEDAN',5,'Performance sedan from Skoda.' UNION ALL
 SELECT 'Superb','skoda-superb','SEDAN',5,'Premium sedan from Skoda.'
) x ON b.slug='skoda'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- FORD MODELS (HISTORICAL / USED-CAR CATALOGUE)
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'EcoSport' name,'ford-ecosport' slug,'SUV' body_type,5 seats,'Compact SUV formerly sold by Ford India; useful for used-car listings.' description UNION ALL
 SELECT 'Endeavour','ford-endeavour','SUV',7,'Large SUV formerly sold by Ford India; useful for used-car listings.' UNION ALL
 SELECT 'Figo','ford-figo','HATCHBACK',5,'Hatchback formerly sold by Ford India.' UNION ALL
 SELECT 'Aspire','ford-aspire','SEDAN',5,'Compact sedan formerly sold by Ford India.' UNION ALL
 SELECT 'Freestyle','ford-freestyle','SUV',5,'Crossover hatchback formerly sold by Ford India.' UNION ALL
 SELECT 'Fiesta','ford-fiesta','SEDAN',5,'Sedan formerly sold by Ford India.'
) x ON b.slug='ford'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- VOLKSWAGEN MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Taigun' name,'volkswagen-taigun' slug,'SUV' body_type,5 seats,'Compact SUV from Volkswagen.' description UNION ALL
 SELECT 'Virtus','volkswagen-virtus','SEDAN',5,'Mid-size sedan from Volkswagen.' UNION ALL
 SELECT 'Tiguan R-Line','volkswagen-tiguan-r-line','SUV',5,'Premium SUV from Volkswagen.' UNION ALL
 SELECT 'Tayron','volkswagen-tayron','SUV',5,'Premium SUV from Volkswagen.' UNION ALL
 SELECT 'Golf GTI','volkswagen-golf-gti','HATCHBACK',5,'Performance hatchback from Volkswagen.'
) x ON b.slug='volkswagen'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- MG MODELS
-- =========================
INSERT INTO car_models (brand_id,name,slug,body_type,seating_capacity,description,is_active,created_at,updated_at,deleted_at)
SELECT b.id,x.name,x.slug,x.body_type,x.seats,x.description,1,NOW(),NOW(),NULL
FROM car_brands b JOIN (
 SELECT 'Comet EV' name,'mg-comet-ev' slug,'HATCHBACK' body_type,4 seats,'Compact electric city car from MG.' description UNION ALL
 SELECT 'Windsor EV','mg-windsor-ev','HATCHBACK',5,'Electric crossover from MG.' UNION ALL
 SELECT 'Astor','mg-astor','SUV',5,'Mid-size SUV from MG.' UNION ALL
 SELECT 'Hector','mg-hector','SUV',5,'Mid-size SUV from MG.' UNION ALL
 SELECT 'Hector Plus','mg-hector-plus','SUV',7,'Three-row SUV from MG.' UNION ALL
 SELECT 'ZS EV','mg-zs-ev','SUV',5,'Electric SUV from MG.' UNION ALL
 SELECT 'Gloster','mg-gloster','SUV',7,'Premium full-size SUV from MG.' UNION ALL
 SELECT 'Majestor','mg-majestor','SUV',7,'Premium large SUV from MG.'
) x ON b.slug='mg'
WHERE NOT EXISTS (SELECT 1 FROM car_models m WHERE m.slug=x.slug);

-- =========================
-- REPRESENTATIVE VARIANTS
-- =========================
-- The variants below are catalogue/demo records, not a complete trim list.

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'toyota-glanza' slug,'G' variant_name,'PETROL' fuel_type,'MANUAL' transmission,1197.00 cc,88.00 hp,5 seats,750000.00 price UNION ALL
 SELECT 'toyota-glanza','V AMT','PETROL','AMT',1197.00,88.00,5,950000.00 UNION ALL
 SELECT 'toyota-urban-cruiser-taisor','S','PETROL','MANUAL',1197.00,89.00,5,800000.00 UNION ALL
 SELECT 'toyota-urban-cruiser-taisor','V Turbo AT','PETROL','AUTOMATIC',998.00,99.00,5,1250000.00 UNION ALL
 SELECT 'toyota-rumion','G','PETROL','MANUAL',1462.00,101.00,7,1100000.00 UNION ALL
 SELECT 'toyota-rumion','V AT','PETROL','AUTOMATIC',1462.00,101.00,7,1350000.00 UNION ALL
 SELECT 'toyota-urban-cruiser-hyryder','G Hybrid','HYBRID','AUTOMATIC',1490.00,114.00,5,1900000.00 UNION ALL
 SELECT 'toyota-urban-cruiser-hyryder','S','PETROL','MANUAL',1462.00,103.00,5,1300000.00 UNION ALL
 SELECT 'toyota-innova-crysta','GX','DIESEL','MANUAL',2393.00,148.00,7,2050000.00 UNION ALL
 SELECT 'toyota-innova-crysta','ZX','DIESEL','AUTOMATIC',2393.00,148.00,7,2750000.00 UNION ALL
 SELECT 'toyota-innova-hycross','GX','PETROL','AUTOMATIC',1987.00,172.00,7,2000000.00 UNION ALL
 SELECT 'toyota-innova-hycross','ZX Hybrid','HYBRID','AUTOMATIC',1987.00,184.00,7,3000000.00 UNION ALL
 SELECT 'toyota-fortuner','4x2 Diesel MT','DIESEL','MANUAL',2755.00,201.00,7,3400000.00 UNION ALL
 SELECT 'toyota-fortuner','4x4 Diesel AT','DIESEL','AUTOMATIC',2755.00,201.00,7,4200000.00 UNION ALL
 SELECT 'toyota-hilux','Standard','DIESEL','MANUAL',2755.00,201.00,5,3200000.00 UNION ALL
 SELECT 'toyota-hilux','High AT','DIESEL','AUTOMATIC',2755.00,201.00,5,3650000.00 UNION ALL
 SELECT 'toyota-camry','Hybrid','HYBRID','AUTOMATIC',2487.00,227.00,5,4900000.00 UNION ALL
 SELECT 'toyota-vellfire','VIP','HYBRID','AUTOMATIC',2487.00,190.00,7,12000000.00 UNION ALL
 SELECT 'toyota-land-cruiser-300','ZX','DIESEL','AUTOMATIC',3346.00,304.00,5,22000000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'mahindra-xuv-3xo' slug,'MX2 Pro','PETROL','MANUAL',1197.00,110.00,5,800000.00 UNION ALL
 SELECT 'mahindra-xuv-3xo','AX7 L TGDi','PETROL','AUTOMATIC',1197.00,129.00,5,1400000.00 UNION ALL
 SELECT 'mahindra-thar','AX Opt','DIESEL','MANUAL',2184.00,130.00,4,1350000.00 UNION ALL
 SELECT 'mahindra-thar','LX AT','PETROL','AUTOMATIC',1997.00,150.00,4,1800000.00 UNION ALL
 SELECT 'mahindra-thar-roxx','MX5','DIESEL','MANUAL',2184.00,175.00,5,1700000.00 UNION ALL
 SELECT 'mahindra-thar-roxx','AX7 L','DIESEL','AUTOMATIC',2184.00,175.00,5,2300000.00 UNION ALL
 SELECT 'mahindra-bolero','B4','DIESEL','MANUAL',1493.00,74.00,7,850000.00 UNION ALL
 SELECT 'mahindra-bolero','B6 Opt','DIESEL','MANUAL',1493.00,74.00,7,1000000.00 UNION ALL
 SELECT 'mahindra-bolero-neo','N10','DIESEL','MANUAL',1493.00,100.00,7,1100000.00 UNION ALL
 SELECT 'mahindra-scorpio-classic','S','DIESEL','MANUAL',2184.00,130.00,7,1400000.00 UNION ALL
 SELECT 'mahindra-scorpio-n','Z4','DIESEL','MANUAL',2184.00,172.00,7,1700000.00 UNION ALL
 SELECT 'mahindra-scorpio-n','Z8L','DIESEL','AUTOMATIC',2184.00,172.00,7,2300000.00 UNION ALL
 SELECT 'mahindra-xuv700','MX','PETROL','MANUAL',1997.00,197.00,5,1450000.00 UNION ALL
 SELECT 'mahindra-xuv700','AX7 L','DIESEL','AUTOMATIC',2198.00,182.00,7,2500000.00 UNION ALL
 SELECT 'mahindra-xuv400','EL Pro','ELECTRIC','AUTOMATIC',NULL,147.00,5,1600000.00 UNION ALL
 SELECT 'mahindra-be-6','Pack One','ELECTRIC','AUTOMATIC',NULL,231.00,5,2000000.00 UNION ALL
 SELECT 'mahindra-xev-9e','Pack Three','ELECTRIC','AUTOMATIC',NULL,285.00,5,3000000.00 UNION ALL
 SELECT 'mahindra-marazzo','M2','DIESEL','MANUAL',1497.00,120.00,7,1450000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'kia-sonet' slug,'HTK','PETROL','MANUAL',1197.00,81.00,5,850000.00 UNION ALL
 SELECT 'kia-sonet','GTX+ DCT','PETROL','DCT',998.00,118.00,5,1400000.00 UNION ALL
 SELECT 'kia-seltos','HTK+','PETROL','MANUAL',1497.00,113.00,5,1200000.00 UNION ALL
 SELECT 'kia-seltos','GTX+ DCT','PETROL','DCT',1482.00,158.00,5,2000000.00 UNION ALL
 SELECT 'kia-carens','Premium','PETROL','MANUAL',1497.00,115.00,7,1100000.00 UNION ALL
 SELECT 'kia-carens','Luxury Plus DCT','PETROL','DCT',1482.00,158.00,7,2000000.00 UNION ALL
 SELECT 'kia-carens-clavis','HTK+','PETROL','MANUAL',1497.00,115.00,7,1200000.00 UNION ALL
 SELECT 'kia-carens-clavis','X-Line DCT','PETROL','DCT',1482.00,158.00,7,2000000.00 UNION ALL
 SELECT 'kia-carnival','Limousine Plus','DIESEL','AUTOMATIC',2151.00,190.00,7,6500000.00 UNION ALL
 SELECT 'kia-ev6','GT Line','ELECTRIC','AUTOMATIC',NULL,229.00,5,6500000.00 UNION ALL
 SELECT 'kia-ev9','GT Line','ELECTRIC','AUTOMATIC',NULL,384.00,6,13000000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'skoda-kylaq' slug,'Classic','PETROL','MANUAL',999.00,114.00,5,800000.00 UNION ALL
 SELECT 'skoda-kylaq','Prestige AT','PETROL','AUTOMATIC',999.00,114.00,5,1350000.00 UNION ALL
 SELECT 'skoda-kushaq','Classic','PETROL','MANUAL',999.00,113.00,5,1100000.00 UNION ALL
 SELECT 'skoda-kushaq','Prestige 1.5 DSG','PETROL','DCT',1498.00,148.00,5,1900000.00 UNION ALL
 SELECT 'skoda-slavia','Classic','PETROL','MANUAL',999.00,113.00,5,1100000.00 UNION ALL
 SELECT 'skoda-slavia','Prestige 1.5 DSG','PETROL','DCT',1498.00,148.00,5,1900000.00 UNION ALL
 SELECT 'skoda-kodiaq','Sportline','PETROL','DCT',1984.00,188.00,7,4000000.00 UNION ALL
 SELECT 'skoda-kodiaq','L&K','PETROL','DCT',1984.00,188.00,7,4700000.00 UNION ALL
 SELECT 'skoda-octavia-rs','RS','PETROL','DCT',1984.00,265.00,5,5000000.00 UNION ALL
 SELECT 'skoda-superb','L&K','PETROL','DCT',1984.00,190.00,5,5500000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'ford-ecosport' slug,'Titanium','PETROL','MANUAL',1497.00,121.00,5,950000.00 UNION ALL
 SELECT 'ford-ecosport','S Diesel','DIESEL','MANUAL',1498.00,99.00,5,1050000.00 UNION ALL
 SELECT 'ford-endeavour','Titanium 4x2','DIESEL','AUTOMATIC',1996.00,170.00,7,3300000.00 UNION ALL
 SELECT 'ford-endeavour','Titanium+ 4x4','DIESEL','AUTOMATIC',1996.00,170.00,7,4000000.00 UNION ALL
 SELECT 'ford-figo','Titanium','PETROL','MANUAL',1194.00,94.00,5,700000.00 UNION ALL
 SELECT 'ford-figo','Titanium Diesel','DIESEL','MANUAL',1498.00,99.00,5,850000.00 UNION ALL
 SELECT 'ford-aspire','Titanium','PETROL','MANUAL',1194.00,94.00,5,750000.00 UNION ALL
 SELECT 'ford-aspire','Titanium Diesel','DIESEL','MANUAL',1498.00,99.00,5,900000.00 UNION ALL
 SELECT 'ford-freestyle','Titanium','PETROL','MANUAL',1194.00,94.00,5,800000.00 UNION ALL
 SELECT 'ford-fiesta','Titanium','PETROL','MANUAL',1499.00,109.00,5,950000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'volkswagen-taigun' slug,'Comfortline','PETROL','MANUAL',999.00,113.00,5,1200000.00 UNION ALL
 SELECT 'volkswagen-taigun','GT Plus DSG','PETROL','DCT',1498.00,148.00,5,2000000.00 UNION ALL
 SELECT 'volkswagen-virtus','Comfortline','PETROL','MANUAL',999.00,113.00,5,1200000.00 UNION ALL
 SELECT 'volkswagen-virtus','GT Plus DSG','PETROL','DCT',1498.00,148.00,5,2000000.00 UNION ALL
 SELECT 'volkswagen-tiguan-r-line','R-Line','PETROL','DCT',1984.00,201.00,5,4800000.00 UNION ALL
 SELECT 'volkswagen-tayron','Elegance','PETROL','DCT',1984.00,201.00,5,4200000.00 UNION ALL
 SELECT 'volkswagen-golf-gti','GTI','PETROL','DCT',1984.00,261.00,5,5100000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

INSERT INTO car_variants (model_id,variant_name,fuel_type,transmission,engine_cc,horsepower,seating_capacity,ex_showroom_price,created_at,updated_at,deleted_at)
SELECT m.id,x.variant_name,x.fuel_type,x.transmission,x.cc,x.hp,x.seats,x.price,NOW(),NOW(),NULL
FROM car_models m JOIN (
 SELECT 'mg-comet-ev' slug,'Executive','ELECTRIC','AUTOMATIC',NULL,42.00,4,750000.00 UNION ALL
 SELECT 'mg-comet-ev','Exclusive','ELECTRIC','AUTOMATIC',NULL,42.00,4,1000000.00 UNION ALL
 SELECT 'mg-windsor-ev','Excite','ELECTRIC','AUTOMATIC',NULL,134.00,5,1400000.00 UNION ALL
 SELECT 'mg-windsor-ev','Essence','ELECTRIC','AUTOMATIC',NULL,134.00,5,1700000.00 UNION ALL
 SELECT 'mg-astor','Sprint','PETROL','MANUAL',1349.00,108.00,5,1100000.00 UNION ALL
 SELECT 'mg-astor','Savvy Pro CVT','PETROL','CVT',1349.00,138.00,5,1700000.00 UNION ALL
 SELECT 'mg-hector','Shine Pro','PETROL','CVT',1451.00,141.00,5,1700000.00 UNION ALL
 SELECT 'mg-hector','Savvy Pro','PETROL','CVT',1451.00,141.00,5,2100000.00 UNION ALL
 SELECT 'mg-hector-plus','Sharp Pro','PETROL','CVT',1451.00,141.00,7,2100000.00 UNION ALL
 SELECT 'mg-zs-ev','Excite Pro','ELECTRIC','AUTOMATIC',NULL,174.00,5,1900000.00 UNION ALL
 SELECT 'mg-gloster','Desertstorm','DIESEL','AUTOMATIC',1996.00,212.00,7,4000000.00 UNION ALL
 SELECT 'mg-majestor','Sharp','DIESEL','AUTOMATIC',1996.00,215.00,7,4500000.00
) x ON m.slug=x.slug
WHERE NOT EXISTS (SELECT 1 FROM car_variants v WHERE v.model_id=m.id AND v.variant_name=x.variant_name);

COMMIT;

-- =========================
-- VERIFICATION
-- =========================
SELECT b.name AS brand, COUNT(m.id) AS model_count
FROM car_brands b LEFT JOIN car_models m ON m.brand_id=b.id AND m.deleted_at IS NULL
WHERE b.slug IN ('maruti-suzuki','hyundai','tata-motors','honda','toyota','mahindra','kia','skoda','ford','volkswagen','mg')
GROUP BY b.id,b.name ORDER BY b.name;

SELECT b.name AS brand,m.name AS model,COUNT(v.id) AS variant_count
FROM car_brands b JOIN car_models m ON m.brand_id=b.id LEFT JOIN car_variants v ON v.model_id=m.id AND v.deleted_at IS NULL
WHERE b.slug IN ('toyota','mahindra','kia','skoda','ford','volkswagen','mg') AND m.deleted_at IS NULL
GROUP BY b.name,m.id,m.name ORDER BY b.name,m.name;

SELECT b.name AS brand,m.id AS model_id,m.name AS model,m.slug
FROM car_brands b JOIN car_models m ON m.brand_id=b.id
WHERE b.is_active=1 AND m.is_active=1 AND m.deleted_at IS NULL
ORDER BY b.name,m.name;

SELECT b.name AS brand,m.name AS model,v.id AS variant_id,v.variant_name,v.fuel_type,v.transmission
FROM car_brands b JOIN car_models m ON m.brand_id=b.id
JOIN car_variants v ON v.model_id=m.id
WHERE b.slug='tata-motors' AND m.deleted_at IS NULL AND v.deleted_at IS NULL
ORDER BY m.name,v.id;

SELECT m.id,b.name AS brand,m.name AS model,v.id AS variant_id,v.variant_name
FROM car_models m JOIN car_brands b ON b.id=m.brand_id
LEFT JOIN car_variants v ON v.model_id=m.id
WHERE m.slug='tata-sierra'
ORDER BY v.id;
