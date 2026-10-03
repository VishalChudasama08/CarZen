-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: carzen_db_v3
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `address_line_1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line_2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `landmark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_addresses_id` (`id`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (101,101,'12, Shreeji Apartments','Satellite Road','Near Iscon Cross Roads','Ahmedabad','Gujarat','India','380015',NULL,NULL,1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,101,'48, Orchid Villas','Bopal','Behind Shilp Circle','Ahmedabad','Gujarat','India','380058',NULL,NULL,0,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,102,'7, Sunrise Residency','Adajan','Opposite Reliance Mall','Surat','Gujarat','India','395009',NULL,NULL,1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alembic_version`
--

LOCK TABLES `alembic_version` WRITE;
/*!40000 ALTER TABLE `alembic_version` DISABLE KEYS */;
INSERT INTO `alembic_version` VALUES ('3e8d8588f13c');
/*!40000 ALTER TABLE `alembic_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_brands`
--

DROP TABLE IF EXISTS `car_brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_brands` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `ix_car_brands_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_brands`
--

LOCK TABLES `car_brands` WRITE;
/*!40000 ALTER TABLE `car_brands` DISABLE KEYS */;
INSERT INTO `car_brands` VALUES (101,'Maruti Suzuki','maruti-suzuki','India',NULL,'India\'s largest carmaker, known for efficient and affordable hatchbacks, sedans and SUVs.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,'Hyundai','hyundai','South Korea',NULL,'South Korean manufacturer with a strong lineup of SUVs, sedans and hatchbacks in India.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,'Tata Motors','tata-motors','India',NULL,'Indian manufacturer offering safe, feature-rich SUVs and electric vehicles.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(104,'Honda','honda','Japan',NULL,'Japanese manufacturer known for refined engines and reliable sedans.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,'Toyota','toyota','Japan',NULL,'Japanese automobile manufacturer with a broad India passenger-vehicle range.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(106,'Mahindra','mahindra','India',NULL,'Indian manufacturer known for SUVs, utility vehicles and electric vehicles.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(107,'Kia','kia','South Korea',NULL,'South Korean automobile manufacturer with SUVs, MPVs and electric vehicles in India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(108,'Skoda','skoda','Czech Republic',NULL,'Czech automobile manufacturer offering sedans and SUVs in India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(109,'Ford','ford','United States',NULL,'American automobile manufacturer; India catalogue retained for historical and used-car listings.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(110,'Volkswagen','volkswagen','Germany',NULL,'German automobile manufacturer offering sedans, SUVs and performance models in India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(111,'MG','mg','United Kingdom',NULL,'MG brand offering feature-rich SUVs, EVs and MPVs in India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL);
/*!40000 ALTER TABLE `car_brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_features`
--

DROP TABLE IF EXISTS `car_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_features` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint NOT NULL,
  `feature_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `feature_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_car_features_id` (`id`),
  CONSTRAINT `car_features_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_features`
--

LOCK TABLES `car_features` WRITE;
/*!40000 ALTER TABLE `car_features` DISABLE KEYS */;
INSERT INTO `car_features` VALUES (101,101,'Touchscreen Infotainment','7-inch with Android Auto and Apple CarPlay','2026-09-28 10:00:00'),(102,101,'Airbags','Dual front airbags with ABS','2026-09-28 10:00:00'),(103,102,'Sunroof','Panoramic sunroof','2026-09-28 10:00:00'),(104,102,'Safety','6 airbags, ESC, hill assist','2026-09-28 10:00:00'),(105,102,'Climate Control','Dual-zone automatic AC','2026-09-28 10:00:00'),(106,103,'Safety','6 airbags, 5-star crash rating','2026-09-28 10:00:00'),(107,103,'Connectivity','10.25-inch touchscreen with wireless Android Auto','2026-09-28 10:00:00'),(108,104,'Transmission','CVT with paddle shifters','2026-09-28 10:00:00'),(109,104,'Comfort','Leather seats, rear AC vents','2026-09-28 10:00:00'),(110,105,'Parking','Rear camera with sensors','2026-09-28 10:00:00'),(111,106,'Battery','30.2 kWh, 8-year battery warranty','2026-09-28 10:00:00'),(112,106,'Charging','DC fast-charging capable, home charger included','2026-09-28 10:00:00');
/*!40000 ALTER TABLE `car_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_media`
--

DROP TABLE IF EXISTS `car_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_media` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint NOT NULL,
  `media_type` enum('IMAGE','VIDEO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `media_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_car_media_id` (`id`),
  CONSTRAINT `car_media_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_media`
--

LOCK TABLES `car_media` WRITE;
/*!40000 ALTER TABLE `car_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `car_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_models`
--

DROP TABLE IF EXISTS `car_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_models` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `brand_id` bigint NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body_type` enum('HATCHBACK','SEDAN','SUV','MUV','MPV','COUPE','CONVERTIBLE','PICKUP','MINIVAN','OTHER') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seating_capacity` int DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `brand_id` (`brand_id`),
  KEY `ix_car_models_id` (`id`),
  CONSTRAINT `car_models_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `car_brands` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=210 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_models`
--

LOCK TABLES `car_models` WRITE;
/*!40000 ALTER TABLE `car_models` DISABLE KEYS */;
INSERT INTO `car_models` VALUES (101,101,'Swift','maruti-swift','HATCHBACK',5,'A sporty, fuel-efficient hatchback that is a favourite for city driving.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,102,'Creta','hyundai-creta','SUV',5,'A comfortable and well-equipped compact SUV.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,103,'Nexon','tata-nexon','SUV',5,'A compact SUV with a five-star safety reputation, available as petrol and electric.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(104,104,'City','honda-city','SEDAN',5,'A spacious, refined mid-size sedan.',1,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,103,'Punch','tata-punch','SUV',5,'Compact SUV from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(106,103,'Harrier','tata-harrier','SUV',5,'Mid-size SUV from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(107,103,'Safari','tata-safari','SUV',6,'Three-row SUV from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(108,103,'Tiago','tata-tiago','HATCHBACK',5,'Compact hatchback from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(109,103,'Altroz','tata-altroz','HATCHBACK',5,'Premium hatchback from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(110,103,'Tigor','tata-tigor','SEDAN',5,'Compact sedan from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(111,103,'Sierra','tata-sierra','SUV',5,'SUV model from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(112,103,'Curvv','tata-curvv','SUV',5,'SUV coupe-style model from Tata Motors.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(120,104,'Amaze','honda-amaze','SEDAN',5,'Compact sedan from Honda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(121,104,'Elevate','honda-elevate','SUV',5,'Mid-size SUV from Honda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(122,104,'City Hatchback','honda-city-hatchback','HATCHBACK',5,'Hatchback model in the City family.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(123,102,'Venue','hyundai-venue','SUV',5,'Compact SUV from Hyundai.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(124,102,'i20','hyundai-i20','HATCHBACK',5,'Premium hatchback from Hyundai.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(125,102,'Verna','hyundai-verna','SEDAN',5,'Mid-size sedan from Hyundai.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(126,102,'Tucson','hyundai-tucson','SUV',5,'Premium SUV from Hyundai.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(127,102,'Alcazar','hyundai-alcazar','SUV',7,'Three-row SUV from Hyundai.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(130,101,'Baleno','maruti-baleno','HATCHBACK',5,'Premium hatchback from Maruti Suzuki.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(131,101,'Dzire','maruti-dzire','SEDAN',5,'Compact sedan from Maruti Suzuki.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(132,101,'Brezza','maruti-brezza','SUV',5,'Compact SUV from Maruti Suzuki.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(133,101,'Fronx','maruti-fronx','SUV',5,'Compact crossover SUV from Maruti Suzuki.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(134,101,'Grand Vitara','maruti-grand-vitara','SUV',5,'SUV from Maruti Suzuki.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(137,105,'Glanza','toyota-glanza','HATCHBACK',5,'Premium hatchback sold by Toyota in India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(138,105,'Urban Cruiser Taisor','toyota-urban-cruiser-taisor','SUV',5,'Compact crossover SUV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(139,105,'Rumion','toyota-rumion','MUV',7,'Seven-seat MPV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(140,105,'Urban Cruiser Hyryder','toyota-urban-cruiser-hyryder','SUV',5,'Mid-size SUV with petrol and strong-hybrid options.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(141,105,'Innova Crysta','toyota-innova-crysta','MUV',7,'Diesel MPV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(142,105,'Innova Hycross','toyota-innova-hycross','MUV',7,'Premium MPV with petrol and hybrid powertrains.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(143,105,'Fortuner','toyota-fortuner','SUV',7,'Body-on-frame SUV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(144,105,'Hilux','toyota-hilux','PICKUP',5,'Lifestyle pickup truck from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(145,105,'Camry','toyota-camry','SEDAN',5,'Premium hybrid sedan from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(146,105,'Vellfire','toyota-vellfire','MUV',7,'Luxury MPV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(147,105,'Land Cruiser 300','toyota-land-cruiser-300','SUV',5,'Premium full-size SUV from Toyota.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(152,106,'XUV 3XO','mahindra-xuv-3xo','SUV',5,'Compact SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(153,106,'Thar','mahindra-thar','SUV',4,'Lifestyle off-road SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(154,106,'Thar Roxx','mahindra-thar-roxx','SUV',5,'Five-door lifestyle SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(155,106,'Bolero','mahindra-bolero','SUV',7,'Rugged utility SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(156,106,'Bolero Neo','mahindra-bolero-neo','SUV',7,'Compact body-on-frame SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(157,106,'Scorpio Classic','mahindra-scorpio-classic','SUV',7,'Rugged seven-seat SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(158,106,'Scorpio-N','mahindra-scorpio-n','SUV',7,'Modern body-on-frame SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(159,106,'XUV700','mahindra-xuv700','SUV',7,'Premium family SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(160,106,'XUV400','mahindra-xuv400','SUV',5,'Electric SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(161,106,'BE 6','mahindra-be-6','SUV',5,'Electric SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(162,106,'XEV 9e','mahindra-xev-9e','SUV',5,'Premium electric SUV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(163,106,'Marazzo','mahindra-marazzo','MUV',7,'Seven-seat MPV from Mahindra.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(167,107,'Sonet','kia-sonet','SUV',5,'Compact SUV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(168,107,'Seltos','kia-seltos','SUV',5,'Mid-size SUV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(169,107,'Carens','kia-carens','MUV',7,'Three-row family MPV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(170,107,'Carens Clavis','kia-carens-clavis','MUV',7,'Updated three-row MPV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(171,107,'Carnival','kia-carnival','MUV',7,'Premium MPV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(172,107,'EV6','kia-ev6','SUV',5,'Premium electric crossover from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(173,107,'EV9','kia-ev9','SUV',6,'Large electric SUV from Kia.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(174,108,'Kylaq','skoda-kylaq','SUV',5,'Compact SUV from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(175,108,'Kushaq','skoda-kushaq','SUV',5,'Mid-size SUV from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(176,108,'Slavia','skoda-slavia','SEDAN',5,'Mid-size sedan from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(177,108,'Kodiaq','skoda-kodiaq','SUV',7,'Premium seven-seat SUV from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(178,108,'Octavia RS','skoda-octavia-rs','SEDAN',5,'Performance sedan from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(179,108,'Superb','skoda-superb','SEDAN',5,'Premium sedan from Skoda.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(181,109,'EcoSport','ford-ecosport','SUV',5,'Compact SUV formerly sold by Ford India; useful for used-car listings.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(182,109,'Endeavour','ford-endeavour','SUV',7,'Large SUV formerly sold by Ford India; useful for used-car listings.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(183,109,'Figo','ford-figo','HATCHBACK',5,'Hatchback formerly sold by Ford India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(184,109,'Aspire','ford-aspire','SEDAN',5,'Compact sedan formerly sold by Ford India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(185,109,'Freestyle','ford-freestyle','SUV',5,'Crossover hatchback formerly sold by Ford India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(186,109,'Fiesta','ford-fiesta','SEDAN',5,'Sedan formerly sold by Ford India.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(188,110,'Taigun','volkswagen-taigun','SUV',5,'Compact SUV from Volkswagen.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(189,110,'Virtus','volkswagen-virtus','SEDAN',5,'Mid-size sedan from Volkswagen.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(190,110,'Tiguan R-Line','volkswagen-tiguan-r-line','SUV',5,'Premium SUV from Volkswagen.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(191,110,'Tayron','volkswagen-tayron','SUV',5,'Premium SUV from Volkswagen.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(192,110,'Golf GTI','volkswagen-golf-gti','HATCHBACK',5,'Performance hatchback from Volkswagen.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(195,111,'Comet EV','mg-comet-ev','HATCHBACK',4,'Compact electric city car from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(196,111,'Windsor EV','mg-windsor-ev','HATCHBACK',5,'Electric crossover from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(197,111,'Astor','mg-astor','SUV',5,'Mid-size SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(198,111,'Hector','mg-hector','SUV',5,'Mid-size SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(199,111,'Hector Plus','mg-hector-plus','SUV',7,'Three-row SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(200,111,'ZS EV','mg-zs-ev','SUV',5,'Electric SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(201,111,'Gloster','mg-gloster','SUV',7,'Premium full-size SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(202,111,'Majestor','mg-majestor','SUV',7,'Premium large SUV from MG.',1,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL);
/*!40000 ALTER TABLE `car_models` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_variants`
--

DROP TABLE IF EXISTS `car_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_variants` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `model_id` bigint NOT NULL,
  `variant_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fuel_type` enum('PETROL','DIESEL','CNG','ELECTRIC','HYBRID') COLLATE utf8mb4_unicode_ci NOT NULL,
  `transmission` enum('MANUAL','AUTOMATIC','AMT','CVT','DCT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `engine_cc` decimal(8,2) DEFAULT NULL,
  `horsepower` decimal(8,2) DEFAULT NULL,
  `seating_capacity` int DEFAULT NULL,
  `ex_showroom_price` decimal(15,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `model_id` (`model_id`),
  KEY `ix_car_variants_id` (`id`),
  CONSTRAINT `car_variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `car_models` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_variants`
--

LOCK TABLES `car_variants` WRITE;
/*!40000 ALTER TABLE `car_variants` DISABLE KEYS */;
INSERT INTO `car_variants` VALUES (101,101,'VXi','PETROL','MANUAL',1197.00,82.00,5,749000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,101,'ZXi AMT','PETROL','AMT',1197.00,82.00,5,849000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,102,'SX Diesel','DIESEL','MANUAL',1493.00,113.00,5,1600000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(104,103,'XZ+ Petrol AMT','PETROL','AMT',1199.00,118.00,5,1050000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,104,'V CVT','PETROL','CVT',1498.00,119.00,5,1200000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(106,103,'EV Empowered','ELECTRIC','AUTOMATIC',NULL,143.00,5,1500000.00,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(107,111,'Pure','PETROL','MANUAL',1199.00,118.00,5,1100000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(108,111,'Adventure','PETROL','MANUAL',1199.00,118.00,5,1300000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(109,111,'Accomplished+','PETROL','DCT',1199.00,118.00,5,1600000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(110,105,'Pure','PETROL','MANUAL',1199.00,87.00,5,650000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(111,105,'Adventure AMT','PETROL','AMT',1199.00,87.00,5,800000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(112,105,'Creative+','PETROL','AMT',1199.00,87.00,5,950000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(113,106,'Pure','DIESEL','MANUAL',1956.00,168.00,5,1500000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(114,106,'Adventure+','DIESEL','AUTOMATIC',1956.00,168.00,5,2000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(116,107,'Pure','DIESEL','MANUAL',1956.00,168.00,6,1600000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(117,107,'Adventure+','DIESEL','AUTOMATIC',1956.00,168.00,6,2100000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(119,108,'XE','PETROL','MANUAL',1199.00,84.00,5,550000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(120,108,'XZA AMT','PETROL','AMT',1199.00,84.00,5,700000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(121,109,'Pure','PETROL','MANUAL',1199.00,84.00,5,700000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(122,109,'XZ+ Petrol DCA','PETROL','DCT',1199.00,84.00,5,950000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(123,110,'XE','PETROL','MANUAL',1199.00,84.00,5,600000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(124,110,'XZA+','PETROL','AMT',1199.00,84.00,5,750000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(126,112,'Pure+','PETROL','MANUAL',1199.00,118.00,5,1000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(127,112,'Creative+','PETROL','DCT',1199.00,118.00,5,1400000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(129,120,'S','PETROL','MANUAL',1199.00,89.00,5,800000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(130,120,'VX CVT','PETROL','CVT',1199.00,89.00,5,1000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(131,121,'SV','PETROL','MANUAL',1498.00,119.00,5,1200000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(132,121,'ZX CVT','PETROL','CVT',1498.00,119.00,5,1600000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(136,123,'S','PETROL','MANUAL',1197.00,81.00,5,800000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(137,123,'SX(O) DCT','PETROL','DCT',998.00,118.00,5,1300000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(138,124,'Sportz','PETROL','MANUAL',1197.00,87.00,5,750000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(139,124,'Asta(O) IVT','PETROL','CVT',1197.00,87.00,5,1000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(140,125,'EX','PETROL','MANUAL',1497.00,113.00,5,1100000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(141,125,'SX(O) DCT','PETROL','DCT',1482.00,158.00,5,1700000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(143,130,'Sigma','PETROL','MANUAL',1197.00,88.00,5,700000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(144,130,'Alpha AMT','PETROL','AMT',1197.00,88.00,5,950000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(145,131,'VXi','PETROL','MANUAL',1197.00,80.00,5,700000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(146,131,'ZXi AMT','PETROL','AMT',1197.00,80.00,5,850000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(147,132,'LXi','PETROL','MANUAL',1197.00,102.00,5,850000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(148,132,'ZXi AT','PETROL','AUTOMATIC',1197.00,102.00,5,1200000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(150,137,'G','PETROL','MANUAL',1197.00,88.00,5,750000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(151,137,'V AMT','PETROL','AMT',1197.00,88.00,5,950000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(152,138,'S','PETROL','MANUAL',1197.00,89.00,5,800000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(153,138,'V Turbo AT','PETROL','AUTOMATIC',998.00,99.00,5,1250000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(154,139,'G','PETROL','MANUAL',1462.00,101.00,7,1100000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(155,139,'V AT','PETROL','AUTOMATIC',1462.00,101.00,7,1350000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(156,140,'G Hybrid','HYBRID','AUTOMATIC',1490.00,114.00,5,1900000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(157,140,'S','PETROL','MANUAL',1462.00,103.00,5,1300000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(158,141,'GX','DIESEL','MANUAL',2393.00,148.00,7,2050000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(159,141,'ZX','DIESEL','AUTOMATIC',2393.00,148.00,7,2750000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(160,142,'GX','PETROL','AUTOMATIC',1987.00,172.00,7,2000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(161,142,'ZX Hybrid','HYBRID','AUTOMATIC',1987.00,184.00,7,3000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(162,143,'4x2 Diesel MT','DIESEL','MANUAL',2755.00,201.00,7,3400000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(163,143,'4x4 Diesel AT','DIESEL','AUTOMATIC',2755.00,201.00,7,4200000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(164,144,'Standard','DIESEL','MANUAL',2755.00,201.00,5,3200000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(165,144,'High AT','DIESEL','AUTOMATIC',2755.00,201.00,5,3650000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(166,145,'Hybrid','HYBRID','AUTOMATIC',2487.00,227.00,5,4900000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(167,146,'VIP','HYBRID','AUTOMATIC',2487.00,190.00,7,12000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL),(168,147,'ZX','DIESEL','AUTOMATIC',3346.00,304.00,5,22000000.00,'2026-10-03 12:55:32','2026-10-03 12:55:32',NULL);
/*!40000 ALTER TABLE `car_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cars`
--

DROP TABLE IF EXISTS `cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cars` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `variant_id` bigint NOT NULL,
  `owner_id` bigint NOT NULL,
  `registration_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vin_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacturing_year` int NOT NULL,
  `registration_year` int DEFAULT NULL,
  `fuel_type` enum('PETROL','DIESEL','CNG','ELECTRIC','HYBRID') COLLATE utf8mb4_unicode_ci NOT NULL,
  `transmission` enum('MANUAL','AUTOMATIC','AMT','CVT','DCT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `engine_cc` decimal(8,2) DEFAULT NULL,
  `horsepower` decimal(8,2) DEFAULT NULL,
  `mileage_km` decimal(12,2) NOT NULL,
  `color` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seating_capacity` int DEFAULT NULL,
  `owner_count` int DEFAULT NULL,
  `ownership_type` enum('FIRST_OWNER','SECOND_OWNER','THIRD_OWNER','FOURTH_OR_MORE') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `condition` enum('EXCELLENT','GOOD','FAIR','POOR','NEW','OLD') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_company` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_expiry` date DEFAULT NULL,
  `rc_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `expected_market_price` decimal(15,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT NULL,
  `approval_status` enum('draft','pending_approval','approved','rejected','published','sold','inactive') COLLATE utf8mb4_unicode_ci NOT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `verified_at` datetime DEFAULT NULL,
  `verified_by_id` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `registration_number` (`registration_number`),
  UNIQUE KEY `vin_number` (`vin_number`),
  KEY `variant_id` (`variant_id`),
  KEY `owner_id` (`owner_id`),
  KEY `verified_by_id` (`verified_by_id`),
  KEY `ix_cars_id` (`id`),
  CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `car_variants` (`id`),
  CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`),
  CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`verified_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
INSERT INTO `cars` VALUES (101,101,102,'GJ01DM1101','DEMOVIN00000101',2021,2021,'PETROL','MANUAL',1197.00,82.00,34500.00,'Pearl White',5,1,'FIRST_OWNER','EXCELLENT','ICICI Lombard','comprehensive','2027-03-14','valid','Ahmedabad','Gujarat','India','380015','Single-owner Swift, regularly serviced at the authorised workshop. Clean interior, no accident history.',560000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,103,102,'GJ05DM1102','DEMOVIN00000102',2020,2020,'DIESEL','MANUAL',1493.00,113.00,58200.00,'Phantom Grey',5,1,'FIRST_OWNER','GOOD','HDFC Ergo','comprehensive','2027-01-22','valid','Surat','Gujarat','India','395009','Well-kept Creta SX diesel with panoramic sunroof, full service records and new tyres.',1250000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,104,102,'GJ06DM1103','DEMOVIN00000103',2022,2022,'PETROL','AMT',1199.00,118.00,21000.00,'Daytona Grey',5,1,'FIRST_OWNER','EXCELLENT','Tata AIG','comprehensive','2027-06-30','valid','Vadodara','Gujarat','India','390007','Nexon XZ+ with AMT. Under warranty, rear camera, touchscreen infotainment, six airbags.',890000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(104,105,102,'GJ03DM1104','DEMOVIN00000104',2019,2019,'PETROL','CVT',1498.00,119.00,47800.00,'Lunar Silver',5,2,'SECOND_OWNER','GOOD','Bajaj Allianz','comprehensive','2026-12-05','valid','Rajkot','Gujarat','India','360001','Smooth Honda City CVT. Second owner, always garaged, service done on time.',780000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,102,102,'GJ01DM1105','DEMOVIN00000105',2023,2023,'PETROL','AMT',1197.00,82.00,9800.00,'Fire Red',5,1,'FIRST_OWNER','EXCELLENT','New India Assurance','comprehensive','2027-09-10','valid','Ahmedabad','Gujarat','India','380054','Almost-new Swift ZXi AMT with under 10,000 km. Showroom condition.',760000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(106,106,102,'GJ01DM1106','DEMOVIN00000106',2022,2022,'ELECTRIC','AUTOMATIC',NULL,143.00,18400.00,'Teal Blue',5,1,'FIRST_OWNER','EXCELLENT','Tata AIG','comprehensive','2027-04-18','valid','Ahmedabad','Gujarat','India','380009','Nexon EV with 8-year battery warranty, home charger included, fast-charging capable.',1320000.00,1,'published',NULL,'2026-09-29 12:00:00',103,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(107,103,102,'GJ05DM1107','DEMOVIN00000107',2018,2018,'DIESEL','MANUAL',1493.00,113.00,86400.00,'Polar White',5,2,'SECOND_OWNER','FAIR','Oriental Insurance','third_party','2026-11-30','valid','Surat','Gujarat','India','395007','Creta diesel awaiting admin review - used to demonstrate the approval queue.',900000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(108,101,102,'GJ05DM1108','DEMOVIN00000108',2015,2015,'PETROL','MANUAL',1197.00,82.00,121000.00,'Silver',5,3,'THIRD_OWNER','FAIR','United India','third_party','2026-08-01','expired','Surat','Gujarat','India','395002','Older Swift - used to demonstrate a rejected submission.',230000.00,0,'rejected','Insurance has expired and the RC status could not be verified. Please update the documents and resubmit.',NULL,NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(109,105,101,'GJ01DM1109','DEMOVIN00000109',2020,2020,'PETROL','CVT',1498.00,119.00,39800.00,'Metallic Blue',5,1,'FIRST_OWNER','GOOD','HDFC Ergo','comprehensive','2027-02-12','valid','Ahmedabad','Gujarat','India','380015','Added for service booking.',NULL,0,'approved',NULL,NULL,NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(110,101,101,'GJ01DM1110','DEMOVIN00000110',2018,2018,'PETROL','MANUAL',1197.00,82.00,52300.00,'Red',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-05-01','valid','Ahmedabad','Gujarat','India','380015','Added for service booking.',NULL,0,'approved',NULL,NULL,NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL);
/*!40000 ALTER TABLE `cars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contacts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `address_id` bigint NOT NULL,
  `whatsapp_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferred_contact_method` enum('PHONE','EMAIL','WHATSAPP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_visibility` enum('PUBLIC','BUYERS_ONLY','PRIVATE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_visible` tinyint(1) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_contacts_user_id` (`user_id`),
  KEY `ix_contacts_address_id` (`address_id`),
  KEY `ix_contacts_id` (`id`),
  CONSTRAINT `contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `contacts_ibfk_2` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `car_id` bigint NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_favorites_user_car` (`user_id`,`car_id`),
  KEY `car_id` (`car_id`),
  KEY `ix_favorites_id` (`id`),
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (101,101,101,'2026-09-28 10:00:00'),(102,101,103,'2026-09-28 10:00:00');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inquiries`
--

DROP TABLE IF EXISTS `inquiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inquiries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` bigint NOT NULL,
  `buyer_id` bigint NOT NULL,
  `seller_id` bigint NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('OPEN','CONTACTED','CLOSED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_inquiries_id` (`id`),
  CONSTRAINT `inquiries_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `inquiries_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `inquiries_ibfk_3` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiries`
--

LOCK TABLES `inquiries` WRITE;
/*!40000 ALTER TABLE `inquiries` DISABLE KEYS */;
INSERT INTO `inquiries` VALUES (101,102,101,102,'Service history of the Creta','Hi, do you have the service records for the last three years? Also, is the sunroof working smoothly?','CONTACTED','2026-09-29 20:00:00','2026-09-30 07:45:00'),(102,103,101,102,'Nexon warranty','Is the manufacturer warranty transferable to a new owner?','OPEN','2026-09-30 10:30:00','2026-09-30 10:30:00');
/*!40000 ALTER TABLE `inquiries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inquiry_messages`
--

DROP TABLE IF EXISTS `inquiry_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inquiry_messages` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `inquiry_id` bigint NOT NULL,
  `sender_id` bigint NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `inquiry_id` (`inquiry_id`),
  KEY `sender_id` (`sender_id`),
  KEY `ix_inquiry_messages_id` (`id`),
  CONSTRAINT `inquiry_messages_ibfk_1` FOREIGN KEY (`inquiry_id`) REFERENCES `inquiries` (`id`),
  CONSTRAINT `inquiry_messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry_messages`
--

LOCK TABLES `inquiry_messages` WRITE;
/*!40000 ALTER TABLE `inquiry_messages` DISABLE KEYS */;
INSERT INTO `inquiry_messages` VALUES (101,101,101,'Hi, do you have the service records for the last three years? Also, is the sunroof working smoothly?','2026-09-29 20:00:00'),(102,101,102,'Hello Riya! Yes, all records are with the authorised workshop and I can share copies. The sunroof works perfectly.','2026-09-30 07:30:00'),(103,101,101,'Great, thank you. I will send a purchase request shortly.','2026-09-30 07:45:00'),(104,102,101,'Is the manufacturer warranty transferable to a new owner?','2026-09-30 10:30:00');
/*!40000 ALTER TABLE `inquiry_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listing_views`
--

DROP TABLE IF EXISTS `listing_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `listing_views` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` bigint NOT NULL,
  `buyer_id` bigint NOT NULL,
  `viewed_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_listing_views_listing_buyer` (`listing_id`,`buyer_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `ix_listing_views_id` (`id`),
  CONSTRAINT `listing_views_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `listing_views_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listing_views`
--

LOCK TABLES `listing_views` WRITE;
/*!40000 ALTER TABLE `listing_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `listing_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listings`
--

DROP TABLE IF EXISTS `listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `listings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint NOT NULL,
  `seller_id` bigint NOT NULL,
  `listing_type` enum('SALE','RESALE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `asking_price` decimal(15,2) NOT NULL,
  `negotiable` tinyint(1) DEFAULT NULL,
  `listing_status` enum('DRAFT','PENDING_REVIEW','APPROVED','REJECTED','ACTIVE','RESERVED','SOLD','EXPIRED','CANCELLED','REMOVED','SUSPENDED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `listed_at` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `views_count` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_listings_id` (`id`),
  CONSTRAINT `listings_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `listings_ibfk_2` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
INSERT INTO `listings` VALUES (101,101,102,'SALE','2021 Maruti Suzuki Swift VXi - Single owner, 34,500 km','Single-owner Swift in excellent condition with full service history. Ready to drive away.',560000.00,1,'ACTIVE','2026-09-29 12:30:00','2027-03-31 23:59:59',19,'2026-09-28 10:00:00','2026-10-03 06:45:43',NULL),(102,102,102,'SALE','2020 Hyundai Creta SX Diesel - Sunroof, full service records','Well-maintained Creta diesel with panoramic sunroof, new tyres and complete service records.',1250000.00,1,'ACTIVE','2026-09-29 12:35:00','2027-03-31 23:59:59',18,'2026-09-28 10:00:00','2026-10-03 06:45:43',NULL),(103,103,102,'SALE','2022 Tata Nexon XZ+ AMT - 21,000 km, under warranty','Nexon XZ+ with AMT, still under manufacturer warranty. Six airbags and a five-star safety rating.',890000.00,1,'ACTIVE','2026-09-29 12:40:00','2027-03-31 23:59:59',26,'2026-09-28 10:00:00','2026-10-03 06:45:43',NULL),(104,104,102,'RESALE','2019 Honda City V CVT - Second owner, garage kept','Smooth CVT City, second owner, garage kept and serviced on time.',780000.00,1,'RESERVED','2026-09-29 12:45:00','2027-03-31 23:59:59',0,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,105,102,'SALE','2023 Maruti Suzuki Swift ZXi AMT - Under 10,000 km','Showroom-condition Swift ZXi AMT with under 10,000 km on the clock.',760000.00,0,'ACTIVE','2026-09-29 12:50:00','2027-03-31 23:59:59',19,'2026-09-28 10:00:00','2026-10-03 06:45:43',NULL),(106,106,102,'SALE','2022 Tata Nexon EV Empowered - Home charger included','Nexon EV with an 8-year battery warranty and home charger included.',1320000.00,1,'ACTIVE','2026-09-29 12:55:00','2027-03-31 23:59:59',24,'2026-09-28 10:00:00','2026-10-03 06:45:43',NULL);
/*!40000 ALTER TABLE `listings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `reference_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_notifications_id` (`id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (101,103,'Car awaiting approval','A newly submitted car is waiting for admin approval.','admin',107,'car',0,'2026-09-29 11:00:00'),(102,103,'New service request','Riya Patel requested Full Car Servicing for 08 Oct 2026.','system',101,'service_request',0,'2026-09-30 09:00:00'),(103,102,'New order received','A buyer placed an order for 2021 Maruti Suzuki Swift VXi.','order',101,'order',0,'2026-09-30 09:10:00'),(104,102,'New enquiry','Riya Patel asked a question about the Nexon XZ+.','inquiry',102,'inquiry',0,'2026-09-30 10:30:00'),(105,102,'Car rejected','Your Swift submission was rejected. Please check the reason and resubmit.','listing',108,'car',1,'2026-09-29 11:30:00'),(106,101,'Service Request Submitted','Your request for \'Full Car Servicing\' on 2026-10-08 at 10:00:00 has been submitted.','system',101,'service_request',0,'2026-09-28 11:00:00'),(107,101,'Service request accepted','Your service request #102 has been accepted.','system',102,'service_request',0,'2026-09-29 10:00:00'),(108,101,'Service scheduled','Your service request #103 is scheduled for 2026-10-15 at 14:00.','system',103,'service_request',0,'2026-09-30 11:00:00'),(109,101,'Service completed','Your service request #105 has been completed.','system',105,'service_request',1,'2026-09-18 16:35:00'),(110,101,'Order confirmed','The seller confirmed your order for 2019 Honda City V CVT.','order',102,'order',0,'2026-09-30 08:05:00'),(111,101,'New reply from the seller','Arjun replied to your enquiry about the Creta.','inquiry',101,'inquiry',0,'2026-09-30 07:30:00');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` bigint NOT NULL,
  `car_id` bigint NOT NULL,
  `buyer_id` bigint NOT NULL,
  `seller_id` bigint NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` enum('PENDING','CONFIRMED','PROCESSING','COMPLETED','CANCELLED','REJECTED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED','UNPAID') COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `car_id` (`car_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_orders_id` (`id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (101,101,101,101,102,550000.00,'PENDING','UNPAID','Interested - can I see the car this weekend?','2026-09-30 09:10:00','2026-09-30 09:10:00',NULL),(102,104,104,101,102,775000.00,'CONFIRMED','UNPAID','Please keep it reserved until Saturday.','2026-09-29 18:20:00','2026-09-30 08:05:00',NULL),(103,105,105,101,102,740000.00,'CANCELLED','UNPAID','Changed my mind, thanks.','2026-09-28 15:00:00','2026-09-28 16:30:00',NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `service_request_id` bigint DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','processing','success','failed','cancelled','refunded') COLLATE utf8mb4_unicode_ci NOT NULL,
  `razorpay_order_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `razorpay_payment_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `razorpay_signature` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_payments_razorpay_payment_id` (`razorpay_payment_id`),
  UNIQUE KEY `ix_payments_razorpay_order_id` (`razorpay_order_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `ix_payments_order_id` (`order_id`),
  KEY `ix_payments_service_request_id` (`service_request_id`),
  KEY `ix_payments_user_id` (`user_id`),
  KEY `ix_payments_id` (`id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prediction_features`
--

DROP TABLE IF EXISTS `prediction_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prediction_features` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `prediction_id` bigint NOT NULL,
  `feature_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `feature_value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prediction_id` (`prediction_id`),
  KEY `ix_prediction_features_id` (`id`),
  CONSTRAINT `prediction_features_ibfk_1` FOREIGN KEY (`prediction_id`) REFERENCES `price_predictions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prediction_features`
--

LOCK TABLES `prediction_features` WRITE;
/*!40000 ALTER TABLE `prediction_features` DISABLE KEYS */;
/*!40000 ALTER TABLE `prediction_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_predictions`
--

DROP TABLE IF EXISTS `price_predictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price_predictions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  `prediction_status` enum('REQUESTED','COMPLETED','FAILED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `predicted_price` decimal(15,2) DEFAULT NULL,
  `minimum_price` decimal(15,2) DEFAULT NULL,
  `maximum_price` decimal(15,2) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `model_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model_version` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `prediction_input` json DEFAULT NULL,
  `prediction_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `user_id` (`user_id`),
  KEY `ix_price_predictions_id` (`id`),
  CONSTRAINT `price_predictions_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `price_predictions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_predictions`
--

LOCK TABLES `price_predictions` WRITE;
/*!40000 ALTER TABLE `price_predictions` DISABLE KEYS */;
/*!40000 ALTER TABLE `price_predictions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `reporter_id` bigint NOT NULL,
  `listing_id` bigint DEFAULT NULL,
  `car_id` bigint DEFAULT NULL,
  `reason` enum('fake_listing','wrong_information','fraud','duplicate_listing','suspicious_seller','inappropriate_content','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','under_review','resolved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `resolved_by_id` bigint DEFAULT NULL,
  `admin_note` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `reporter_id` (`reporter_id`),
  KEY `listing_id` (`listing_id`),
  KEY `car_id` (`car_id`),
  KEY `resolved_by_id` (`resolved_by_id`),
  KEY `ix_reports_id` (`id`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `reports_ibfk_4` FOREIGN KEY (`resolved_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `car_id` bigint DEFAULT NULL,
  `listing_id` bigint DEFAULT NULL,
  `transaction_id` bigint DEFAULT NULL,
  `rating` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `review_text` text COLLATE utf8mb4_unicode_ci,
  `is_visible` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `car_id` (`car_id`),
  KEY `listing_id` (`listing_id`),
  KEY `ix_reviews_transaction_id` (`transaction_id`),
  KEY `ix_reviews_id` (`id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `reviews_ibfk_4` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_items`
--

DROP TABLE IF EXISTS `service_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `service_record_id` bigint NOT NULL,
  `item_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int DEFAULT NULL,
  `unit_cost` decimal(15,2) DEFAULT NULL,
  `total_cost` decimal(15,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_record_id` (`service_record_id`),
  KEY `ix_service_items_id` (`id`),
  CONSTRAINT `service_items_ibfk_1` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_items`
--

LOCK TABLES `service_items` WRITE;
/*!40000 ALTER TABLE `service_items` DISABLE KEYS */;
INSERT INTO `service_items` VALUES (101,101,'Engine oil (3.5 L)',1,1200.00,1200.00,'2026-09-18 16:30:00'),(102,101,'Oil filter',1,350.00,350.00,'2026-09-18 16:30:00'),(103,101,'Air filter',1,550.00,550.00,'2026-09-18 16:30:00'),(104,102,'Synthetic engine oil (3.5 L)',1,900.00,900.00,'2026-06-10 12:00:00');
/*!40000 ALTER TABLE `service_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_records`
--

DROP TABLE IF EXISTS `service_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint NOT NULL,
  `service_center_id` bigint DEFAULT NULL,
  `service_type` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_date` date NOT NULL,
  `odometer_reading` decimal(12,2) DEFAULT NULL,
  `service_cost` decimal(15,2) DEFAULT NULL,
  `parts_cost` decimal(15,2) DEFAULT NULL,
  `labor_cost` decimal(15,2) DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `next_service_date` date DEFAULT NULL,
  `next_service_mileage` decimal(12,2) DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_service_records_id` (`id`),
  CONSTRAINT `service_records_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_records`
--

LOCK TABLES `service_records` WRITE;
/*!40000 ALTER TABLE `service_records` DISABLE KEYS */;
INSERT INTO `service_records` VALUES (101,110,NULL,'Full Car Servicing','2026-09-18',52300.00,4999.00,2100.00,2899.00,'Full service completed. Engine oil, oil filter and air filter replaced; brakes inspected; no issues found.','2027-03-18',62300.00,'completed','2026-09-18 16:30:00','2026-09-18 16:30:00'),(102,109,NULL,'Oil & Filter Change','2026-06-10',37400.00,1799.00,900.00,899.00,'Synthetic oil and filter replaced.','2026-12-10',42400.00,'completed','2026-06-10 12:00:00','2026-06-10 12:00:00');
/*!40000 ALTER TABLE `service_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_request_items`
--

DROP TABLE IF EXISTS `service_request_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_request_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `service_request_id` bigint NOT NULL,
  `service_id` bigint DEFAULT NULL,
  `service_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `duration_minutes` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_service_request_items_id` (`id`),
  KEY `ix_service_request_items_service_request_id` (`service_request_id`),
  KEY `ix_service_request_items_service_id` (`service_id`),
  CONSTRAINT `service_request_items_ibfk_1` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_request_items_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_request_items`
--

LOCK TABLES `service_request_items` WRITE;
/*!40000 ALTER TABLE `service_request_items` DISABLE KEYS */;
INSERT INTO `service_request_items` VALUES (101,101,101,'Full Car Servicing',4999.00,180,'2026-09-28 11:00:00'),(102,102,102,'Oil & Filter Change',1799.00,45,'2026-09-28 11:00:00'),(103,102,104,'Wheel Alignment & Balancing',1299.00,60,'2026-09-28 11:00:00'),(104,103,103,'Brake Pad Replacement',2599.00,90,'2026-09-28 11:00:00'),(105,103,104,'Wheel Alignment & Balancing',1299.00,60,'2026-09-28 11:00:00'),(106,104,105,'AC Service & Gas Top-up',2199.00,90,'2026-09-28 11:00:00'),(107,105,101,'Full Car Servicing',4999.00,180,'2026-09-28 11:00:00'),(108,106,106,'Interior Deep Cleaning',1499.00,120,'2026-09-28 11:00:00'),(109,107,108,'Pre-Purchase Inspection',999.00,60,'2026-09-28 11:00:00');
/*!40000 ALTER TABLE `service_request_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_requests`
--

DROP TABLE IF EXISTS `service_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_requests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `car_id` bigint NOT NULL,
  `service_id` bigint DEFAULT NULL,
  `address_id` bigint DEFAULT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_time` time NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `amount` decimal(15,2) NOT NULL,
  `payment_status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('requested','accepted','scheduled','in_progress','completed','cancelled','rejected') COLLATE utf8mb4_unicode_ci NOT NULL,
  `admin_note` text COLLATE utf8mb4_unicode_ci,
  `service_record_id` bigint DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_service_requests_deleted_at` (`deleted_at`),
  KEY `ix_service_requests_service_record_id` (`service_record_id`),
  KEY `ix_service_requests_id` (`id`),
  KEY `ix_service_requests_scheduled_date` (`scheduled_date`),
  KEY `ix_service_requests_address_id` (`address_id`),
  KEY `ix_service_requests_service_id` (`service_id`),
  KEY `ix_service_requests_status` (`status`),
  KEY `ix_service_requests_car_id` (`car_id`),
  KEY `ix_service_requests_user_id` (`user_id`),
  KEY `ix_service_requests_payment_status` (`payment_status`),
  CONSTRAINT `service_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `service_requests_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `service_requests_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `service_requests_ibfk_4` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `service_requests_ibfk_5` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_requests`
--

LOCK TABLES `service_requests` WRITE;
/*!40000 ALTER TABLE `service_requests` DISABLE KEYS */;
INSERT INTO `service_requests` VALUES (101,101,109,101,101,'2026-10-08','10:00:00','Please check the AC as well.',4999.00,'unpaid',NULL,'requested',NULL,NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(102,101,109,102,101,'2026-10-12','11:00:00',NULL,3098.00,'unpaid',NULL,'accepted','Accepted - we will confirm the exact time shortly.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(103,101,110,103,102,'2026-10-15','14:00:00','Squeaking noise from the front brakes.',3898.00,'unpaid',NULL,'scheduled','Scheduled for 15 Oct at 2:00 PM. Our mechanic will arrive at your address.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(104,101,110,105,101,'2026-10-02','09:00:00',NULL,2199.00,'unpaid',NULL,'in_progress','Work started.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(105,101,110,101,101,'2026-09-18','10:00:00','Regular service before a long trip.',4999.00,'unpaid',NULL,'completed','Completed. Next service due in six months.',101,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(106,101,109,106,101,'2026-09-25','15:00:00',NULL,1499.00,'unpaid',NULL,'cancelled','Cancelled by user.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(107,101,109,108,102,'2026-09-22','12:00:00','Need it before buying a used car.',999.00,'unpaid',NULL,'rejected','Sorry, inspections are not available at that location. Please book another time.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL);
/*!40000 ALTER TABLE `service_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `price` decimal(15,2) NOT NULL,
  `duration_minutes` int DEFAULT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_services_status` (`status`),
  KEY `ix_services_id` (`id`),
  KEY `ix_services_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (101,'Full Car Servicing','Complete multi-point service: engine oil and filter, air and cabin filters, brake and fluid check, battery test and a road test.',4999.00,180,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,'Oil & Filter Change','Engine oil and oil filter replacement with a quick fluid top-up and visual inspection.',1799.00,45,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,'Brake Pad Replacement','Front or rear brake pad replacement, disc inspection and brake fluid check.',2599.00,90,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(104,'Wheel Alignment & Balancing','Computerised four-wheel alignment and balancing for even tyre wear and a straighter drive.',1299.00,60,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(105,'AC Service & Gas Top-up','AC performance check, cabin filter cleaning, leak test and refrigerant top-up.',2199.00,90,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(106,'Interior Deep Cleaning','Vacuuming, steam cleaning of seats and mats, dashboard polish and odour treatment.',1499.00,120,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(107,'Battery Check & Replacement','Battery health test, terminal cleaning and replacement if needed (battery cost extra).',3499.00,30,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(108,'Pre-Purchase Inspection','A 100-point inspection by our mechanics before you buy a used car.',999.00,60,NULL,'active','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(109,'Underbody Coating','Rust-proof underbody coating. Currently not offered (shows as Inactive in the admin catalogue).',3999.00,150,NULL,'inactive','2026-09-28 10:00:00','2026-09-28 10:00:00',NULL);
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` bigint NOT NULL,
  `order_id` bigint NOT NULL,
  `car_id` bigint NOT NULL,
  `buyer_id` bigint NOT NULL,
  `seller_id` bigint NOT NULL,
  `final_price` decimal(15,2) NOT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED','UNPAID') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_status` enum('INITIATED','COMPLETED','CANCELLED','FAILED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_transactions_order_id` (`order_id`),
  KEY `listing_id` (`listing_id`),
  KEY `car_id` (`car_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_transactions_id` (`id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `transactions_ibfk_4` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `transactions_ibfk_5` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('USER','ADMIN') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('ACTIVE','INACTIVE','BLOCKED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile_image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_username` (`username`),
  UNIQUE KEY `ix_users_email` (`email`),
  UNIQUE KEY `phone_number` (`phone_number`),
  KEY `ix_users_id` (`id`),
  KEY `ix_users_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (101,'Riya','Patel','riya.demo','riya.patel@carzendemo.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500101','USER','ACTIVE',NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(102,'Arjun','Mehta','arjun.demo','arjun.mehta@carzendemo.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500102','USER','ACTIVE',NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(103,'Neha','Shah','neha.admin','neha.admin@carzendemo.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500103','ADMIN','ACTIVE',NULL,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-03 13:49:21
