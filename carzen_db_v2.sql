-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: carzen_db_v2
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
  `address_line_1` varchar(255) NOT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `landmark` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `postal_code` varchar(10) NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,4,'12, Sardar Patel Ring Road',NULL,'Near Thaltej Cross Roads','Ahmedabad','Gujarat','India','380054',NULL,NULL,1,'2026-08-27 10:00:00','2026-08-27 10:00:00',NULL),(2,5,'45 Adajan Gam Road',NULL,'Opposite Star Bazaar','Surat','Gujarat','India','395009',NULL,NULL,1,'2026-08-27 10:00:00','2026-08-27 10:00:00',NULL),(3,6,'8 Alkapuri Society',NULL,'Near Race Course Circle','Vadodara','Gujarat','India','390007',NULL,NULL,1,'2026-08-27 10:00:00','2026-08-27 10:00:00',NULL),(4,9,'21 Satellite Road',NULL,'Near Iscon Mega Mall','Ahmedabad','Gujarat','India','380015',NULL,NULL,1,'2026-08-27 10:00:00','2026-08-27 10:00:00',NULL);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `car_brands`
--

DROP TABLE IF EXISTS `car_brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car_brands` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `country` varchar(100) DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `ix_car_brands_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_brands`
--

LOCK TABLES `car_brands` WRITE;
/*!40000 ALTER TABLE `car_brands` DISABLE KEYS */;
INSERT INTO `car_brands` VALUES (1,'Toyota','toyota','Japan','https://upload.wikimedia.org/wikipedia/commons/9/9d/Toyota_carlogo.svg','Japanese automobile manufacturer known for reliable and practical vehicles.',1,'2026-09-12 11:13:39','2026-09-12 11:13:39',NULL),(2,'Honda','honda','Japan','https://upload.wikimedia.org/wikipedia/commons/7/7b/Honda_Logo.svg','Japanese automobile manufacturer offering reliable cars, SUVs and hybrid vehicles.',1,'2026-09-12 11:13:39','2026-09-12 11:13:39',NULL),(3,'Hyundai','hyundai','South Korea','https://upload.wikimedia.org/wikipedia/commons/4/44/Hyundai_Motor_Company_logo.svg','South Korean automobile manufacturer with a strong presence in the Indian market.',1,'2026-09-12 11:13:39','2026-09-12 11:13:39',NULL),(4,'Tata','tata','India','https://upload.wikimedia.org/wikipedia/commons/8/83/Tata_Motors_Logo.svg','Indian automobile manufacturer producing passenger cars, SUVs and commercial vehicles.',1,'2026-09-12 11:13:39','2026-09-12 11:13:39',NULL),(5,'Mahindra','mahindra','India','https://upload.wikimedia.org/wikipedia/commons/5/5f/Mahindra_%26_Mahindra_Logo.svg','Indian automobile manufacturer well known for SUVs and utility vehicles.',1,'2026-09-12 11:13:39','2026-09-12 11:13:39',NULL),(16,'Kia','kia','South Korea','https://upload.wikimedia.org/wikipedia/commons/4/47/KIA_logo2.svg','South Korean automobile manufacturer offering modern cars and SUVs with advanced features.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(17,'Skoda','skoda','Czech Republic','https://upload.wikimedia.org/wikipedia/commons/4/44/Skoda_Auto_2016_logo.svg','Czech automobile manufacturer known for practical design, European engineering and premium interiors.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(18,'Volkswagen','volkswagen','Germany','https://upload.wikimedia.org/wikipedia/commons/6/6d/Volkswagen_Logo_2023.svg','German automobile manufacturer known for refined driving dynamics and engineering.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(19,'MG','mg','United Kingdom','https://upload.wikimedia.org/wikipedia/commons/9/9a/MG_logo.svg','Automotive brand offering feature-rich cars and SUVs with modern technology.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(20,'Maruti Suzuki','maruti-suzuki','India','https://upload.wikimedia.org/wikipedia/commons/8/83/Maruti_Suzuki_Logo.svg','Indian automobile manufacturer offering practical, efficient and widely supported passenger vehicles.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL);
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
  `feature_name` varchar(150) NOT NULL,
  `feature_value` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_car_features_id` (`id`),
  CONSTRAINT `car_features_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_features`
--

LOCK TABLES `car_features` WRITE;
/*!40000 ALTER TABLE `car_features` DISABLE KEYS */;
INSERT INTO `car_features` VALUES (1,7,'Ground Clearance Unladen','208 mm','2026-09-10 11:19:29'),(2,7,'Seating Capacity','5','2026-09-10 11:19:45'),(3,7,'Boot Space','382 litres','2026-09-10 11:20:00'),(4,7,'Fuel Tank Capacity','44 litres','2026-09-10 11:20:15'),(5,7,'Engine Displacement','1199 cc','2026-09-10 11:20:31'),(6,7,'Maximum Power','118 HP','2026-09-10 11:20:42'),(7,7,'Transmission Type','Automatic','2026-09-10 11:20:57'),(8,7,'Front Suspension','Independent MacPherson Strut','2026-09-10 11:21:10'),(9,6,'Front Suspension','Independent MacPherson Strut','2026-09-10 11:21:18'),(10,6,'Front Brakes','Disc','2026-09-10 11:21:55'),(11,13,'Airbags','6 Airbags','2026-09-12 11:20:41'),(12,13,'Sunroof','Panoramic Sunroof','2026-09-12 11:20:41'),(13,13,'Infotainment','10.25 inch Touchscreen','2026-09-12 11:20:41'),(14,13,'Parking','360 Degree Camera','2026-09-12 11:20:41'),(15,13,'Cruise Control','Adaptive Cruise Control','2026-09-12 11:20:41'),(16,14,'Airbags','6 Airbags','2026-09-12 11:20:41'),(17,14,'Sunroof','Electric Sunroof','2026-09-12 11:20:41'),(18,14,'Infotainment','10 inch Touchscreen','2026-09-12 11:20:41'),(19,14,'Parking','Rear Camera','2026-09-12 11:20:41'),(20,14,'Drive Modes','Multiple Drive Modes','2026-09-12 11:20:41'),(21,15,'Airbags','6 Airbags','2026-09-12 11:20:41'),(22,15,'Sunroof','Electric Sunroof','2026-09-12 11:20:41'),(23,15,'Infotainment','10 inch Touchscreen','2026-09-12 11:20:41'),(24,15,'Digital Cluster','Digital Instrument Cluster','2026-09-12 11:20:41'),(25,15,'Cruise Control','Cruise Control','2026-09-12 11:20:41'),(26,16,'Airbags','6 Airbags','2026-09-12 11:20:41'),(27,16,'Infotainment','14 inch Touchscreen','2026-09-12 11:20:41'),(28,16,'Connected Car','Connected Car Technology','2026-09-12 11:20:41'),(29,16,'Camera','360 Degree Camera','2026-09-12 11:20:41'),(30,16,'Voice Assistant','AI Voice Assistant','2026-09-12 11:20:41'),(31,17,'Airbags','6 Airbags','2026-09-12 11:20:41'),(32,17,'Infotainment','9 inch Touchscreen','2026-09-12 11:20:41'),(33,17,'Parking','Rear Camera','2026-09-12 11:20:41'),(34,17,'Headlights','LED Projector Headlamps','2026-09-12 11:20:41'),(35,17,'Cruise Control','Cruise Control','2026-09-12 11:20:41'),(36,18,'Airbags','6 Airbags','2026-09-13 11:00:00'),(37,18,'Infotainment','8.8 inch Touchscreen','2026-09-13 11:00:00'),(38,18,'Sunroof','Panoramic Sunroof','2026-09-13 11:00:00'),(39,18,'Drive Modes','Eco / City / Sport','2026-09-13 11:00:00'),(40,19,'Airbags','6 Airbags','2026-09-13 11:00:00'),(41,19,'Infotainment','10.25 inch Touchscreen','2026-09-13 11:00:00'),(42,19,'Camera','Rear Parking Camera','2026-09-13 11:00:00'),(43,19,'Cruise Control','Cruise Control','2026-09-13 11:00:00'),(44,20,'Airbags','Dual Airbags','2026-09-13 11:00:00'),(45,20,'Infotainment','7 inch SmartPlay Studio','2026-09-13 11:00:00'),(46,20,'Fuel Efficiency','23 km/l (ARAI)','2026-09-13 11:00:00'),(47,20,'ABS','ABS with EBD','2026-09-13 11:00:00'),(48,21,'Airbags','6 Airbags','2026-09-13 11:00:00'),(49,21,'Sunroof','Electric Sunroof','2026-09-13 11:00:00'),(50,21,'Safety','Honda Sensing (ADAS)','2026-09-13 11:00:00'),(51,21,'Infotainment','8 inch Touchscreen','2026-09-13 11:00:00'),(52,22,'Drivetrain','4x4 with Low Range','2026-09-13 11:00:00'),(53,22,'Roof','Hard Top','2026-09-13 11:00:00'),(54,22,'Infotainment','7 inch Touchscreen','2026-09-13 11:00:00'),(55,22,'Airbags','Dual Airbags','2026-09-13 11:00:00'),(56,23,'Battery','40.5 kWh Long Range','2026-09-13 11:00:00'),(57,23,'Charging','Home Charger Included','2026-09-13 11:00:00'),(58,23,'Infotainment','10.25 inch Touchscreen','2026-09-13 11:00:00'),(59,23,'Camera','360 Degree Camera','2026-09-13 11:00:00'),(60,24,'Powertrain','Strong Hybrid e-CVT','2026-09-13 11:00:00'),(61,24,'Infotainment','9 inch Touchscreen','2026-09-13 11:00:00'),(62,24,'Sunroof','Panoramic Sunroof','2026-09-13 11:00:00'),(63,24,'Warranty','Manufacturer warranty active','2026-09-13 11:00:00'),(64,25,'Transmission','7-speed DCT','2026-09-13 11:00:00'),(65,25,'Sunroof','Electric Sunroof','2026-09-13 11:00:00'),(66,25,'Connected Car','Blue Link Connected Car','2026-09-13 11:00:00'),(67,25,'Airbags','6 Airbags','2026-09-13 11:00:00'),(68,26,'Seating','7 Seater (2+3+2)','2026-09-13 11:00:00'),(69,26,'Air Conditioning','Rear AC Vents','2026-09-13 11:00:00'),(70,26,'Service','Recent clutch and suspension work','2026-09-13 11:00:00'),(71,26,'Infotainment','7 inch Touchscreen','2026-09-13 11:00:00'),(72,27,'Transmission','AGS (Auto Gear Shift)','2026-09-13 11:00:00'),(73,27,'Infotainment','7 inch SmartPlay Studio','2026-09-13 11:00:00'),(74,27,'Airbags','Dual Airbags','2026-09-13 11:00:00'),(75,27,'Keyless','Push Button Start','2026-09-13 11:00:00'),(76,28,'Safety','Level 2 ADAS','2026-09-13 11:00:00'),(77,28,'Sunroof','Panoramic Sunroof','2026-09-13 11:00:00'),(78,28,'Seating','7 Seater Captain Options','2026-09-13 11:00:00'),(79,28,'Infotainment','Dual 10.25 inch Screens','2026-09-13 11:00:00'),(80,29,'Fuel','Company-fitted CNG','2026-09-13 11:00:00'),(81,29,'Infotainment','7 inch SmartPlay Studio','2026-09-13 11:00:00'),(82,29,'Service','Full service records','2026-09-13 11:00:00'),(83,29,'ABS','ABS with EBD','2026-09-13 11:00:00'),(84,30,'Airbags','Dual Airbags','2026-09-13 11:00:00'),(85,30,'Infotainment','7 inch Touchscreen','2026-09-13 11:00:00'),(86,30,'Transmission','AMT','2026-09-13 11:00:00'),(87,30,'Camera','Rear Parking Camera','2026-09-13 11:00:00');
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
  `media_type` enum('IMAGE','VIDEO','DOCUMENT') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_car_media_id` (`id`),
  CONSTRAINT `car_media_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_media`
--

LOCK TABLES `car_media` WRITE;
/*!40000 ALTER TABLE `car_media` DISABLE KEYS */;
INSERT INTO `car_media` VALUES (1,7,'IMAGE','/uploads/cars/7/4c7345cfa4a04d76afda42f69a8c0597.jpg',NULL,'4-Website-Page-1500x664-241224.jpg.ximg.l_full_m.smart.jpg',157117,0,0,'2026-09-10 11:23:41',NULL),(2,7,'VIDEO','/uploads/cars/7/ac650921d6394737a88f8048d1b471b0.mp4',NULL,'13335275_3840_2160_24fps.mp4',9003211,0,0,'2026-09-10 11:24:02',NULL),(3,13,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','kia-seltos-front.jpg',285000,1,1,'2026-09-12 11:20:41',NULL),(4,13,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','kia-seltos-side.jpg',267000,2,0,'2026-09-12 11:20:41',NULL),(5,14,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','skoda-kushaq-front.jpg',291000,1,1,'2026-09-12 11:20:41',NULL),(6,14,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','skoda-kushaq-side.jpg',256000,2,0,'2026-09-12 11:20:41',NULL),(7,15,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','volkswagen-virtus-front.jpg',302000,1,1,'2026-09-12 11:20:41',NULL),(8,15,'IMAGE','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=500&q=75','volkswagen-virtus-rear.jpg',278000,2,0,'2026-09-12 11:20:41',NULL),(9,16,'IMAGE','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=500&q=75','mg-hector-front.jpg',310000,1,1,'2026-09-12 11:20:41',NULL),(10,16,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','mg-hector-side.jpg',275000,2,0,'2026-09-12 11:20:41',NULL),(11,17,'IMAGE','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=75','baleno-front.jpg',242000,1,1,'2026-09-12 11:20:41',NULL),(12,17,'IMAGE','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=500&q=75','baleno-side.jpg',229000,2,0,'2026-09-12 11:20:41',NULL),(13,18,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','harrier-front.jpg',210000,0,1,'2026-08-28 10:00:00',NULL),(14,18,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','harrier-side.jpg',247000,1,0,'2026-08-28 10:00:00',NULL),(15,18,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','harrier-rear.jpg',284000,2,0,'2026-08-28 10:00:00',NULL),(16,19,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','creta-front.jpg',211300,0,1,'2026-08-29 11:30:00',NULL),(17,19,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','creta-side.jpg',248300,1,0,'2026-08-29 11:30:00',NULL),(18,19,'IMAGE','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=500&q=75','creta-rear.jpg',285300,2,0,'2026-08-29 11:30:00',NULL),(19,20,'IMAGE','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=500&q=75','swift-front.jpg',212600,0,1,'2026-08-30 09:15:00',NULL),(20,20,'IMAGE','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=75','swift-side.jpg',249600,1,0,'2026-08-30 09:15:00',NULL),(21,20,'IMAGE','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=500&q=75','swift-rear.jpg',286600,2,0,'2026-08-30 09:15:00',NULL),(22,21,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','honda-city-front.jpg',213900,0,1,'2026-08-31 15:45:00',NULL),(23,21,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','honda-city-side.jpg',250900,1,0,'2026-08-31 15:45:00',NULL),(24,21,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','honda-city-rear.jpg',287900,2,0,'2026-08-31 15:45:00',NULL),(25,22,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','thar-front.jpg',215200,0,1,'2026-09-01 12:00:00',NULL),(26,22,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','thar-side.jpg',252200,1,0,'2026-09-01 12:00:00',NULL),(27,22,'IMAGE','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=500&q=75','thar-rear.jpg',289200,2,0,'2026-09-01 12:00:00',NULL),(28,23,'IMAGE','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=500&q=75','nexon-front.jpg',216500,0,1,'2026-09-02 10:20:00',NULL),(29,23,'IMAGE','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=75','nexon-side.jpg',253500,1,0,'2026-09-02 10:20:00',NULL),(30,23,'IMAGE','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=500&q=75','nexon-rear.jpg',290500,2,0,'2026-09-02 10:20:00',NULL),(31,24,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','urban-cruiser-hyryder-front.jpg',217800,0,1,'2026-09-03 13:10:00',NULL),(32,24,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','urban-cruiser-hyryder-side.jpg',254800,1,0,'2026-09-03 13:10:00',NULL),(33,24,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','urban-cruiser-hyryder-rear.jpg',291800,2,0,'2026-09-03 13:10:00',NULL),(34,25,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','venue-front.jpg',219100,0,1,'2026-09-04 09:50:00',NULL),(35,25,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','venue-side.jpg',256100,1,0,'2026-09-04 09:50:00',NULL),(36,25,'IMAGE','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=500&q=75','venue-rear.jpg',293100,2,0,'2026-09-04 09:50:00',NULL),(37,26,'IMAGE','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=500&q=75','toyota-innova-crysta-front.jpg',220400,0,1,'2026-09-05 16:30:00',NULL),(38,26,'IMAGE','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=75','toyota-innova-crysta-side.jpg',257400,1,0,'2026-09-05 16:30:00',NULL),(39,26,'IMAGE','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=500&q=75','toyota-innova-crysta-rear.jpg',294400,2,0,'2026-09-05 16:30:00',NULL),(40,27,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','maruti-suzuki-dzire-front.jpg',221700,0,1,'2026-09-06 11:40:00',NULL),(41,27,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','maruti-suzuki-dzire-side.jpg',258700,1,0,'2026-09-06 11:40:00',NULL),(42,27,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','maruti-suzuki-dzire-rear.jpg',295700,2,0,'2026-09-06 11:40:00',NULL),(43,28,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','xuv700-front.jpg',223000,0,1,'2026-09-07 14:00:00',NULL),(44,28,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','xuv700-side.jpg',260000,1,0,'2026-09-07 14:00:00',NULL),(45,28,'IMAGE','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=500&q=75','xuv700-rear.jpg',297000,2,0,'2026-09-07 14:00:00',NULL),(46,29,'IMAGE','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=500&q=75','swift-front.jpg',224300,0,1,'2026-09-08 10:35:00',NULL),(47,29,'IMAGE','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=500&q=75','swift-side.jpg',261300,1,0,'2026-09-08 10:35:00',NULL),(48,29,'IMAGE','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=500&q=75','swift-rear.jpg',298300,2,0,'2026-09-08 10:35:00',NULL),(49,30,'IMAGE','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=500&q=75','tata-tiago-front.jpg',225600,0,1,'2026-08-27 09:00:00',NULL),(50,30,'IMAGE','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=500&q=75','tata-tiago-side.jpg',262600,1,0,'2026-08-27 09:00:00',NULL),(51,30,'IMAGE','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=500&q=75','tata-tiago-rear.jpg',299600,2,0,'2026-08-27 09:00:00',NULL),(52,31,'IMAGE','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=75','safari-front.jpg',226900,0,1,'2026-09-17 18:20:00',NULL),(53,31,'IMAGE','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=85','https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=500&q=75','safari-side.jpg',263900,1,0,'2026-09-17 18:20:00',NULL);
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
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `body_type` enum('HATCHBACK','SEDAN','SUV','MUV','COUPE','CONVERTIBLE','PICKUP','MINIVAN','OTHER') DEFAULT NULL,
  `seating_capacity` int DEFAULT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `brand_id` (`brand_id`),
  KEY `ix_car_models_id` (`id`),
  CONSTRAINT `car_models_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `car_brands` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_models`
--

LOCK TABLES `car_models` WRITE;
/*!40000 ALTER TABLE `car_models` DISABLE KEYS */;
INSERT INTO `car_models` VALUES (1,4,'Nexon','nexon','SUV',5,'Compact SUV with petrol, diesel, and electric powertrain options.',1,'2026-09-10 10:31:48','2026-09-10 10:31:48',NULL),(2,4,'Punch','punch','SUV',5,'Compact SUV designed for urban driving with a spacious and practical interior.',1,'2026-09-10 10:32:15','2026-09-10 10:32:15',NULL),(3,4,'Harrier','harrier','SUV',5,'Premium mid-size SUV offering a spacious cabin and strong road presence.',1,'2026-09-10 10:32:32','2026-09-10 10:32:32',NULL),(4,4,'Safari','safari','SUV',7,'Three-row premium SUV designed for family and long-distance travel.',1,'2026-09-10 10:32:45','2026-09-10 10:32:45',NULL),(5,20,'Swift','swift','HATCHBACK',5,'Popular premium hatchback known for its sporty design, efficiency, and city-friendly performance.',1,'2026-09-10 10:33:09','2026-09-10 10:33:09',NULL),(6,20,'Baleno','baleno','HATCHBACK',5,'Premium hatchback offering a spacious cabin, modern features, and efficient performance.',1,'2026-09-10 10:33:32','2026-09-10 10:33:32',NULL),(7,3,'Creta','creta','SUV',5,'Popular mid-size SUV offering modern styling, advanced features, and multiple powertrain options.',1,'2026-09-10 10:34:12','2026-09-10 10:34:12',NULL),(8,3,'Venue','venue','SUV',5,'Compact SUV designed for urban mobility with modern technology and efficient engines.',1,'2026-09-10 10:34:34','2026-09-10 10:34:34',NULL),(9,5,'Thar','thar','SUV',4,'Rugged lifestyle SUV designed for both everyday driving and off-road adventures.',1,'2026-09-10 10:35:05','2026-09-10 10:35:05',NULL),(10,5,'Scorpio','scorpio','SUV',7,'Rugged SUV offering a commanding driving position, spacious seating, and strong road presence.',1,'2026-09-10 10:35:25','2026-09-10 10:35:25',NULL),(11,5,'XUV700','xuv700','SUV',7,'Premium SUV offering advanced technology, powerful engines, and flexible seating configurations.',1,'2026-09-10 10:35:42','2026-09-10 10:35:42',NULL),(12,1,'Urban Cruiser Hyryder','urban-cruiser-hyryder','SUV',5,'Mid-size SUV available with petrol and strong-hybrid powertrain options for efficient everyday driving.',1,'2026-09-10 10:36:57','2026-09-10 10:36:57',NULL),(13,16,'Seltos','kia-seltos','SUV',5,'Modern compact SUV with premium interiors, strong road presence and advanced technology.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(14,17,'Kushaq','skoda-kushaq','SUV',5,'European-inspired compact SUV offering solid build quality, refined performance and practicality.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(15,18,'Virtus','volkswagen-virtus','SEDAN',5,'Premium mid-size sedan focused on driving performance, comfort and refined design.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(16,19,'Hector','mg-hector','SUV',5,'Spacious SUV featuring connected technology, premium cabin equipment and comfortable seating.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(17,20,'Baleno','maruti-suzuki-baleno','HATCHBACK',5,'Premium hatchback offering efficient performance, practical dimensions and modern features.',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(18,2,'Honda City','honda-city','SEDAN',5,'Compact sedan known for refinement, space and a reliable petrol engine.',1,'2026-09-13 10:00:00','2026-09-13 10:00:00',NULL),(19,3,'i20','hyundai-i20','HATCHBACK',5,'Premium hatchback with a feature-rich cabin and smooth petrol engines.',1,'2026-09-13 10:00:00','2026-09-13 10:00:00',NULL),(20,20,'Dzire','maruti-suzuki-dzire','SEDAN',5,'Compact sedan popular for low running costs and easy maintenance.',1,'2026-09-13 10:00:00','2026-09-13 10:00:00',NULL),(21,1,'Innova Crysta','toyota-innova-crysta','MUV',7,'Seven-seat family MPV known for durability and comfortable long-distance travel.',1,'2026-09-13 10:00:00','2026-09-13 10:00:00',NULL),(22,4,'Tiago','tata-tiago','HATCHBACK',5,'Practical city hatchback with strong safety credentials.',1,'2026-09-13 10:00:00','2026-09-13 10:00:00',NULL);
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
  `variant_name` varchar(150) NOT NULL,
  `fuel_type` enum('PETROL','DIESEL','CNG','ELECTRIC','HYBRID') NOT NULL,
  `transmission` enum('MANUAL','AUTOMATIC','AMT','CVT','DCT') NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_variants`
--

LOCK TABLES `car_variants` WRITE;
/*!40000 ALTER TABLE `car_variants` DISABLE KEYS */;
INSERT INTO `car_variants` VALUES (1,1,'Smart 1.2 Petrol MT','PETROL','MANUAL',1199.00,120.00,5,800000.00,'2026-09-10 10:41:57','2026-09-10 10:41:57',NULL),(2,1,'Pure 1.2 Petrol MT','PETROL','MANUAL',1199.00,120.00,5,900000.00,'2026-09-10 10:42:14','2026-09-10 10:42:14',NULL),(3,1,'Creative 1.2 Petrol DCA','PETROL','DCT',1199.00,120.00,5,1200000.00,'2026-09-10 10:42:32','2026-09-10 10:42:32',NULL),(4,1,'Creative 1.5 Diesel MT','DIESEL','MANUAL',1497.00,115.00,5,1250000.00,'2026-09-10 10:42:45','2026-09-10 10:42:45',NULL),(5,2,'Pure 1.2 Petrol MT','PETROL','MANUAL',1199.00,88.00,5,700000.00,'2026-09-10 10:43:15','2026-09-10 10:43:15',NULL),(6,2,'Adventure 1.2 Petrol MT','PETROL','MANUAL',1199.00,88.00,5,800000.00,'2026-09-10 10:43:26','2026-09-10 10:43:26',NULL),(7,2,'Accomplished 1.2 Petrol AMT','PETROL','AMT',1199.00,88.00,5,950000.00,'2026-09-10 10:43:35','2026-09-10 10:43:35',NULL),(8,13,'HTX 1.5 Turbo','PETROL','AUTOMATIC',1482.00,158.00,5,1895000.00,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(9,14,'Style 1.5 TSI DSG','PETROL','AUTOMATIC',1498.00,148.00,5,1825000.00,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(10,15,'GT Plus 1.5 TSI','PETROL','AUTOMATIC',1498.00,148.00,5,1950000.00,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(11,16,'Sharp Pro 1.5 Turbo','PETROL','AUTOMATIC',1451.00,141.00,5,2100000.00,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(12,17,'Alpha AGS','PETROL','AUTOMATIC',1197.00,88.00,5,980000.00,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(13,1,'Empowered LR Electric','ELECTRIC','AUTOMATIC',NULL,143.00,5,1600000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(14,3,'Adventure 2.0 Diesel MT','DIESEL','MANUAL',1956.00,168.00,5,1700000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(15,3,'Fearless 2.0 Diesel AT','DIESEL','AUTOMATIC',1956.00,168.00,5,2100000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(16,4,'Accomplished 2.0 Diesel AT','DIESEL','AUTOMATIC',1956.00,168.00,7,2500000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(17,5,'VXi 1.2 Petrol MT','PETROL','MANUAL',1197.00,82.00,5,650000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(18,5,'ZXi 1.2 CNG MT','CNG','MANUAL',1197.00,77.00,5,780000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(19,7,'SX 1.5 Diesel MT','DIESEL','MANUAL',1493.00,113.00,5,1500000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(20,7,'SX(O) 1.5 Petrol CVT','PETROL','CVT',1497.00,113.00,5,1800000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(21,8,'S(O) 1.0 Turbo DCT','PETROL','DCT',998.00,118.00,5,1250000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(22,9,'LX 2.2 Diesel 4WD MT','DIESEL','MANUAL',2184.00,130.00,4,1650000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(23,10,'S11 2.2 Diesel MT','DIESEL','MANUAL',2184.00,130.00,7,1800000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(24,11,'AX7 2.0 Petrol AT','PETROL','AUTOMATIC',1999.00,200.00,7,2400000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(25,12,'V Strong Hybrid e-CVT','HYBRID','CVT',1490.00,115.00,5,1950000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(26,18,'ZX 1.5 Petrol CVT','PETROL','CVT',1498.00,119.00,5,1500000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(27,19,'Asta 1.2 Petrol MT','PETROL','MANUAL',1197.00,82.00,5,950000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(28,20,'ZXi AGS','PETROL','AMT',1197.00,82.00,5,900000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(29,21,'GX 2.4 Diesel MT','DIESEL','MANUAL',2393.00,148.00,7,2000000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL),(30,22,'XZ+ 1.2 Petrol AMT','PETROL','AMT',1199.00,84.00,5,850000.00,'2026-09-13 10:05:00','2026-09-13 10:05:00',NULL);
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
  `registration_number` varchar(30) DEFAULT NULL,
  `vin_number` varchar(100) DEFAULT NULL,
  `manufacturing_year` int NOT NULL,
  `registration_year` int DEFAULT NULL,
  `fuel_type` enum('PETROL','DIESEL','CNG','ELECTRIC','HYBRID') NOT NULL,
  `transmission` enum('MANUAL','AUTOMATIC','AMT','CVT','DCT') NOT NULL,
  `engine_cc` decimal(8,2) DEFAULT NULL,
  `horsepower` decimal(8,2) DEFAULT NULL,
  `mileage_km` decimal(12,2) NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  `seating_capacity` int DEFAULT NULL,
  `owner_count` int DEFAULT NULL,
  `ownership_type` enum('FIRST_OWNER','SECOND_OWNER','THIRD_OWNER','FOURTH_OR_MORE') DEFAULT NULL,
  `condition` enum('EXCELLENT','GOOD','FAIR','POOR','NEW','OLD') DEFAULT NULL,
  `insurance_company` varchar(150) DEFAULT NULL,
  `insurance_type` varchar(100) DEFAULT NULL,
  `insurance_expiry` date DEFAULT NULL,
  `rc_status` varchar(50) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `description` text,
  `expected_market_price` decimal(15,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT NULL,
  `approval_status` enum('draft','pending_approval','approved','rejected','published','sold','inactive') NOT NULL,
  `rejection_reason` text,
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
  KEY `ix_cars_id` (`id`),
  KEY `fk_cars_verified_by` (`verified_by_id`),
  CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `car_variants` (`id`),
  CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`),
  CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`verified_by_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cars_verified_by` FOREIGN KEY (`verified_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
INSERT INTO `cars` VALUES (1,2,3,NULL,NULL,2026,NULL,'PETROL','MANUAL',1199.00,118.00,0.00,'Pure Grey',5,0,NULL,'NEW',NULL,NULL,NULL,NULL,'Ahmedabad','Gujarat','India','380001','Brand-new Tata Nexon with zero kilometres, ready for delivery.',850000.00,1,'published',NULL,'2026-09-10 11:26:54',1,'2026-09-10 11:00:51','2026-09-10 11:36:45',NULL),(2,2,3,NULL,NULL,2026,NULL,'PETROL','MANUAL',1199.00,118.00,0.00,'Atlas Black',5,1,NULL,'NEW',NULL,NULL,NULL,NULL,'Ahmedabad','Gujarat','India','380001','Brand-new Tata Nexon, zero kilometres, available for immediate delivery.',850000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-10 11:06:09','2026-09-10 11:06:09',NULL),(3,2,3,NULL,NULL,2026,NULL,'PETROL','MANUAL',1199.00,118.00,0.00,'Atlas Black',5,1,NULL,'NEW',NULL,NULL,NULL,NULL,'Ahmedabad','Gujarat','India','380001','Brand-new Tata Nexon, zero kilometres, available for immediate delivery.',850000.00,0,'rejected','Vehicle registration information could not be pepper add.','2026-09-10 11:27:20',1,'2026-09-10 11:06:15','2026-09-10 11:27:20',NULL),(4,2,3,NULL,NULL,2026,NULL,'PETROL','MANUAL',1199.00,118.00,0.00,'Atlas Black',5,1,NULL,'NEW',NULL,NULL,NULL,NULL,'Ahmedabad','Gujarat','India','380001','Brand-new Tata Nexon, zero kilometres, available for immediate delivery.',850000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-10 11:07:25','2026-09-10 11:07:25',NULL),(5,2,3,NULL,NULL,2026,NULL,'PETROL','MANUAL',1199.00,118.00,0.00,'Pure Grey',5,1,NULL,'NEW',NULL,NULL,NULL,NULL,'Ahmedabad','Gujarat','India','380001','Brand-new Tata Nexon with zero kilometres, ready for delivery.',850000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-10 11:08:44','2026-09-10 11:08:44',NULL),(6,2,2,'GJ01MK4587','MAT627184NAX45872',2022,2022,'DIESEL','AUTOMATIC',1497.00,113.00,38500.00,'Pearl White',5,1,'FIRST_OWNER','OLD','ICICI Lombard','comprehensive','2027-04-18','valid','Ahmedabad','Gujarat','India','380015','Well-maintained Tata Nexon with complete service history, single previous owner, clean interior and exterior, and no major accident history.',825000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-10 11:10:41','2026-09-10 11:10:41',NULL),(7,2,2,'GJ01RT7821','MAT62719NXB782145',2023,2023,'PETROL','AUTOMATIC',1199.00,118.00,22000.00,'Daytona Grey',5,1,'FIRST_OWNER','OLD','HDFC ERGO','comprehensive','2027-08-22','valid','Ahmedabad','Gujarat','India','380054','Excellent condition Tata Nexon with low mileage, single owner, complete service records, clean interior, and well-maintained exterior.',925000.00,1,'published',NULL,'2026-09-10 11:26:23',1,'2026-09-10 11:14:42','2026-09-10 11:38:31',NULL),(8,5,3,'GJ09RT7891','MAT62719NXB782974',2023,2023,'PETROL','AUTOMATIC',1199.00,118.00,22000.00,'Daytona Grey',5,1,'FIRST_OWNER','OLD','HDFC ERGO','comprehensive','2027-08-22','valid','Ahmedabad','Gujarat','India','380054','Excellent condition Tata Nexon with low mileage, single owner, complete service records, clean interior, and well-maintained exterior.',925000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-11 13:37:48','2026-09-11 13:37:48',NULL),(9,6,2,'GJ09RT7081','MAT62710OXB782974',2023,2023,'PETROL','AUTOMATIC',1199.00,118.00,22000.00,'Daytona Grey',5,1,'FIRST_OWNER','OLD','HDFC ERGO','comprehensive','2027-08-22','valid','Ahmedabad','Gujarat','India','380054','Excellent condition Tata Nexon with low mileage, single owner, complete service records, clean interior, and well-maintained exterior.',925000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-11 13:38:51','2026-09-11 13:38:51',NULL),(10,6,2,'GJ09RT7000','MAT62710OXB782933',2023,2023,'PETROL','AUTOMATIC',1199.00,118.00,22000.00,'Daytona Grey',5,1,'FIRST_OWNER','GOOD','HDFC ERGO','comprehensive','2027-08-22','valid','Ahmedabad','Gujarat','India','380054','Excellent condition Tata Nexon with low mileage, single owner, complete service records, clean interior, and well-maintained exterior.',925000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-11 13:39:51','2026-09-11 13:39:51',NULL),(11,6,2,'GJ09RT7070','MAT62710OXB782903',2023,2023,'PETROL','AUTOMATIC',1199.00,118.00,22000.00,'Daytona Grey',5,1,'FIRST_OWNER','NEW','HDFC ERGO','comprehensive','2027-08-22','valid','Ahmedabad','Gujarat','India','380054','Excellent condition Tata Nexon with low mileage, single owner, complete service records, clean interior, and well-maintained exterior.',925000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-11 13:40:43','2026-09-11 13:40:43',NULL),(12,2,3,'GJ01AB1234','MA3EJKD1S00123456',2022,2022,'DIESEL','AUTOMATIC',2755.00,201.00,35000.00,'White',7,1,'FIRST_OWNER','GOOD','ABC Insurance','comprehensive','2027-03-15','valid','Ahmedabad','Gujarat','India','380001','Well maintained vehicle',3200000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-11 13:52:17','2026-09-11 13:52:17',NULL),(13,8,1,'GJ01LM4821','KIASELTO2023GJ00001',2023,2023,'PETROL','AUTOMATIC',1482.00,158.00,24500.00,'Pearl White',5,1,'FIRST_OWNER','EXCELLENT','ICICI_LOMBARD','COMPREHENSIVE','2027-12-15','ACTIVE','Ahmedabad','Gujarat','India','380054','Single-owner Kia Seltos with low mileage, clean interior and complete service history.',1680000.00,1,'approved',NULL,'2026-09-12 11:20:41',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(14,9,1,'GJ05NP7316','SKODAKUSHAQ2022GJ00002',2022,2022,'PETROL','AUTOMATIC',1498.00,148.00,31800.00,'Carbon Steel',5,1,'FIRST_OWNER','GOOD','HDFC_ERGO','COMPREHENSIVE','2027-08-22','ACTIVE','Vadodara','Gujarat','India','390011','Well maintained Skoda Kushaq with DSG automatic transmission and complete maintenance records.',1490000.00,1,'approved',NULL,'2026-09-12 11:20:41',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(15,10,1,'GJ27QR1548','VWVIRTUS2024GJ00003',2024,2024,'PETROL','AUTOMATIC',1498.00,148.00,12600.00,'Deep Black',5,1,'FIRST_OWNER','EXCELLENT','BAJAJ_ALLIANZ','COMPREHENSIVE','2028-04-18','ACTIVE','Surat','Gujarat','India','395009','Nearly new Volkswagen Virtus GT with very low mileage and premium interior condition.',1785000.00,1,'approved',NULL,'2026-09-12 11:20:41',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(16,11,1,'GJ18ST6209','MGHECTOR2022GJ00004',2022,2022,'PETROL','AUTOMATIC',1451.00,141.00,36500.00,'Metallic Red',5,2,'SECOND_OWNER','GOOD','TATA_AIG','COMPREHENSIVE','2027-10-05','ACTIVE','Rajkot','Gujarat','India','360005','Spacious MG Hector with connected car technology, automatic transmission and good service history.',1540000.00,1,'approved',NULL,'2026-09-12 11:20:41',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(17,12,1,'GJ06UV8432','MARUTIBALENO2024GJ00005',2024,2024,'PETROL','AUTOMATIC',1197.00,88.00,9800.00,'Nexa Blue',5,1,'FIRST_OWNER','EXCELLENT','RELIANCE_GENERAL','COMPREHENSIVE','2028-06-12','ACTIVE','Gandhinagar','Gujarat','India','382010','Low-mileage Maruti Suzuki Baleno Alpha with excellent condition and premium features.',875000.00,1,'approved',NULL,'2026-09-12 11:20:41',1,'2026-09-12 11:20:41','2026-09-12 11:20:41',NULL),(18,14,4,'GJ01DM1001','DEMOVIN2021GJ00001',2021,2021,'DIESEL','MANUAL',1956.00,168.00,48000.00,'Lunar White',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-05-14','valid','Ahmedabad','Gujarat','India','380054','Single-owner Harrier with full service history at the authorised workshop. Comfortable highway car with plenty of torque.',1450000.00,1,'published',NULL,'2026-08-28 10:00:00',1,'2026-08-28 10:00:00','2026-08-28 10:00:00',NULL),(19,19,5,'GJ05DM1002','DEMOVIN2020GJ00002',2020,2020,'DIESEL','MANUAL',1493.00,113.00,62300.00,'Polar White',5,2,'SECOND_OWNER','GOOD','HDFC ERGO','comprehensive','2027-02-03','valid','Surat','Gujarat','India','395009','Well-kept Creta diesel, two owners, all tyres replaced last year. Rear camera and touchscreen working perfectly.',1210000.00,1,'published',NULL,'2026-08-29 11:30:00',1,'2026-08-29 11:30:00','2026-08-29 11:30:00',NULL),(20,17,6,'GJ06DM1003','DEMOVIN2019GJ00003',2019,2019,'PETROL','MANUAL',1197.00,82.00,41200.00,'Magma Grey',5,1,'FIRST_OWNER','GOOD','New India Assurance','third_party','2026-12-20','valid','Vadodara','Gujarat','India','390007','Reliable city hatchback, first owner, regular servicing and excellent fuel economy.',485000.00,1,'published',NULL,'2026-08-30 09:15:00',1,'2026-08-30 09:15:00','2026-08-30 09:15:00',NULL),(21,26,7,'GJ27DM1004','DEMOVIN2022GJ00004',2022,2022,'PETROL','CVT',1498.00,119.00,21500.00,'Radiant Red',5,1,'FIRST_OWNER','EXCELLENT','Bajaj Allianz','comprehensive','2027-08-09','valid','Rajkot','Gujarat','India','360005','Low-mileage City ZX with sunroof and Honda Sensing. Garage-kept and never modified.',1295000.00,1,'published',NULL,'2026-08-31 15:45:00',1,'2026-08-31 15:45:00','2026-08-31 15:45:00',NULL),(22,22,8,'GJ01DM1005','DEMOVIN2021GJ00005',2021,2021,'DIESEL','MANUAL',2184.00,130.00,33800.00,'Napoli Black',4,1,'FIRST_OWNER','EXCELLENT','TATA AIG','comprehensive','2027-06-30','valid','Ahmedabad','Gujarat','India','380015','4x4 Thar hard-top, lightly used for weekend drives. Genuine accessories, no off-road abuse.',1525000.00,1,'published',NULL,'2026-09-01 12:00:00',1,'2026-09-01 12:00:00','2026-09-01 12:00:00',NULL),(23,13,7,'GJ18DM1006','DEMOVIN2023GJ00006',2023,2023,'ELECTRIC','AUTOMATIC',NULL,143.00,14200.00,'Teal Blue',5,1,'FIRST_OWNER','EXCELLENT','ICICI Lombard','comprehensive','2027-11-11','valid','Gandhinagar','Gujarat','India','382010','Long-range Nexon EV with home charger included. Battery health verified at service centre.',1350000.00,1,'published',NULL,'2026-09-02 10:20:00',1,'2026-09-02 10:20:00','2026-09-02 10:20:00',NULL),(24,25,4,'GJ05DM1007','DEMOVIN2023GJ00007',2023,2023,'HYBRID','CVT',1490.00,115.00,9600.00,'Speedy Blue',5,1,'FIRST_OWNER','EXCELLENT','HDFC ERGO','comprehensive','2027-10-02','valid','Surat','Gujarat','India','395007','Strong-hybrid Hyryder with outstanding mileage. Still under manufacturer warranty.',1820000.00,1,'published',NULL,'2026-09-03 13:10:00',1,'2026-09-03 13:10:00','2026-09-03 13:10:00',NULL),(25,21,5,'GJ01DM1008','DEMOVIN2022GJ00008',2022,2022,'PETROL','DCT',998.00,118.00,27900.00,'Titan Grey',5,1,'FIRST_OWNER','GOOD','Reliance General','comprehensive','2027-04-25','valid','Ahmedabad','Gujarat','India','380052','Fun-to-drive turbo Venue with DCT gearbox, sunroof and connected car features.',1010000.00,1,'published',NULL,'2026-09-04 09:50:00',1,'2026-09-04 09:50:00','2026-09-04 09:50:00',NULL),(26,29,6,'GJ01DM1009','DEMOVIN2018GJ00009',2018,2018,'DIESEL','MANUAL',2393.00,148.00,89400.00,'Silver Metallic',7,2,'SECOND_OWNER','FAIR','Oriental Insurance','comprehensive','2026-11-30','valid','Ahmedabad','Gujarat','India','380058','Seven-seat family Innova with recent clutch and suspension work. Accident-free.',1380000.00,1,'published',NULL,'2026-09-05 16:30:00',1,'2026-09-05 16:30:00','2026-09-05 16:30:00',NULL),(27,28,7,'GJ06DM1010','DEMOVIN2021GJ00010',2021,2021,'PETROL','AMT',1197.00,82.00,26400.00,'Pearl White',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-03-18','valid','Vadodara','Gujarat','India','390011','Easy-to-drive AMT Dzire, ideal first car or city commuter.',665000.00,1,'published',NULL,'2026-09-06 11:40:00',1,'2026-09-06 11:40:00','2026-09-06 11:40:00',NULL),(28,24,8,'GJ05DM1011','DEMOVIN2022GJ00011',2022,2022,'PETROL','AUTOMATIC',1999.00,200.00,24100.00,'Everest White',7,1,'FIRST_OWNER','EXCELLENT','HDFC ERGO','comprehensive','2027-07-22','valid','Surat','Gujarat','India','395009','Loaded AX7 with ADAS, panoramic sunroof and 7 seats. Immaculate condition.',1925000.00,1,'published',NULL,'2026-09-07 14:00:00',1,'2026-09-07 14:00:00','2026-09-07 14:00:00',NULL),(29,18,4,'GJ27DM1012','DEMOVIN2020GJ00012',2020,2020,'CNG','MANUAL',1197.00,77.00,55600.00,'Solid Fire Red',5,2,'SECOND_OWNER','GOOD','New India Assurance','comprehensive','2026-12-01','valid','Rajkot','Gujarat','India','360001','Company-fitted CNG Swift with very low running cost. Service records available.',565000.00,1,'published',NULL,'2026-09-08 10:35:00',1,'2026-09-08 10:35:00','2026-09-08 10:35:00',NULL),(30,30,5,'GJ01DM1013','DEMOVIN2021GJ00013',2021,2021,'PETROL','AMT',1199.00,84.00,30900.00,'Daytona Grey',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-01-15','valid','Ahmedabad','Gujarat','India','380009','Neat Tiago AMT with new tyres and fresh service. Sold through CarZen.',595000.00,1,'sold',NULL,'2026-08-27 09:00:00',1,'2026-08-27 09:00:00','2026-08-27 09:00:00',NULL),(31,16,8,'GJ05DM1014','DEMOVIN2022GJ00014',2022,2022,'DIESEL','AUTOMATIC',1956.00,168.00,41000.00,'Cosmic Gold',7,1,'FIRST_OWNER','GOOD','HDFC ERGO','comprehensive','2027-09-01','valid','Surat','Gujarat','India','395009','Three-row Safari with captain seats, awaiting admin approval.',2050000.00,1,'approved',NULL,'2026-09-20 14:18:59',1,'2026-09-17 18:20:00','2026-09-20 14:18:59',NULL),(32,20,6,'GJ06DM1015','DEMOVIN2019GJ00015',2019,2019,'PETROL','CVT',1497.00,113.00,71500.00,'Phantom Black',5,3,'THIRD_OWNER','FAIR','Oriental Insurance','third_party','2026-10-10','valid','Vadodara','Gujarat','India','390007','Third-owner Creta petrol CVT.',1050000.00,0,'pending_approval',NULL,'2026-09-21 13:26:43',1,'2026-09-12 08:45:00','2026-09-21 13:26:43',NULL),(33,23,7,'GJ18DM1016','DEMOVIN2017GJ00016',2017,2017,'DIESEL','MANUAL',2184.00,130.00,102000.00,'Dizzling Silver',7,2,'SECOND_OWNER','POOR','National Insurance','third_party','2026-11-05','valid','Gandhinagar','Gujarat','India','382016','Draft entry, photos and documents still to be added.',890000.00,0,'draft',NULL,NULL,NULL,'2026-09-18 20:10:00','2026-09-18 20:10:00',NULL);
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
  `whatsapp_number` varchar(20) DEFAULT NULL,
  `preferred_contact_method` enum('PHONE','EMAIL','WHATSAPP') NOT NULL,
  `contact_visibility` enum('PUBLIC','BUYERS_ONLY','PRIVATE') NOT NULL,
  `is_visible` tinyint(1) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_contacts_user_id` (`user_id`),
  KEY `ix_contacts_id` (`id`),
  KEY `ix_contacts_address_id` (`address_id`),
  CONSTRAINT `contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `contacts_ibfk_2` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
INSERT INTO `contacts` VALUES (1,4,1,'9825010001','WHATSAPP','PUBLIC',1,'2026-08-27 10:05:00','2026-08-27 10:05:00',NULL),(2,5,2,'9825010002','PHONE','BUYERS_ONLY',1,'2026-08-27 10:05:00','2026-08-27 10:05:00',NULL),(3,6,3,'9825010003','WHATSAPP','BUYERS_ONLY',1,'2026-08-27 10:05:00','2026-08-27 10:05:00',NULL),(4,9,4,'9825010006','EMAIL','PRIVATE',0,'2026-08-27 10:05:00','2026-08-27 10:05:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (2,3,2,'2026-09-10 14:54:06'),(3,3,3,'2026-09-10 14:56:42'),(4,3,7,'2026-09-10 14:57:55'),(5,3,5,'2026-09-10 15:22:30'),(6,3,18,'2026-09-10 10:15:00'),(7,3,19,'2026-09-11 11:15:00'),(8,3,23,'2026-09-12 12:15:00'),(9,3,22,'2026-09-13 13:15:00'),(10,3,24,'2026-09-14 14:15:00'),(11,9,18,'2026-09-15 15:15:00'),(12,9,21,'2026-09-16 16:15:00'),(13,9,28,'2026-09-17 17:15:00'),(14,10,19,'2026-09-10 18:15:00'),(15,10,25,'2026-09-11 19:15:00'),(16,10,29,'2026-09-12 10:15:00');
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
  `subject` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('OPEN','CONTACTED','CLOSED') DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiries`
--

LOCK TABLES `inquiries` WRITE;
/*!40000 ALTER TABLE `inquiries` DISABLE KEYS */;
INSERT INTO `inquiries` VALUES (1,11,9,7,'Is the price negotiable?','Hi, I like the City ZX. Is there any room on the price and is the service history complete?','CONTACTED','2026-09-15 19:00:00','2026-09-15 19:00:00'),(2,15,10,5,'Test drive availability','Can I schedule a test drive on Saturday morning in Ahmedabad?','OPEN','2026-09-17 09:10:00','2026-09-17 09:10:00'),(3,13,3,7,'Battery health report','Do you have the battery health report from the service centre?','CONTACTED','2026-09-16 14:20:00','2026-09-16 14:20:00'),(4,18,9,8,'Insurance transfer','Will the current insurance be transferred to the buyer?','CLOSED','2026-09-08 10:50:00','2026-09-08 10:50:00');
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
  `message` text NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `inquiry_id` (`inquiry_id`),
  KEY `sender_id` (`sender_id`),
  KEY `ix_inquiry_messages_id` (`id`),
  CONSTRAINT `inquiry_messages_ibfk_1` FOREIGN KEY (`inquiry_id`) REFERENCES `inquiries` (`id`),
  CONSTRAINT `inquiry_messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry_messages`
--

LOCK TABLES `inquiry_messages` WRITE;
/*!40000 ALTER TABLE `inquiry_messages` DISABLE KEYS */;
INSERT INTO `inquiry_messages` VALUES (1,1,9,'Hi, I like the City ZX. Is there any room on the price and is the service history complete?','2026-09-15 19:00:00'),(2,1,7,'Hello Neha! The service history is complete, I can share the records. The price is fixed, but I can include a set of mats and a dashcam.','2026-09-15 20:10:00'),(3,1,9,'That works, thank you. I will visit on Sunday.','2026-09-15 20:32:00'),(4,2,10,'Can I schedule a test drive on Saturday morning in Ahmedabad?','2026-09-17 09:10:00'),(5,3,3,'Do you have the battery health report from the service centre?','2026-09-16 14:20:00'),(6,3,7,'Yes, I will upload the report. Battery health is 97% as of last month.','2026-09-16 16:45:00'),(7,4,9,'Will the current insurance be transferred to the buyer?','2026-09-08 10:50:00'),(8,4,8,'Yes, the policy has a NCB benefit and I will assist with the transfer.','2026-09-08 12:15:00'),(9,3,3,'Ok, Thank You','2026-09-20 12:34:52');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listing_views`
--

LOCK TABLES `listing_views` WRITE;
/*!40000 ALTER TABLE `listing_views` DISABLE KEYS */;
INSERT INTO `listing_views` VALUES (1,8,3,'2026-09-12 01:40:00'),(2,9,3,'2026-09-13 02:40:00'),(3,13,3,'2026-09-14 03:40:00'),(4,14,3,'2026-09-15 04:40:00'),(5,12,3,'2026-09-16 05:40:00'),(6,8,9,'2026-09-17 06:40:00'),(7,11,9,'2026-09-18 07:40:00'),(8,9,10,'2026-09-12 08:40:00'),(9,15,10,'2026-09-13 09:40:00');
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
  `listing_type` enum('SALE','RESALE') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `asking_price` decimal(15,2) NOT NULL,
  `negotiable` tinyint(1) DEFAULT NULL,
  `listing_status` enum('DRAFT','ACTIVE','RESERVED','SOLD','EXPIRED','CANCELLED','REMOVED') DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
INSERT INTO `listings` VALUES (1,7,2,'RESALE','2023 Tata Nexon Petrol Automatic','Excellent-condition Tata Nexon with 22,000 km, single owner, automatic transmission, complete service history, and well-maintained interior and exterior.',925000.00,1,'ACTIVE','2026-09-10 11:38:31','2027-01-31 23:59:59',100,'2026-09-10 11:32:50','2026-09-21 17:42:06',NULL),(2,1,3,'SALE','2023 Tata Nexon Petrol Automatic','Excellent-condition Tata Nexon with 22,000 km, single owner, automatic transmission, complete service history, and well-maintained interior and exterior.',925000.00,1,'ACTIVE','2026-09-10 11:36:45','2027-01-31 23:59:59',93,'2026-09-10 11:35:10','2026-09-21 17:42:06',NULL),(3,13,1,'SALE','2023 Kia Seltos HTX Turbo - Excellent Condition','Single-owner Kia Seltos with low mileage, automatic transmission and premium features.',1680000.00,1,'ACTIVE','2026-09-12 11:20:41','2026-12-11 11:20:41',233,'2026-09-12 11:20:41','2026-09-21 17:42:06',NULL),(4,14,1,'SALE','2022 Skoda Kushaq Style DSG - Well Maintained','Well maintained Skoda Kushaq with DSG automatic transmission and complete service records.',1490000.00,1,'ACTIVE','2026-09-12 11:20:41','2026-12-11 11:20:41',187,'2026-09-12 11:20:41','2026-09-21 17:42:06',NULL),(5,15,1,'SALE','2024 Volkswagen Virtus GT Plus - Low Mileage','Nearly new Virtus GT Plus with very low mileage, premium features and excellent condition.',1785000.00,1,'ACTIVE','2026-09-12 11:20:41','2026-12-11 11:20:41',322,'2026-09-12 11:20:41','2026-09-21 17:42:06',NULL),(6,16,1,'SALE','2022 MG Hector Sharp Pro Automatic','Spacious MG Hector with connected technology, automatic transmission and good maintenance history.',1540000.00,1,'ACTIVE','2026-09-12 11:20:41','2026-12-11 11:20:41',269,'2026-09-12 11:20:41','2026-09-21 17:42:06',NULL),(7,17,1,'SALE','2024 Maruti Suzuki Baleno Alpha - Low Mileage','Low-mileage Baleno Alpha with excellent condition, modern features and efficient petrol engine.',875000.00,1,'ACTIVE','2026-09-12 11:20:41','2026-12-11 11:20:41',359,'2026-09-12 11:20:41','2026-09-21 17:42:06',NULL),(8,18,4,'RESALE','2021 Tata Harrier Adventure Diesel MT - Single Owner','Single-owner Harrier with full service history at the authorised workshop. Comfortable highway car with plenty of torque.',1425000.00,1,'ACTIVE','2026-08-29 10:00:00','2026-12-31 23:59:59',119,'2026-08-29 10:00:00','2026-09-20 18:03:10',NULL),(9,19,5,'RESALE','2020 Hyundai Creta SX Diesel MT - Well Maintained','Well-kept Creta diesel, two owners, all tyres replaced last year. Rear camera and touchscreen working perfectly.',1180000.00,1,'ACTIVE','2026-08-30 12:00:00','2026-12-31 23:59:59',98,'2026-08-30 12:00:00','2026-09-20 18:03:10',NULL),(10,20,6,'RESALE','2019 Maruti Suzuki Swift VXi - First Owner','Reliable city hatchback, first owner, regular servicing and excellent fuel economy.',465000.00,1,'ACTIVE','2026-08-31 09:30:00','2026-12-31 23:59:59',152,'2026-08-31 09:30:00','2026-09-20 18:07:28',NULL),(11,21,7,'RESALE','2022 Honda City ZX CVT - Low Mileage','Low-mileage City ZX with sunroof and Honda Sensing. Garage-kept and never modified.',1275000.00,0,'ACTIVE','2026-09-01 16:00:00','2026-12-31 23:59:59',189,'2026-09-01 16:00:00','2026-09-20 18:03:24',NULL),(12,22,8,'RESALE','2021 Mahindra Thar LX Diesel 4x4 - Hard Top','4x4 Thar hard-top, lightly used for weekend drives. Genuine accessories, no off-road abuse.',1495000.00,1,'ACTIVE','2026-09-02 12:30:00','2026-12-31 23:59:59',314,'2026-09-02 12:30:00','2026-09-20 18:08:28',NULL),(13,23,7,'RESALE','2023 Tata Nexon EV Long Range - With Home Charger','Long-range Nexon EV with home charger included. Battery health verified at service centre.',1325000.00,1,'ACTIVE','2026-09-03 10:45:00','2026-12-31 23:59:59',207,'2026-09-03 10:45:00','2026-09-20 18:03:09',NULL),(14,24,4,'SALE','2023 Toyota Urban Cruiser Hyryder Strong Hybrid','Strong-hybrid Hyryder with outstanding mileage. Still under manufacturer warranty.',1780000.00,0,'ACTIVE','2026-09-04 13:30:00','2026-12-31 23:59:59',165,'2026-09-04 13:30:00','2026-09-20 18:03:09',NULL),(15,25,5,'RESALE','2022 Hyundai Venue S(O) Turbo DCT','Fun-to-drive turbo Venue with DCT gearbox, sunroof and connected car features.',985000.00,1,'ACTIVE','2026-09-05 10:15:00','2026-12-31 23:59:59',97,'2026-09-05 10:15:00','2026-09-21 17:08:57',NULL),(16,26,6,'RESALE','2018 Toyota Innova Crysta GX Diesel - 7 Seater','Seven-seat family Innova with recent clutch and suspension work. Accident-free.',1340000.00,1,'ACTIVE','2026-09-06 17:00:00','2026-12-31 23:59:59',148,'2026-09-06 17:00:00','2026-09-21 17:08:57',NULL),(17,27,7,'RESALE','2021 Maruti Suzuki Dzire ZXi AGS','Easy-to-drive AMT Dzire, ideal first car or city commuter.',640000.00,1,'ACTIVE','2026-09-07 12:20:00','2026-12-31 23:59:59',80,'2026-09-07 12:20:00','2026-09-21 17:08:57',NULL),(18,28,8,'RESALE','2022 Mahindra XUV700 AX7 Petrol AT - 7 Seater','Loaded AX7 with ADAS, panoramic sunroof and 7 seats. Immaculate condition.',1895000.00,1,'ACTIVE','2026-09-08 14:40:00','2026-12-31 23:59:59',267,'2026-09-08 14:40:00','2026-09-21 17:08:57',NULL),(19,29,4,'RESALE','2020 Maruti Suzuki Swift ZXi CNG','Company-fitted CNG Swift with very low running cost. Service records available.',545000.00,1,'ACTIVE','2026-09-09 11:10:00','2026-12-31 23:59:59',172,'2026-09-09 11:10:00','2026-09-21 17:42:06',NULL),(20,30,5,'RESALE','2021 Tata Tiago XZ+ AMT - Sold','Neat Tiago AMT with new tyres and fresh service. Sold through CarZen.',595000.00,0,'SOLD','2026-08-28 10:00:00',NULL,204,'2026-08-28 10:00:00','2026-08-28 10:00:00',NULL);
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
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `notification_type` varchar(100) DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `reference_type` varchar(100) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_notifications_id` (`id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,9,'Order request sent','Your request for the 2021 Tata Harrier was sent to the seller.','order',1,'order',1,'2026-09-16 10:30:00'),(2,4,'New order request','Neha Trivedi requested to buy your 2021 Tata Harrier.','order',1,'order',0,'2026-09-16 10:31:00'),(3,10,'Order confirmed','The seller confirmed your order for the 2020 Hyundai Creta.','order',2,'order',0,'2026-09-14 16:00:00'),(4,5,'Order confirmed','You confirmed Karan Joshi\'s order for the 2020 Hyundai Creta.','order',2,'order',1,'2026-09-14 16:00:00'),(5,3,'Order in progress','Your order for the Toyota Urban Cruiser Hyryder is now being processed.','order',3,'order',0,'2026-09-11 09:00:00'),(6,3,'Order rejected','The seller rejected your offer for the Maruti Suzuki Dzire.','order',6,'order',0,'2026-09-13 20:00:00'),(7,3,'Seller replied','The seller replied to your inquiry about the Nexon EV battery report.','inquiry',3,'inquiry',1,'2026-09-16 16:45:00'),(8,3,'Price dropped on a favourite','The asking price of a car you saved has changed.','favorite',9,'listing',1,'2026-09-17 08:00:00'),(9,9,'Purchase completed','Your purchase of the 2021 Tata Tiago is complete. Congratulations!','order',4,'order',1,'2026-09-09 17:00:00'),(10,5,'Your car was sold','Your 2021 Tata Tiago was sold to Neha Trivedi.','order',4,'order',1,'2026-09-09 17:00:00'),(11,8,'Car awaiting approval','Your Tata Safari is waiting for admin approval.','listing',31,'car',0,'2026-09-17 18:21:00'),(12,6,'Car rejected','Your Hyundai Creta was rejected: the RC photo is unreadable.','listing',32,'car',0,'2026-09-12 12:00:00'),(13,1,'Car awaiting approval','A newly submitted Tata Safari is waiting for admin approval.','admin',31,'car',0,'2026-09-17 18:20:00'),(14,1,'New report','A listing report about the Toyota Innova Crysta needs review.','admin',16,'listing',0,'2026-09-18 10:00:00'),(15,7,'New inquiry message','You received a new message in an inquiry conversation.','inquiry',3,'inquiry',0,'2026-09-20 12:34:52'),(16,8,'Car approved','Your car has been approved and can now be published as a listing.','listing',31,'car',0,'2026-09-20 14:18:59'),(17,8,'New order received','A buyer placed an order for 2022 Mahindra XUV700 AX7 Petrol AT - 7 Seater.','order',8,'order',0,'2026-09-20 18:10:02'),(18,11,'Order created','Your order for 2022 Mahindra XUV700 AX7 Petrol AT - 7 Seater is pending seller confirmation.','order',8,'order',0,'2026-09-20 18:10:02'),(19,11,'Order updated by admin','An administrator changed your order for 2022 Mahindra XUV700 AX7 Petrol AT - 7 Seater to confirmed.','admin',8,'order',0,'2026-09-21 13:12:37'),(20,8,'Order updated by admin','An administrator changed the order for 2022 Mahindra XUV700 AX7 Petrol AT - 7 Seater to confirmed.','admin',8,'order',0,'2026-09-21 13:12:37'),(21,6,'Car approved','Your car has been approved and can now be published as a listing.','listing',32,'car',0,'2026-09-21 13:26:22');
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
  `status` enum('PENDING','CONFIRMED','PROCESSING','COMPLETED','CANCELLED','REJECTED') NOT NULL,
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED') NOT NULL,
  `notes` text,
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,8,18,9,4,1400000.00,'PENDING','PENDING','Interested - can I inspect the car this weekend?','2026-09-16 10:30:00','2026-09-16 10:30:00',NULL),(2,9,19,10,5,1170000.00,'CONFIRMED','PENDING','Please hold the car until Friday.','2026-09-14 15:10:00','2026-09-14 15:10:00',NULL),(3,14,24,3,4,1780000.00,'PROCESSING','PARTIAL','Token amount paid. Paperwork in progress.','2026-09-10 11:45:00','2026-09-10 11:45:00',NULL),(4,20,30,9,5,595000.00,'COMPLETED','PAID','Payment done, RC transfer completed.','2026-09-01 09:20:00','2026-09-09 17:00:00','2026-09-09 17:00:00'),(5,19,29,10,4,545000.00,'CANCELLED','PENDING','Changed my mind, found another option.','2026-09-12 13:05:00','2026-09-12 13:05:00',NULL),(6,17,27,3,7,610000.00,'REJECTED','PENDING','Offer below asking price.','2026-09-13 18:25:00','2026-09-13 18:25:00',NULL),(7,12,22,3,8,1495000.00,'PENDING','PENDING',NULL,'2026-09-18 12:00:00','2026-09-18 12:00:00',NULL),(8,18,28,11,8,1895000.00,'CONFIRMED','PENDING','I like this Car','2026-09-20 18:10:02','2026-09-21 13:12:37',NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ownership_history`
--

DROP TABLE IF EXISTS `ownership_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ownership_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `car_id` bigint NOT NULL,
  `owner_id` bigint NOT NULL,
  `ownership_number` int NOT NULL,
  `ownership_type` enum('FIRST_OWNER','SECOND_OWNER','THIRD_OWNER','FOURTH_OR_MORE') DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `sale_date` date DEFAULT NULL,
  `purchase_price` decimal(15,2) DEFAULT NULL,
  `sale_price` decimal(15,2) DEFAULT NULL,
  `purchase_location` varchar(150) DEFAULT NULL,
  `sale_location` varchar(150) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `owner_id` (`owner_id`),
  KEY `ix_ownership_history_id` (`id`),
  CONSTRAINT `ownership_history_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `ownership_history_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ownership_history`
--

LOCK TABLES `ownership_history` WRITE;
/*!40000 ALTER TABLE `ownership_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `ownership_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `currency` varchar(10) DEFAULT NULL,
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `provider_transaction_id` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED') DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `ix_payments_id` (`id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  `feature_name` varchar(100) NOT NULL,
  `feature_value` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prediction_id` (`prediction_id`),
  KEY `ix_prediction_features_id` (`id`),
  CONSTRAINT `prediction_features_ibfk_1` FOREIGN KEY (`prediction_id`) REFERENCES `price_predictions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  `prediction_status` enum('REQUESTED','COMPLETED','FAILED') DEFAULT NULL,
  `predicted_price` decimal(15,2) DEFAULT NULL,
  `minimum_price` decimal(15,2) DEFAULT NULL,
  `maximum_price` decimal(15,2) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `model_name` varchar(150) DEFAULT NULL,
  `model_version` varchar(100) DEFAULT NULL,
  `prediction_input` json DEFAULT NULL,
  `prediction_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `user_id` (`user_id`),
  KEY `ix_price_predictions_id` (`id`),
  CONSTRAINT `price_predictions_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `price_predictions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  `reason` varchar(255) NOT NULL,
  `description` text,
  `status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reporter_id` (`reporter_id`),
  KEY `listing_id` (`listing_id`),
  KEY `car_id` (`car_id`),
  KEY `ix_reports_id` (`id`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,9,16,26,'wrong_information','The odometer photo shows a different reading than the listing.','pending','2026-09-18 09:55:00',NULL),(2,10,19,29,'suspicious_seller','Seller asked for an advance payment outside the platform.','under_review','2026-09-16 21:15:00',NULL),(3,3,10,20,'duplicate_listing','This car appears to be posted twice.','resolved','2026-09-11 08:30:00','2026-09-12 10:00:00');
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
  `rating` int NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `review_text` text,
  `is_visible` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `car_id` (`car_id`),
  KEY `listing_id` (`listing_id`),
  KEY `ix_reviews_id` (`id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_centers`
--

DROP TABLE IF EXISTS `service_centers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_centers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `owner_id` bigint DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `contact_person` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address_line_1` varchar(255) DEFAULT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  KEY `ix_service_centers_id` (`id`),
  CONSTRAINT `service_centers_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_centers`
--

LOCK TABLES `service_centers` WRITE;
/*!40000 ALTER TABLE `service_centers` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_centers` ENABLE KEYS */;
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
  `item_name` varchar(150) NOT NULL,
  `quantity` int DEFAULT NULL,
  `unit_cost` decimal(15,2) DEFAULT NULL,
  `total_cost` decimal(15,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_record_id` (`service_record_id`),
  KEY `ix_service_items_id` (`id`),
  CONSTRAINT `service_items_ibfk_1` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_items`
--

LOCK TABLES `service_items` WRITE;
/*!40000 ALTER TABLE `service_items` DISABLE KEYS */;
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
  `service_type` varchar(150) NOT NULL,
  `service_date` date NOT NULL,
  `odometer_reading` decimal(12,2) DEFAULT NULL,
  `service_cost` decimal(15,2) DEFAULT NULL,
  `parts_cost` decimal(15,2) DEFAULT NULL,
  `labor_cost` decimal(15,2) DEFAULT NULL,
  `description` text,
  `next_service_date` date DEFAULT NULL,
  `next_service_mileage` decimal(12,2) DEFAULT NULL,
  `status` enum('SCHEDULED','COMPLETED','CANCELLED') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `service_center_id` (`service_center_id`),
  KEY `ix_service_records_id` (`id`),
  CONSTRAINT `service_records_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `service_records_ibfk_2` FOREIGN KEY (`service_center_id`) REFERENCES `service_centers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_records`
--

LOCK TABLES `service_records` WRITE;
/*!40000 ALTER TABLE `service_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_records` ENABLE KEYS */;
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
  `car_id` bigint NOT NULL,
  `buyer_id` bigint NOT NULL,
  `seller_id` bigint NOT NULL,
  `final_price` decimal(15,2) NOT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') DEFAULT NULL,
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED') DEFAULT NULL,
  `transaction_status` enum('INITIATED','COMPLETED','CANCELLED','FAILED') DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `car_id` (`car_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  KEY `ix_transactions_id` (`id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `transactions_ibfk_3` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `transactions_ibfk_4` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `role` enum('BUYER','SELLER','RESELLER','SERVICE_PROVIDER','USER','ADMIN') NOT NULL,
  `status` enum('ACTIVE','INACTIVE','BLOCKED') NOT NULL,
  `profile_image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_email` (`email`),
  UNIQUE KEY `ix_users_username` (`username`),
  UNIQUE KEY `phone_number` (`phone_number`),
  KEY `ix_users_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin','admin','admin@gmail.com','$2b$12$i9Nl7Yqm7Oie5TMmmlw2WONCqhy4kgXv7yrpKiJpaQxdaAa3xExhe','1354567890','ADMIN','ACTIVE',NULL,'2026-09-10 10:18:45','2026-09-10 10:18:45',NULL),(2,'resellers','resellers','resellers','resellers@gmail.com','$2b$12$MTEbYetWt3sEIBcst1LDueqSnJ0gI/Sb5JQFWHf4daYGOedU17Eum','9696544250','USER','BLOCKED',NULL,'2026-09-10 10:48:15','2026-09-21 13:11:02',NULL),(3,'User','user','user','user@gmail.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9876543210','USER','ACTIVE',NULL,'2026-09-10 10:53:45','2026-09-19 13:04:15',NULL),(4,'Rohan','Mehta','demo_rohan','demo.rohan@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010001','USER','ACTIVE',NULL,'2026-08-20 10:12:00','2026-08-20 10:12:00',NULL),(5,'Priya','Shah','demo_priya','demo.priya@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010002','USER','ACTIVE',NULL,'2026-08-21 11:02:00','2026-08-21 11:02:00',NULL),(6,'Amit','Patel','demo_amit','demo.amit@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010003','USER','ACTIVE',NULL,'2026-08-22 09:40:00','2026-08-22 09:40:00',NULL),(7,'Sneha','Desai','demo_sneha','demo.sneha@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010004','USER','ACTIVE',NULL,'2026-08-23 16:25:00','2026-08-23 16:25:00',NULL),(8,'Vikram','Rathod','demo_vikram','demo.vikram@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010005','USER','ACTIVE',NULL,'2026-08-24 12:10:00','2026-08-24 12:10:00',NULL),(9,'Neha','Trivedi','demo_neha','demo.neha@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010006','USER','ACTIVE',NULL,'2026-08-25 18:30:00','2026-08-25 18:30:00',NULL),(10,'Karan','Joshi','demo_karan','demo.karan@example.com','$2b$12$51crjIGbYzvqJI98jv1cJO6RgMCecx/Pj.YfaWjjk8j44rCyPT2Fm','9825010007','USER','ACTIVE',NULL,'2026-08-26 14:05:00','2026-08-26 14:05:00',NULL),(11,'vishal',NULL,'vishal08','vishal@gmail.com','$2b$12$xrk7lL49kQA7Ii7dspwKNuGTCC0B0vuGMKpGKYtIdzkZZj3Q5e6Mm',NULL,'USER','ACTIVE',NULL,'2026-09-20 18:06:10','2026-09-20 18:06:10',NULL);
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

-- Dump completed on 2026-09-21 23:25:39
