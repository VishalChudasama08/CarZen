import pymysql

conn = pymysql.connect(
    host="localhost",
    user="root",
    password="vishal08",
    database="carzen_v4_test_isolated",
    port=3306,
    autocommit=True
)

with conn.cursor() as cur:
    # 1. Brands
    brands = [
        (2, 'Hyundai', 'hyundai', 'South Korea', 'https://upload.wikimedia.org/wikipedia/commons/4/44/Hyundai_Motor_Company_logo.svg', 'Leading global automaker.'),
        (3, 'Honda', 'honda', 'Japan', 'https://upload.wikimedia.org/wikipedia/commons/7/76/Honda_logo.svg', 'Renowned for reliable cars and engines.'),
        (4, 'Tata', 'tata', 'India', 'https://upload.wikimedia.org/wikipedia/commons/8/8e/Tata_logo.svg', 'Pioneering Indian automotive giant.')
    ]
    for b in brands:
        cur.execute("INSERT IGNORE INTO car_brands (id, name, slug, country, logo_url, description, is_active, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, 1, NOW(), NOW())", b)

    # 2. Models
    models = [
        (2, 2, 'Creta', 'hyundai-creta', 'SUV', 5, 'Popular compact SUV.'),
        (3, 3, 'City', 'honda-city', 'Sedan', 5, 'Flagship executive sedan.'),
        (4, 4, 'Harrier', 'tata-harrier', 'SUV', 5, 'Flagship premium SUV.')
    ]
    for m in models:
        cur.execute("INSERT IGNORE INTO car_models (id, brand_id, name, slug, body_type, seating_capacity, description, is_active, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, 1, NOW(), NOW())", m)

    # 3. Variants
    variants = [
        (2, 2, 'SX (O) AT', 'Petrol', 'Automatic', 1497, 113, 5, 1750000.00),
        (3, 3, 'ZX CVT', 'Petrol', 'Automatic', 1498, 119, 5, 1600000.00),
        (4, 4, 'Fearless Plus Dark AT', 'Diesel', 'Automatic', 1956, 168, 5, 2600000.00)
    ]
    for v in variants:
        cur.execute("INSERT IGNORE INTO car_variants (id, model_id, variant_name, fuel_type, transmission, engine_cc, horsepower, seating_capacity, ex_showroom_price, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())", v)

    # 4. Cars (owner_id = 1)
    cars = [
        (1, 1, 1, 'GJ01AB1234', 'VIN12345678901', 2023, 2023, 'Diesel', 'Automatic', 3346, 304, 12500, 'White', 7, 1, 'First', 'Used', 'Ahmedabad', 'Gujarat', 'India', '380015', 'Flawless Toyota Land Cruiser LC300 ZX.', 21000000.00, 1, 'APPROVED'),
        (2, 2, 1, 'GJ01CD5678', 'VIN23456789012', 2022, 2022, 'Petrol', 'Automatic', 1497, 113, 24000, 'Phantom Black', 5, 1, 'First', 'Used', 'Ahmedabad', 'Gujarat', 'India', '380015', 'Single owner Creta SX (O) with sunroof.', 1550000.00, 1, 'APPROVED'),
        (3, 3, 1, 'GJ01EF9012', 'VIN34567890123', 2023, 2023, 'Petrol', 'Automatic', 1498, 119, 15000, 'Platinum White', 5, 1, 'First', 'Used', 'Surat', 'Gujarat', 'India', '395001', 'Honda City top model with full service record.', 1420000.00, 1, 'APPROVED'),
        (4, 4, 1, 'GJ01GH3456', 'VIN45678901234', 2024, 2024, 'Diesel', 'Automatic', 1956, 168, 8500, 'Oberon Black', 5, 1, 'First', 'Used', 'Vadodara', 'Gujarat', 'India', '390001', 'Tata Harrier dark edition almost new.', 2380000.00, 1, 'APPROVED')
    ]
    for c in cars:
        cur.execute("""INSERT IGNORE INTO cars 
            (id, variant_id, owner_id, registration_number, vin_number, manufacturing_year, registration_year, 
             fuel_type, transmission, engine_cc, horsepower, mileage_km, color, seating_capacity, owner_count, 
             ownership_type, `condition`, city, state, country, postal_code, description, expected_market_price, 
             is_verified, approval_status, created_at, updated_at) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())""", c)

    # 5. Listings
    listings = [
        (1, 1, 1, 'SALE', '2023 Toyota Land Cruiser LC300 ZX', 'Showroom condition LC300 available for immediate delivery.', 21000000.00, 1, 'ACTIVE', 120),
        (2, 2, 1, 'SALE', '2022 Hyundai Creta SX (O) Automatic', 'Top condition Creta with ventilated seats and panoramic sunroof.', 1550000.00, 1, 'ACTIVE', 85),
        (3, 3, 1, 'SALE', '2023 Honda City ZX CVT Petrol', 'Well maintained executive sedan with full insurance.', 1420000.00, 1, 'ACTIVE', 64),
        (4, 4, 1, 'SALE', '2024 Tata Harrier Fearless Plus Dark', 'Top spec Harrier with JBL audio and ADAS package.', 2380000.00, 1, 'ACTIVE', 92)
    ]
    for l in listings:
        cur.execute("""INSERT IGNORE INTO listings 
            (id, car_id, seller_id, listing_type, title, description, asking_price, negotiable, listing_status, views_count, listed_at, created_at, updated_at) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW(), NOW())""", l)

    # 6. Car Media
    media = [
        (1, 1, 'image', 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?auto=format&fit=crop&w=1200&q=80', 1, 1),
        (2, 2, 'image', 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80', 1, 1),
        (3, 3, 'image', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1200&q=80', 1, 1),
        (4, 4, 'image', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80', 1, 1)
    ]
    for m in media:
        cur.execute("INSERT IGNORE INTO car_media (id, car_id, media_type, media_url, sort_order, is_primary, created_at) VALUES (%s, %s, %s, %s, %s, %s, NOW())", m)

    # 7. Services
    services = [
        (1, 'General Periodic Service', 'Complete engine oil change, oil filter replacement, 40-point vehicle inspection, fluid top-ups and basic cleaning.', 2499.00, 120, 'ACTIVE'),
        (2, 'Comprehensive Brake Overhaul', 'Inspection and replacement of front & rear brake pads, disc rotor resurfacing, brake fluid flush and calibration.', 3200.00, 90, 'ACTIVE'),
        (3, 'AC Deep Clean & Gas Recharge', 'Complete evaporator cleaning, AC filter replacement, condenser wash and high-grade R134a refrigerant recharge.', 1850.00, 75, 'ACTIVE'),
        (4, 'Complete Wheel Balancing & Alignment', '3D computerized wheel alignment, high precision dynamic balancing with weights, and tire rotation.', 899.00, 45, 'ACTIVE')
    ]
    for s in services:
        cur.execute("INSERT INTO services (id, name, description, price, duration_minutes, status, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW()) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), price=VALUES(price)", s)

print("Demo marketplace listings, media, and services seeded successfully into carzen_v4_test_isolated!")
conn.close()
