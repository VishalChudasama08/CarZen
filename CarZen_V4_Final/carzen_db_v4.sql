-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: carzen_db_v4
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.4

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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,1,'12, Shreeji Apartments','Satellite Road','Near Iscon Cross Roads','Ahmedabad','Gujarat','India','380015',NULL,NULL,1,'2026-06-02 10:00:00','2026-06-02 10:00:00',NULL),(2,1,'48, Orchid Villas','Bopal','Behind Shilp Circle','Ahmedabad','Gujarat','India','380058',NULL,NULL,0,'2026-06-02 10:00:00','2026-06-02 10:00:00',NULL),(3,2,'7, Sunrise Residency','Adajan','Opposite Reliance Mall','Surat','Gujarat','India','395009',NULL,NULL,1,'2026-06-02 10:00:00','2026-06-02 10:00:00',NULL),(4,4,'B-14, Shivalik Heights','Satellite Road','Near Iscon Cross Roads','Ahmedabad','Gujarat','India','380015',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(5,4,'Shop 3, Maninagar Market','Maninagar','Opposite Railway Station','Ahmedabad','Gujarat','India','380008',NULL,NULL,0,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(6,5,'22, Lane 5, Koregaon Park',NULL,'Behind German Bakery','Pune','Maharashtra','India','411001',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(7,6,'5, Road No. 36, Jubilee Hills',NULL,'Near Peddamma Temple','Hyderabad','Telangana','India','500033',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(8,7,'301, Lakeview Residency','Hiranandani Gardens, Powai','Next to Powai Lake','Mumbai','Maharashtra','India','400076',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(9,7,'Unit 12, Prime Business Park','Andheri East','Near Metro Station','Mumbai','Maharashtra','India','400069',NULL,NULL,0,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(10,8,'44, Sector 21','Dwarka','Near Sector 21 Metro','New Delhi','Delhi','India','110075',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(11,9,'9, Alkapuri Society','Alkapuri','Opposite Genda Circle','Vadodara','Gujarat','India','390007',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(12,10,'18, MG Road',NULL,'Near Trinity Circle','Bengaluru','Karnataka','India','560001',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL),(13,11,'77, C-Scheme',NULL,'Near Statue Circle','Jaipur','Rajasthan','India','302001',NULL,NULL,1,'2026-01-06 10:00:00','2026-01-06 10:00:00',NULL);
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alembic_version`
--

DROP TABLE IF EXISTS `alembic_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL,
  PRIMARY KEY (`version_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_brands`
--

LOCK TABLES `car_brands` WRITE;
/*!40000 ALTER TABLE `car_brands` DISABLE KEYS */;
INSERT INTO `car_brands` VALUES (1,'Maruti Suzuki','maruti-suzuki','India',NULL,'India\'s largest carmaker, known for efficient and affordable hatchbacks, sedans and SUVs.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(2,'Hyundai','hyundai','South Korea',NULL,'South Korean manufacturer with a strong lineup of SUVs, sedans and hatchbacks in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(3,'Tata Motors','tata-motors','India',NULL,'Indian manufacturer offering safe, feature-rich SUVs and electric vehicles.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(4,'Honda','honda','Japan',NULL,'Japanese manufacturer known for refined engines and reliable sedans.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(5,'Toyota','toyota','Japan',NULL,'Japanese automobile manufacturer with a broad India passenger-vehicle range.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(6,'Mahindra','mahindra','India',NULL,'Indian manufacturer known for SUVs, utility vehicles and electric vehicles.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(7,'Kia','kia','South Korea',NULL,'South Korean automobile manufacturer with SUVs, MPVs and electric vehicles in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(8,'Skoda','skoda','Czech Republic',NULL,'Czech automobile manufacturer offering sedans and SUVs in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(9,'Ford','ford','United States',NULL,'American automobile manufacturer; India catalogue retained for historical and used-car listings.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(10,'Volkswagen','volkswagen','Germany',NULL,'German automobile manufacturer offering sedans, SUVs and performance models in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(11,'MG','mg','United Kingdom',NULL,'MG brand offering feature-rich SUVs, EVs and MPVs in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(12,'BMW','bmw','Germany',NULL,'German luxury manufacturer.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_features`
--

LOCK TABLES `car_features` WRITE;
/*!40000 ALTER TABLE `car_features` DISABLE KEYS */;
INSERT INTO `car_features` VALUES (1,1,'Touchscreen Infotainment','7-inch with Android Auto and Apple CarPlay','2026-09-28 10:00:00'),(2,1,'Airbags','Dual front airbags with ABS','2026-09-28 10:00:00'),(3,2,'Sunroof','Panoramic sunroof','2026-09-28 10:00:00'),(4,2,'Safety','6 airbags, ESC, hill assist','2026-09-28 10:00:00'),(5,2,'Climate Control','Dual-zone automatic AC','2026-09-28 10:00:00'),(6,3,'Safety','6 airbags, 5-star crash rating','2026-09-28 10:00:00'),(7,3,'Connectivity','10.25-inch touchscreen with wireless Android Auto','2026-09-28 10:00:00'),(8,4,'Transmission','CVT with paddle shifters','2026-09-28 10:00:00'),(9,4,'Comfort','Leather seats, rear AC vents','2026-09-28 10:00:00'),(10,5,'Parking','Rear camera with sensors','2026-09-28 10:00:00'),(11,6,'Battery','30.2 kWh, 8-year battery warranty','2026-09-28 10:00:00'),(12,6,'Charging','DC fast-charging capable, home charger included','2026-09-28 10:00:00'),(13,11,'Sunroof','Electric','2026-09-15 10:30:00'),(14,11,'Safety','7 airbags, hill-hold, 360-degree camera','2026-09-15 10:30:00'),(15,11,'Seats','Leather, ventilated front seats','2026-09-15 10:30:00'),(16,11,'Infotainment','8-inch touchscreen with Android Auto','2026-09-15 10:30:00'),(17,11,'Drive','4x2 diesel automatic','2026-09-15 10:30:00'),(18,12,'Infotainment','7-inch touchscreen with Apple CarPlay','2026-09-15 10:30:00'),(19,12,'Safety','Dual airbags with ABS','2026-09-15 10:30:00'),(20,12,'Mileage','~21 km/l (ARAI)','2026-09-15 10:30:00'),(21,13,'Sunroof','Single-pane electric sunroof','2026-09-15 10:30:00'),(22,13,'Infotainment','7-inch touchscreen with rear camera','2026-09-15 10:30:00'),(23,13,'Climate Control','Automatic AC','2026-09-15 10:30:00'),(24,13,'Safety','Dual airbags, ABS with EBD','2026-09-15 10:30:00'),(25,14,'Safety','5-star Global NCAP rated, dual airbags','2026-09-15 10:30:00'),(26,14,'Infotainment','6.5-inch touchscreen with Harman audio','2026-09-15 10:30:00'),(27,14,'Headlamps','Projector headlamps with DRLs','2026-09-15 10:30:00'),(28,14,'Roof','Dual-tone floating roof','2026-09-15 10:30:00'),(29,15,'Transmission','CVT with paddle shifters','2026-09-15 10:30:00'),(30,15,'Sunroof','Electric sunroof','2026-09-15 10:30:00'),(31,15,'Comfort','Rear AC vents, leather seats','2026-09-15 10:30:00'),(32,15,'Safety','Dual airbags, ABS','2026-09-15 10:30:00'),(33,16,'Roof','Hard top','2026-09-15 10:30:00'),(34,16,'Drive','4x4 with low-range gearbox','2026-09-15 10:30:00'),(35,16,'Infotainment','7-inch touchscreen with Adrenox connect','2026-09-15 10:30:00'),(36,16,'Accessories','Alloy wheels, bumper protectors','2026-09-15 10:30:00'),(37,17,'Seating','7-seater with captain seats','2026-09-02 10:30:00'),(38,17,'Climate Control','Dual-zone automatic AC','2026-09-02 10:30:00'),(39,17,'Safety','7 airbags, ABS','2026-09-02 10:30:00'),(40,17,'Infotainment','7-inch touchscreen with navigation','2026-09-02 10:30:00'),(41,18,'Infotainment','10.25-inch touchscreen with UVO connect','2026-09-15 10:30:00'),(42,18,'Seats','Ventilated front seats','2026-09-15 10:30:00'),(43,18,'Safety','6 airbags, ESC, hill assist','2026-09-15 10:30:00'),(44,18,'Audio','Bose 7-speaker system','2026-09-15 10:30:00'),(45,19,'Sunroof','Electric sunroof','2026-09-15 10:30:00'),(46,19,'Climate Control','Automatic AC with rear vents','2026-09-15 10:30:00'),(47,19,'Infotainment','7-inch touchscreen with Android Auto','2026-09-15 10:30:00'),(48,19,'Safety','6 airbags, ABS','2026-09-15 10:30:00'),(49,20,'Infotainment','7-inch SmartPlay Studio','2026-09-15 10:30:00'),(50,20,'Safety','Dual airbags, ABS','2026-09-15 10:30:00'),(51,20,'Mileage','~21 km/l (ARAI)','2026-09-15 10:30:00'),(52,21,'Seating','7-seater','2026-09-15 10:30:00'),(53,21,'Safety','Dual airbags, ABS','2026-09-15 10:30:00'),(54,21,'Drive','Front-wheel drive diesel','2026-09-15 10:30:00'),(55,22,'Battery','30.2 kWh, 8-year battery warranty','2026-09-15 10:30:00'),(56,22,'Charging','DC fast charging, home charger included','2026-09-15 10:30:00'),(57,22,'Range','~300 km real-world','2026-09-15 10:30:00'),(58,22,'Infotainment','7-inch touchscreen with connected-car app','2026-09-15 10:30:00'),(59,23,'Drive','4x4 with terrain management system','2026-09-15 10:30:00'),(60,23,'Seating','7-seater with leather seats','2026-09-15 10:30:00'),(61,23,'Safety','7 airbags, ESC','2026-09-15 10:30:00'),(62,23,'Sunroof','Panoramic sunroof','2026-09-15 10:30:00'),(63,24,'Sunroof','Electric sunroof','2026-09-15 10:30:00'),(64,24,'Audio','Harman Kardon surround sound','2026-09-15 10:30:00'),(65,24,'Seats','Leather, memory driver seat','2026-09-15 10:30:00'),(66,24,'Display','10.25-inch iDrive with navigation','2026-09-15 10:30:00');
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
  `media_type` enum('IMAGE','VIDEO') NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_media`
--

LOCK TABLES `car_media` WRITE;
/*!40000 ALTER TABLE `car_media` DISABLE KEYS */;
INSERT INTO `car_media` VALUES (1,1,'IMAGE','/uploads/cars/1_maruti_swift_2021_front.jpg',NULL,'1_maruti_swift_2021_front.jpg',148639,0,1,'2026-06-05 11:00:00',NULL),(2,1,'IMAGE','/uploads/cars/1_maruti_swift_2021_rear.jpg',NULL,'1_maruti_swift_2021_rear.jpg',111926,1,0,'2026-06-05 11:00:00',NULL),(3,2,'IMAGE','/uploads/cars/2_hyundai_creta_2020_front.jpg',NULL,'2_hyundai_creta_2020_front.jpg',116221,0,1,'2026-06-05 11:00:00',NULL),(4,2,'IMAGE','/uploads/cars/2_hyundai_creta_2020_rear.jpg',NULL,'2_hyundai_creta_2020_rear.jpg',80448,1,0,'2026-06-05 11:00:00',NULL),(5,2,'IMAGE','/uploads/cars/2_hyundai_creta_2020_front_wide.jpg',NULL,'2_hyundai_creta_2020_front_wide.jpg',110298,2,0,'2026-06-05 11:00:00',NULL),(6,3,'IMAGE','/uploads/cars/3_tata_nexon_2022_front.jpg',NULL,'3_tata_nexon_2022_front.jpg',52825,0,1,'2026-06-05 11:00:00',NULL),(7,3,'IMAGE','/uploads/cars/3_tata_nexon_2022_front_side.jpg',NULL,'3_tata_nexon_2022_front_side.jpg',40578,1,0,'2026-06-05 11:00:00',NULL),(8,4,'IMAGE','/uploads/cars/4_honda_city_2019_front.jpg',NULL,'4_honda_city_2019_front.jpg',32311,0,1,'2026-06-05 11:00:00',NULL),(9,4,'IMAGE','/uploads/cars/4_honda_city_2019_side.jpg',NULL,'4_honda_city_2019_side.jpg',38442,1,0,'2026-06-05 11:00:00',NULL),(10,4,'IMAGE','/uploads/cars/4_honda_city_2019_rear.jpg',NULL,'4_honda_city_2019_rear.jpg',95591,2,0,'2026-06-05 11:00:00',NULL),(11,5,'IMAGE','/uploads/cars/5_maruti_swift_2023_front.jpg',NULL,'5_maruti_swift_2023_front.jpg',80811,0,1,'2026-06-05 11:00:00',NULL),(12,5,'IMAGE','/uploads/cars/5_maruti_swift_2023_front_side.jpg',NULL,'5_maruti_swift_2023_front_side.jpg',235674,1,0,'2026-06-05 11:00:00',NULL),(13,6,'IMAGE','/uploads/cars/6_tata_nexon_ev_2022_front.jpg',NULL,'6_tata_nexon_ev_2022_front.jpg',50004,0,1,'2026-06-05 11:00:00',NULL),(14,6,'IMAGE','/uploads/cars/6_tata_nexon_ev_2022_side.jpg',NULL,'6_tata_nexon_ev_2022_side.jpg',59845,1,0,'2026-06-05 11:00:00',NULL),(15,6,'IMAGE','/uploads/cars/6_tata_nexon_ev_2022_rear.jpg',NULL,'6_tata_nexon_ev_2022_rear.jpg',141873,2,0,'2026-06-05 11:00:00',NULL),(16,7,'IMAGE','/uploads/cars/7_hyundai_creta_2018_front.jpg',NULL,'7_hyundai_creta_2018_front.jpg',124517,0,1,'2026-06-05 11:00:00',NULL),(17,7,'IMAGE','/uploads/cars/7_hyundai_creta_2018_front_side.jpg',NULL,'7_hyundai_creta_2018_front_side.jpg',87229,1,0,'2026-06-05 11:00:00',NULL),(18,7,'IMAGE','/uploads/cars/7_hyundai_creta_2018_rear.jpg',NULL,'7_hyundai_creta_2018_rear.jpg',120814,2,0,'2026-06-05 11:00:00',NULL),(19,8,'IMAGE','/uploads/cars/8_maruti_swift_2015_front.jpg',NULL,'8_maruti_swift_2015_front.jpg',47336,0,1,'2026-06-05 11:00:00',NULL),(20,8,'IMAGE','/uploads/cars/8_maruti_swift_2015_front_side.jpg',NULL,'8_maruti_swift_2015_front_side.jpg',95345,1,0,'2026-06-05 11:00:00',NULL),(21,8,'IMAGE','/uploads/cars/8_maruti_swift_2015_front_close.jpg',NULL,'8_maruti_swift_2015_front_close.jpg',147250,2,0,'2026-06-05 11:00:00',NULL),(22,9,'IMAGE','/uploads/cars/9_honda_city_2020_front.jpg',NULL,'9_honda_city_2020_front.jpg',85658,0,1,'2026-06-05 11:00:00',NULL),(23,9,'IMAGE','/uploads/cars/9_honda_city_2020_side.jpg',NULL,'9_honda_city_2020_side.jpg',120478,1,0,'2026-06-05 11:00:00',NULL),(24,10,'IMAGE','/uploads/cars/10_maruti_swift_2018_front.jpg',NULL,'10_maruti_swift_2018_front.jpg',24703,0,1,'2026-06-05 11:00:00',NULL),(25,10,'IMAGE','/uploads/cars/10_maruti_swift_2018_front_side.jpg',NULL,'10_maruti_swift_2018_front_side.jpg',56741,1,0,'2026-06-05 11:00:00',NULL),(26,10,'IMAGE','/uploads/cars/10_maruti_swift_2018_rear.jpg',NULL,'10_maruti_swift_2018_rear.jpg',132718,2,0,'2026-06-05 11:00:00',NULL),(27,11,'IMAGE','/uploads/cars/11_toyota_fortuner_2021_front.jpg',NULL,'11_toyota_fortuner_2021_front.jpg',123384,0,1,'2026-09-15 11:00:00',NULL),(28,11,'IMAGE','/uploads/cars/11_toyota_fortuner_2021_rear.jpg',NULL,'11_toyota_fortuner_2021_rear.jpg',133200,1,0,'2026-09-15 11:00:00',NULL),(29,11,'IMAGE','/uploads/cars/11_toyota_fortuner_2021_front_wide.jpg',NULL,'11_toyota_fortuner_2021_front_wide.jpg',78272,2,0,'2026-09-15 11:00:00',NULL),(30,12,'IMAGE','/uploads/cars/12_maruti_swift_2019_front.jpg',NULL,'12_maruti_swift_2019_front.jpg',83332,0,1,'2026-09-15 11:00:00',NULL),(31,12,'IMAGE','/uploads/cars/12_maruti_swift_2019_rear.jpg',NULL,'12_maruti_swift_2019_rear.jpg',57814,1,0,'2026-09-15 11:00:00',NULL),(32,13,'IMAGE','/uploads/cars/13_hyundai_creta_2018_front.jpg',NULL,'13_hyundai_creta_2018_front.jpg',143739,0,1,'2026-07-01 10:00:00',NULL),(33,13,'IMAGE','/uploads/cars/13_hyundai_creta_2018_side.jpg',NULL,'13_hyundai_creta_2018_side.jpg',96933,1,0,'2026-07-01 10:00:00',NULL),(34,13,'IMAGE','/uploads/cars/13_hyundai_creta_2018_rear.jpg',NULL,'13_hyundai_creta_2018_rear.jpg',177702,2,0,'2026-07-01 10:00:00',NULL),(35,14,'IMAGE','/uploads/cars/14_tata_nexon_2018_front.jpg',NULL,'14_tata_nexon_2018_front.jpg',318669,0,1,'2026-09-15 11:00:00',NULL),(36,14,'IMAGE','/uploads/cars/14_tata_nexon_2018_side.jpg',NULL,'14_tata_nexon_2018_side.jpg',93958,1,0,'2026-09-15 11:00:00',NULL),(37,14,'IMAGE','/uploads/cars/14_tata_nexon_2018_rear.jpg',NULL,'14_tata_nexon_2018_rear.jpg',89138,2,0,'2026-09-15 11:00:00',NULL),(38,15,'IMAGE','/uploads/cars/15_honda_city_2018_front.jpg',NULL,'15_honda_city_2018_front.jpg',66638,0,1,'2026-09-15 11:00:00',NULL),(39,15,'IMAGE','/uploads/cars/15_honda_city_2018_rear.jpg',NULL,'15_honda_city_2018_rear.jpg',146609,1,0,'2026-09-15 11:00:00',NULL),(40,16,'IMAGE','/uploads/cars/16_mahindra_thar_2021_front.jpg',NULL,'16_mahindra_thar_2021_front.jpg',212578,0,1,'2026-09-15 11:00:00',NULL),(41,16,'IMAGE','/uploads/cars/16_mahindra_thar_2021_front_side.jpg',NULL,'16_mahindra_thar_2021_front_side.jpg',109236,1,0,'2026-09-15 11:00:00',NULL),(42,16,'IMAGE','/uploads/cars/16_mahindra_thar_2021_rear.jpg',NULL,'16_mahindra_thar_2021_rear.jpg',137604,2,0,'2026-09-15 11:00:00',NULL),(43,17,'IMAGE','/uploads/cars/17_toyota_innova_crysta_2018_front.jpg',NULL,'17_toyota_innova_crysta_2018_front.jpg',93932,0,1,'2026-09-01 10:00:00',NULL),(44,17,'IMAGE','/uploads/cars/17_toyota_innova_crysta_2018_side.jpg',NULL,'17_toyota_innova_crysta_2018_side.jpg',193876,1,0,'2026-09-01 10:00:00',NULL),(45,17,'IMAGE','/uploads/cars/17_toyota_innova_crysta_2018_front_close.jpg',NULL,'17_toyota_innova_crysta_2018_front_close.jpg',59737,2,0,'2026-09-01 10:00:00',NULL),(46,18,'IMAGE','/uploads/cars/18_kia_seltos_2020_front.jpg',NULL,'18_kia_seltos_2020_front.jpg',81943,0,1,'2026-09-15 11:00:00',NULL),(47,18,'IMAGE','/uploads/cars/18_kia_seltos_2020_front_side.jpg',NULL,'18_kia_seltos_2020_front_side.jpg',97444,1,0,'2026-09-15 11:00:00',NULL),(48,18,'IMAGE','/uploads/cars/18_kia_seltos_2020_rear.jpg',NULL,'18_kia_seltos_2020_rear.jpg',116946,2,0,'2026-09-15 11:00:00',NULL),(49,19,'IMAGE','/uploads/cars/19_hyundai_verna_2018_front.jpg',NULL,'19_hyundai_verna_2018_front.jpg',84156,0,1,'2026-09-15 11:00:00',NULL),(50,19,'IMAGE','/uploads/cars/19_hyundai_verna_2018_rear.jpg',NULL,'19_hyundai_verna_2018_rear.jpg',74629,1,0,'2026-09-15 11:00:00',NULL),(51,20,'IMAGE','/uploads/cars/20_maruti_baleno_2018_front.jpg',NULL,'20_maruti_baleno_2018_front.jpg',180085,0,1,'2026-09-15 11:00:00',NULL),(52,20,'IMAGE','/uploads/cars/20_maruti_baleno_2018_front_side.jpg',NULL,'20_maruti_baleno_2018_front_side.jpg',73573,1,0,'2026-09-15 11:00:00',NULL),(53,20,'IMAGE','/uploads/cars/20_maruti_baleno_2018_rear.jpg',NULL,'20_maruti_baleno_2018_rear.jpg',58883,2,0,'2026-09-15 11:00:00',NULL),(54,21,'IMAGE','/uploads/cars/21_mahindra_xuv500_2015_front.jpg',NULL,'21_mahindra_xuv500_2015_front.jpg',128230,0,1,'2026-09-15 11:00:00',NULL),(55,21,'IMAGE','/uploads/cars/21_mahindra_xuv500_2015_side.jpg',NULL,'21_mahindra_xuv500_2015_side.jpg',88368,1,0,'2026-09-15 11:00:00',NULL),(56,21,'IMAGE','/uploads/cars/21_mahindra_xuv500_2015_front_side.jpg',NULL,'21_mahindra_xuv500_2015_front_side.jpg',314241,2,0,'2026-09-15 11:00:00',NULL),(57,22,'IMAGE','/uploads/cars/22_tata_nexon_ev_2021_front.jpg',NULL,'22_tata_nexon_ev_2021_front.jpg',106672,0,1,'2026-09-15 11:00:00',NULL),(58,22,'IMAGE','/uploads/cars/22_tata_nexon_ev_2021_rear.jpg',NULL,'22_tata_nexon_ev_2021_rear.jpg',167578,1,0,'2026-09-15 11:00:00',NULL),(59,22,'IMAGE','/uploads/cars/22_tata_nexon_ev_2021_front_close.jpg',NULL,'22_tata_nexon_ev_2021_front_close.jpg',149355,2,0,'2026-09-15 11:00:00',NULL),(60,23,'IMAGE','/uploads/cars/23_ford_endeavour_2019_front.jpg',NULL,'23_ford_endeavour_2019_front.jpg',196862,0,1,'2026-09-15 11:00:00',NULL),(61,23,'IMAGE','/uploads/cars/23_ford_endeavour_2019_front_wide.jpg',NULL,'23_ford_endeavour_2019_front_wide.jpg',155533,1,0,'2026-09-15 11:00:00',NULL),(62,24,'IMAGE','/uploads/cars/24_bmw_3_series_2017_front.jpg',NULL,'24_bmw_3_series_2017_front.jpg',210138,0,1,'2026-09-15 11:00:00',NULL),(63,24,'IMAGE','/uploads/cars/24_bmw_3_series_2017_front_side.jpg',NULL,'24_bmw_3_series_2017_front_side.jpg',110212,1,0,'2026-09-15 11:00:00',NULL),(64,24,'IMAGE','/uploads/cars/24_bmw_3_series_2017_rear.jpg',NULL,'24_bmw_3_series_2017_rear.jpg',189683,2,0,'2026-09-15 11:00:00',NULL),(65,25,'IMAGE','/uploads/cars/25_maruti_dzire_2018_front.jpg',NULL,'25_maruti_dzire_2018_front.jpg',137525,0,1,'2026-05-01 10:00:00',NULL),(66,25,'IMAGE','/uploads/cars/25_maruti_dzire_2018_side.jpg',NULL,'25_maruti_dzire_2018_side.jpg',43462,1,0,'2026-05-01 10:00:00',NULL),(67,25,'IMAGE','/uploads/cars/25_maruti_dzire_2018_front_wide.jpg',NULL,'25_maruti_dzire_2018_front_wide.jpg',109822,2,0,'2026-05-01 10:00:00',NULL),(68,26,'IMAGE','/uploads/cars/26_hyundai_elite_i20_2017_front.jpg',NULL,'26_hyundai_elite_i20_2017_front.jpg',86394,0,1,'2026-02-20 10:00:00',NULL),(69,26,'IMAGE','/uploads/cars/26_hyundai_elite_i20_2017_side.jpg',NULL,'26_hyundai_elite_i20_2017_side.jpg',174507,1,0,'2026-02-20 10:00:00',NULL),(70,26,'IMAGE','/uploads/cars/26_hyundai_elite_i20_2017_front_side.jpg',NULL,'26_hyundai_elite_i20_2017_front_side.jpg',202974,2,0,'2026-02-20 10:00:00',NULL),(71,27,'IMAGE','/uploads/cars/27_mahindra_scorpio_2017_front.jpg',NULL,'27_mahindra_scorpio_2017_front.jpg',52214,0,1,'2026-02-01 10:00:00',NULL),(72,27,'IMAGE','/uploads/cars/27_mahindra_scorpio_2017_side.jpg',NULL,'27_mahindra_scorpio_2017_side.jpg',82970,1,0,'2026-02-01 10:00:00',NULL),(73,27,'IMAGE','/uploads/cars/27_mahindra_scorpio_2017_rear.jpg',NULL,'27_mahindra_scorpio_2017_rear.jpg',64432,2,0,'2026-02-01 10:00:00',NULL);
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
  `body_type` enum('HATCHBACK','SEDAN','SUV','MUV','MPV','COUPE','CONVERTIBLE','PICKUP','MINIVAN','OTHER') DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_models`
--

LOCK TABLES `car_models` WRITE;
/*!40000 ALTER TABLE `car_models` DISABLE KEYS */;
INSERT INTO `car_models` VALUES (1,1,'Swift','maruti-swift','HATCHBACK',5,'A sporty, fuel-efficient hatchback that is a favourite for city driving.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(2,2,'Creta','hyundai-creta','SUV',5,'A comfortable and well-equipped compact SUV.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(3,3,'Nexon','tata-nexon','SUV',5,'A compact SUV with a five-star safety reputation, available as petrol and electric.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(4,4,'City','honda-city','SEDAN',5,'A spacious, refined mid-size sedan.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(5,3,'Punch','tata-punch','SUV',5,'Compact SUV from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(6,3,'Harrier','tata-harrier','SUV',5,'Mid-size SUV from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(7,3,'Safari','tata-safari','SUV',6,'Three-row SUV from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(8,3,'Tiago','tata-tiago','HATCHBACK',5,'Compact hatchback from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(9,3,'Altroz','tata-altroz','HATCHBACK',5,'Premium hatchback from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(10,3,'Tigor','tata-tigor','SEDAN',5,'Compact sedan from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(11,3,'Sierra','tata-sierra','SUV',5,'SUV model from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(12,3,'Curvv','tata-curvv','SUV',5,'SUV coupe-style model from Tata Motors.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(13,4,'Amaze','honda-amaze','SEDAN',5,'Compact sedan from Honda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(14,4,'Elevate','honda-elevate','SUV',5,'Mid-size SUV from Honda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(15,4,'City Hatchback','honda-city-hatchback','HATCHBACK',5,'Hatchback model in the City family.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(16,2,'Venue','hyundai-venue','SUV',5,'Compact SUV from Hyundai.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(17,2,'i20','hyundai-i20','HATCHBACK',5,'Premium hatchback from Hyundai.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(18,2,'Verna','hyundai-verna','SEDAN',5,'Mid-size sedan from Hyundai.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(19,2,'Tucson','hyundai-tucson','SUV',5,'Premium SUV from Hyundai.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(20,2,'Alcazar','hyundai-alcazar','SUV',7,'Three-row SUV from Hyundai.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(21,1,'Baleno','maruti-baleno','HATCHBACK',5,'Premium hatchback from Maruti Suzuki.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(22,1,'Dzire','maruti-dzire','SEDAN',5,'Compact sedan from Maruti Suzuki.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(23,1,'Brezza','maruti-brezza','SUV',5,'Compact SUV from Maruti Suzuki.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(24,1,'Fronx','maruti-fronx','SUV',5,'Compact crossover SUV from Maruti Suzuki.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(25,1,'Grand Vitara','maruti-grand-vitara','SUV',5,'SUV from Maruti Suzuki.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(26,5,'Glanza','toyota-glanza','HATCHBACK',5,'Premium hatchback sold by Toyota in India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(27,5,'Urban Cruiser Taisor','toyota-urban-cruiser-taisor','SUV',5,'Compact crossover SUV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(28,5,'Rumion','toyota-rumion','MUV',7,'Seven-seat MPV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(29,5,'Urban Cruiser Hyryder','toyota-urban-cruiser-hyryder','SUV',5,'Mid-size SUV with petrol and strong-hybrid options.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(30,5,'Innova Crysta','toyota-innova-crysta','MUV',7,'Diesel MPV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(31,5,'Innova Hycross','toyota-innova-hycross','MUV',7,'Premium MPV with petrol and hybrid powertrains.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(32,5,'Fortuner','toyota-fortuner','SUV',7,'Body-on-frame SUV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(33,5,'Hilux','toyota-hilux','PICKUP',5,'Lifestyle pickup truck from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(34,5,'Camry','toyota-camry','SEDAN',5,'Premium hybrid sedan from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(35,5,'Vellfire','toyota-vellfire','MUV',7,'Luxury MPV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(36,5,'Land Cruiser 300','toyota-land-cruiser-300','SUV',5,'Premium full-size SUV from Toyota.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(37,6,'XUV 3XO','mahindra-xuv-3xo','SUV',5,'Compact SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(38,6,'Thar','mahindra-thar','SUV',4,'Lifestyle off-road SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(39,6,'Thar Roxx','mahindra-thar-roxx','SUV',5,'Five-door lifestyle SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(40,6,'Bolero','mahindra-bolero','SUV',7,'Rugged utility SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(41,6,'Bolero Neo','mahindra-bolero-neo','SUV',7,'Compact body-on-frame SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(42,6,'Scorpio Classic','mahindra-scorpio-classic','SUV',7,'Rugged seven-seat SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(43,6,'Scorpio-N','mahindra-scorpio-n','SUV',7,'Modern body-on-frame SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(44,6,'XUV700','mahindra-xuv700','SUV',7,'Premium family SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(45,6,'XUV400','mahindra-xuv400','SUV',5,'Electric SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(46,6,'BE 6','mahindra-be-6','SUV',5,'Electric SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(47,6,'XEV 9e','mahindra-xev-9e','SUV',5,'Premium electric SUV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(48,6,'Marazzo','mahindra-marazzo','MUV',7,'Seven-seat MPV from Mahindra.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(49,7,'Sonet','kia-sonet','SUV',5,'Compact SUV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(50,7,'Seltos','kia-seltos','SUV',5,'Mid-size SUV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(51,7,'Carens','kia-carens','MUV',7,'Three-row family MPV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(52,7,'Carens Clavis','kia-carens-clavis','MUV',7,'Updated three-row MPV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(53,7,'Carnival','kia-carnival','MUV',7,'Premium MPV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(54,7,'EV6','kia-ev6','SUV',5,'Premium electric crossover from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(55,7,'EV9','kia-ev9','SUV',6,'Large electric SUV from Kia.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(56,8,'Kylaq','skoda-kylaq','SUV',5,'Compact SUV from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(57,8,'Kushaq','skoda-kushaq','SUV',5,'Mid-size SUV from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(58,8,'Slavia','skoda-slavia','SEDAN',5,'Mid-size sedan from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(59,8,'Kodiaq','skoda-kodiaq','SUV',7,'Premium seven-seat SUV from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(60,8,'Octavia RS','skoda-octavia-rs','SEDAN',5,'Performance sedan from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(61,8,'Superb','skoda-superb','SEDAN',5,'Premium sedan from Skoda.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(62,9,'EcoSport','ford-ecosport','SUV',5,'Compact SUV formerly sold by Ford India; useful for used-car listings.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(63,9,'Endeavour','ford-endeavour','SUV',7,'Large SUV formerly sold by Ford India; useful for used-car listings.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(64,9,'Figo','ford-figo','HATCHBACK',5,'Hatchback formerly sold by Ford India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(65,9,'Aspire','ford-aspire','SEDAN',5,'Compact sedan formerly sold by Ford India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(66,9,'Freestyle','ford-freestyle','SUV',5,'Crossover hatchback formerly sold by Ford India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(67,9,'Fiesta','ford-fiesta','SEDAN',5,'Sedan formerly sold by Ford India.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(68,10,'Taigun','volkswagen-taigun','SUV',5,'Compact SUV from Volkswagen.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(69,10,'Virtus','volkswagen-virtus','SEDAN',5,'Mid-size sedan from Volkswagen.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(70,10,'Tiguan R-Line','volkswagen-tiguan-r-line','SUV',5,'Premium SUV from Volkswagen.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(71,10,'Tayron','volkswagen-tayron','SUV',5,'Premium SUV from Volkswagen.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(72,10,'Golf GTI','volkswagen-golf-gti','HATCHBACK',5,'Performance hatchback from Volkswagen.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(73,11,'Comet EV','mg-comet-ev','HATCHBACK',4,'Compact electric city car from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(74,11,'Windsor EV','mg-windsor-ev','HATCHBACK',5,'Electric crossover from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(75,11,'Astor','mg-astor','SUV',5,'Mid-size SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(76,11,'Hector','mg-hector','SUV',5,'Mid-size SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(77,11,'Hector Plus','mg-hector-plus','SUV',7,'Three-row SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(78,11,'ZS EV','mg-zs-ev','SUV',5,'Electric SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(79,11,'Gloster','mg-gloster','SUV',7,'Premium full-size SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(80,11,'Majestor','mg-majestor','SUV',7,'Premium large SUV from MG.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(81,6,'XUV500','mahindra-xuv500','SUV',7,'XUV500 - popular choice on the Indian used-car market.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(82,3,'Nexon EV','tata-nexon-ev','SUV',5,'Nexon EV - popular choice on the Indian used-car market.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(83,12,'3 Series','bmw-3-series','SEDAN',5,'3 Series - popular choice on the Indian used-car market.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(84,2,'Elite i20','hyundai-elite-i20','HATCHBACK',5,'Elite i20 - popular choice on the Indian used-car market.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(85,6,'Scorpio','mahindra-scorpio','SUV',7,'Scorpio - popular choice on the Indian used-car market.',1,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_variants`
--

LOCK TABLES `car_variants` WRITE;
/*!40000 ALTER TABLE `car_variants` DISABLE KEYS */;
INSERT INTO `car_variants` VALUES (1,1,'VXi','PETROL','MANUAL',1197.00,82.00,5,749000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(2,1,'ZXi AMT','PETROL','AMT',1197.00,82.00,5,849000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(3,2,'SX Diesel','DIESEL','MANUAL',1493.00,113.00,5,1600000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(4,3,'XZ+ Petrol AMT','PETROL','AMT',1199.00,118.00,5,1050000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(5,4,'V CVT','PETROL','CVT',1498.00,119.00,5,1200000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(6,82,'EV Empowered','ELECTRIC','AUTOMATIC',NULL,143.00,5,1500000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(7,11,'Pure','PETROL','MANUAL',1199.00,118.00,5,1100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(8,11,'Adventure','PETROL','MANUAL',1199.00,118.00,5,1300000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(9,11,'Accomplished+','PETROL','DCT',1199.00,118.00,5,1600000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(10,5,'Pure','PETROL','MANUAL',1199.00,87.00,5,650000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(11,5,'Adventure AMT','PETROL','AMT',1199.00,87.00,5,800000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(12,5,'Creative+','PETROL','AMT',1199.00,87.00,5,950000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(13,6,'Pure','DIESEL','MANUAL',1956.00,168.00,5,1500000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(14,6,'Adventure+','DIESEL','AUTOMATIC',1956.00,168.00,5,2000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(15,7,'Pure','DIESEL','MANUAL',1956.00,168.00,6,1600000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(16,7,'Adventure+','DIESEL','AUTOMATIC',1956.00,168.00,6,2100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(17,8,'XE','PETROL','MANUAL',1199.00,84.00,5,550000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(18,8,'XZA AMT','PETROL','AMT',1199.00,84.00,5,700000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(19,9,'Pure','PETROL','MANUAL',1199.00,84.00,5,700000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(20,9,'XZ+ Petrol DCA','PETROL','DCT',1199.00,84.00,5,950000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(21,10,'XE','PETROL','MANUAL',1199.00,84.00,5,600000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(22,10,'XZA+','PETROL','AMT',1199.00,84.00,5,750000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(23,12,'Pure+','PETROL','MANUAL',1199.00,118.00,5,1000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(24,12,'Creative+','PETROL','DCT',1199.00,118.00,5,1400000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(25,13,'S','PETROL','MANUAL',1199.00,89.00,5,800000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(26,13,'VX CVT','PETROL','CVT',1199.00,89.00,5,1000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(27,14,'SV','PETROL','MANUAL',1498.00,119.00,5,1200000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(28,14,'ZX CVT','PETROL','CVT',1498.00,119.00,5,1600000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(29,16,'S','PETROL','MANUAL',1197.00,81.00,5,800000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(30,16,'SX(O) DCT','PETROL','DCT',998.00,118.00,5,1300000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(31,17,'Sportz','PETROL','MANUAL',1197.00,87.00,5,750000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(32,17,'Asta(O) IVT','PETROL','CVT',1197.00,87.00,5,1000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(33,18,'EX','PETROL','MANUAL',1497.00,113.00,5,1100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(34,18,'SX(O) DCT','PETROL','DCT',1482.00,158.00,5,1700000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(35,21,'Sigma','PETROL','MANUAL',1197.00,88.00,5,700000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(36,21,'Alpha AMT','PETROL','AMT',1197.00,88.00,5,950000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(37,22,'VXi','PETROL','MANUAL',1197.00,80.00,5,700000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(38,22,'ZXi AMT','PETROL','AMT',1197.00,80.00,5,850000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(39,23,'LXi','PETROL','MANUAL',1197.00,102.00,5,850000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(40,23,'ZXi AT','PETROL','AUTOMATIC',1197.00,102.00,5,1200000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(41,26,'G','PETROL','MANUAL',1197.00,88.00,5,750000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(42,26,'V AMT','PETROL','AMT',1197.00,88.00,5,950000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(43,27,'S','PETROL','MANUAL',1197.00,89.00,5,800000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(44,27,'V Turbo AT','PETROL','AUTOMATIC',998.00,99.00,5,1250000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(45,28,'G','PETROL','MANUAL',1462.00,101.00,7,1100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(46,28,'V AT','PETROL','AUTOMATIC',1462.00,101.00,7,1350000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(47,29,'G Hybrid','HYBRID','AUTOMATIC',1490.00,114.00,5,1900000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(48,29,'S','PETROL','MANUAL',1462.00,103.00,5,1300000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(49,30,'GX','DIESEL','MANUAL',2393.00,148.00,7,2050000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(50,30,'ZX','DIESEL','AUTOMATIC',2393.00,148.00,7,2750000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(51,31,'GX','PETROL','AUTOMATIC',1987.00,172.00,7,2000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(52,31,'ZX Hybrid','HYBRID','AUTOMATIC',1987.00,184.00,7,3000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(53,32,'4x2 Diesel MT','DIESEL','MANUAL',2755.00,201.00,7,3400000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(54,32,'4x4 Diesel AT','DIESEL','AUTOMATIC',2755.00,201.00,7,4200000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(55,33,'Standard','DIESEL','MANUAL',2755.00,201.00,5,3200000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(56,33,'High AT','DIESEL','AUTOMATIC',2755.00,201.00,5,3650000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(57,34,'Hybrid','HYBRID','AUTOMATIC',2487.00,227.00,5,4900000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(58,35,'VIP','HYBRID','AUTOMATIC',2487.00,190.00,7,12000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(59,36,'ZX','DIESEL','AUTOMATIC',3346.00,304.00,5,22000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(60,32,'Legender 4x2 AT','DIESEL','AUTOMATIC',2755.00,201.00,7,3506000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(61,2,'SX 1.6 CRDi (O)','DIESEL','MANUAL',1582.00,126.00,5,1420000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(62,3,'XZ+ Petrol','PETROL','MANUAL',1198.00,110.00,5,925000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(63,4,'VX CVT Petrol','PETROL','CVT',1497.00,119.00,5,1300000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(64,38,'LX Hard Top Diesel AT','DIESEL','AUTOMATIC',2184.00,130.00,4,1650000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(65,30,'2.4 ZX MT','DIESEL','MANUAL',2393.00,148.00,7,2250000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(66,50,'HTX 1.5 Petrol','PETROL','MANUAL',1497.00,115.00,5,1300000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(67,18,'SX 1.6 VTVT','PETROL','MANUAL',1591.00,121.00,5,1100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(68,21,'Zeta 1.2','PETROL','MANUAL',1197.00,83.00,5,760000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(69,81,'W8 FWD','DIESEL','MANUAL',2179.00,140.00,7,1350000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(70,82,'XZ+ Prime','ELECTRIC','AUTOMATIC',NULL,129.00,5,1560000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(71,63,'Titanium 3.2 4x4 AT','DIESEL','AUTOMATIC',3198.00,197.00,7,3100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(72,83,'320d Luxury Line','DIESEL','AUTOMATIC',1995.00,188.00,5,4100000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(73,84,'Asta 1.2','PETROL','MANUAL',1197.00,83.00,5,800000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(74,85,'S10 2WD','DIESEL','MANUAL',2179.00,120.00,7,1150000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(75,15,'S MT','PETROL','MANUAL',1199.00,89.00,5,589000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(76,15,'V CVT','PETROL','CVT',1199.00,89.00,5,689000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(77,19,'Platinum 2.0 Petrol AT','PETROL','AUTOMATIC',1999.00,154.00,5,2999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(78,19,'Signature 2.0 Diesel AT','DIESEL','AUTOMATIC',1995.00,183.00,5,3499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(79,20,'Prestige 1.5 Turbo DCT','PETROL','DCT',1482.00,158.00,7,1799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(80,20,'Signature (O) 1.5 Diesel AT','DIESEL','AUTOMATIC',1493.00,114.00,7,2099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(81,24,'Sigma 1.2','PETROL','MANUAL',1197.00,89.00,5,759000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(82,24,'Delta+ 1.0 Turbo AT','PETROL','AUTOMATIC',998.00,99.00,5,1189000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(83,25,'Delta 1.5 Mild Hybrid','PETROL','MANUAL',1462.00,102.00,5,1099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(84,25,'Alpha+ Strong Hybrid','HYBRID','AUTOMATIC',1490.00,114.00,5,1999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(85,37,'MX2 Pro 1.2 Turbo','PETROL','MANUAL',1197.00,110.00,5,899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(86,37,'AX5 1.5 Diesel AMT','DIESEL','AMT',1497.00,115.00,5,1399000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(87,39,'MX3 Diesel MT','DIESEL','MANUAL',2184.00,152.00,5,1299000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(88,39,'AX7 L 4x4 Diesel AT','DIESEL','AUTOMATIC',2184.00,172.00,5,2099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(89,40,'B4 Diesel','DIESEL','MANUAL',1493.00,75.00,7,979000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(90,40,'B6 (O) Diesel','DIESEL','MANUAL',1493.00,75.00,7,1089000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(91,41,'N4 Diesel','DIESEL','MANUAL',1493.00,100.00,7,999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(92,41,'N10 (O) Diesel','DIESEL','MANUAL',1493.00,100.00,7,1239000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(93,42,'S 2WD Diesel','DIESEL','MANUAL',2184.00,132.00,7,1359000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(94,42,'S11 2WD Diesel','DIESEL','MANUAL',2184.00,132.00,7,1699000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(95,43,'Z4 2.0 Petrol MT','PETROL','MANUAL',1997.00,200.00,7,1349000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(96,43,'Z8 L 4x4 Diesel AT','DIESEL','AUTOMATIC',2184.00,172.00,7,2499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(97,44,'MX 2.0 Petrol MT','PETROL','MANUAL',1999.00,200.00,7,1399000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(98,44,'AX7 L Diesel AT','DIESEL','AUTOMATIC',2184.00,185.00,7,2399000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(99,45,'EC Pro 34.5 kWh','ELECTRIC','AUTOMATIC',NULL,148.00,5,1599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(100,45,'EL Pro 39.4 kWh','ELECTRIC','AUTOMATIC',NULL,148.00,5,1749000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(101,46,'Pack One 59 kWh','ELECTRIC','AUTOMATIC',NULL,228.00,5,1899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(102,46,'Pack Three 79 kWh','ELECTRIC','AUTOMATIC',NULL,282.00,5,2699000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(103,47,'Pack Two 59 kWh','ELECTRIC','AUTOMATIC',NULL,228.00,5,2149000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(104,47,'Pack Three 79 kWh','ELECTRIC','AUTOMATIC',NULL,282.00,5,3099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(105,48,'M4+ Diesel','DIESEL','MANUAL',1497.00,121.00,7,1459000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(106,48,'M6+ Diesel','DIESEL','MANUAL',1497.00,121.00,7,1599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(107,49,'HTE 1.2 Petrol','PETROL','MANUAL',1197.00,82.00,5,799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(108,49,'HTX 1.5 Diesel AT','DIESEL','AUTOMATIC',1493.00,114.00,5,1499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(109,51,'Premium 1.5 Petrol','PETROL','MANUAL',1497.00,113.00,7,1099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(110,51,'Luxury Plus 1.5 Diesel AT','DIESEL','AUTOMATIC',1493.00,114.00,7,1999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(111,52,'HTK 1.5 Petrol','PETROL','MANUAL',1497.00,113.00,7,1199000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(112,52,'HTX+ 1.5 Diesel AT','DIESEL','AUTOMATIC',1493.00,114.00,7,2099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(113,53,'Prestige 2.2 Diesel AT','DIESEL','AUTOMATIC',2151.00,193.00,7,6390000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(114,53,'Limousine Plus 2.2 Diesel AT','DIESEL','AUTOMATIC',2151.00,193.00,7,6559000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(115,54,'GT Line RWD 77.4 kWh','ELECTRIC','AUTOMATIC',NULL,229.00,5,6095000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(116,54,'GT Line AWD 77.4 kWh','ELECTRIC','AUTOMATIC',NULL,325.00,5,6495000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(117,55,'GT Line AWD 99.8 kWh','ELECTRIC','AUTOMATIC',NULL,379.00,6,13000000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(118,56,'Classic 1.0 TSI MT','PETROL','MANUAL',999.00,114.00,5,789000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(119,56,'Prestige 1.0 TSI AT','PETROL','AUTOMATIC',999.00,114.00,5,1199000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(120,57,'Active 1.0 TSI MT','PETROL','MANUAL',999.00,114.00,5,1089000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(121,57,'Style 1.5 TSI DSG','PETROL','DCT',1498.00,148.00,5,1799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(122,58,'Classic 1.0 TSI MT','PETROL','MANUAL',999.00,114.00,5,1069000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(123,58,'Style 1.5 TSI DSG','PETROL','DCT',1498.00,148.00,5,1799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(124,59,'Sportline 2.0 TSI DSG','PETROL','DCT',1984.00,190.00,7,4599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(125,59,'L&K 2.0 TSI DSG','PETROL','DCT',1984.00,190.00,7,4999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(126,60,'RS 2.0 TSI DSG','PETROL','DCT',1984.00,265.00,5,4999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(127,61,'L&K 2.0 TSI DSG','PETROL','DCT',1984.00,190.00,5,5499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(128,61,'Sportline 2.0 TSI DSG','PETROL','DCT',1984.00,190.00,5,5599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(129,62,'Trend 1.5 Petrol','PETROL','MANUAL',1497.00,121.00,5,899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(130,62,'Titanium 1.5 Diesel','DIESEL','MANUAL',1498.00,99.00,5,1199000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(131,64,'Ambiente 1.2 Petrol','PETROL','MANUAL',1196.00,96.00,5,599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(132,64,'Titanium 1.5 AT','PETROL','AUTOMATIC',1499.00,123.00,5,799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(133,65,'Trend 1.2 Petrol','PETROL','MANUAL',1196.00,96.00,5,699000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(134,65,'Titanium+ 1.5 Diesel','DIESEL','MANUAL',1498.00,99.00,5,899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(135,66,'Trend 1.2 Petrol','PETROL','MANUAL',1194.00,96.00,5,749000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(136,66,'Titanium 1.5 Diesel','DIESEL','MANUAL',1498.00,99.00,5,919000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(137,67,'Titanium 1.5 Petrol','PETROL','MANUAL',1499.00,110.00,5,799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(138,67,'Titanium 1.5 TDCi','DIESEL','MANUAL',1498.00,89.00,5,899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(139,68,'Comfortline 1.0 TSI MT','PETROL','MANUAL',999.00,114.00,5,1139000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(140,68,'GT 1.5 TSI DSG','PETROL','DCT',1498.00,148.00,5,1899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(141,69,'Comfortline 1.0 TSI MT','PETROL','MANUAL',999.00,114.00,5,1149000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(142,69,'GT Plus 1.5 TSI DSG','PETROL','DCT',1498.00,148.00,5,1949000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(143,70,'R-Line 2.0 TSI DSG','PETROL','DCT',1984.00,190.00,5,4999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(144,71,'R-Line 2.0 TSI DSG 4Motion','PETROL','DCT',1984.00,201.00,5,5499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(145,72,'GTI 2.0 TSI DSG','PETROL','DCT',1984.00,265.00,5,5299000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(146,73,'Executive 17.3 kWh','ELECTRIC','AUTOMATIC',NULL,41.00,4,699000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(147,73,'Exclusive FC 17.3 kWh','ELECTRIC','AUTOMATIC',NULL,41.00,4,899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(148,74,'Excite 38 kWh','ELECTRIC','AUTOMATIC',NULL,134.00,5,1399000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(149,74,'Essence 38 kWh','ELECTRIC','AUTOMATIC',NULL,134.00,5,1599000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(150,75,'Sprint 1.5 MT','PETROL','MANUAL',1498.00,110.00,5,999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(151,75,'Savvy Pro 1.3 Turbo AT','PETROL','AUTOMATIC',1349.00,140.00,5,1799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(152,76,'Style 1.5 Turbo MT','PETROL','MANUAL',1451.00,143.00,5,1499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(153,76,'Sharp Pro 2.0 Diesel MT','DIESEL','MANUAL',1956.00,170.00,5,1999000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(154,77,'Select Pro 1.5 Turbo MT','PETROL','MANUAL',1451.00,143.00,7,1799000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(155,77,'Sharp Pro 2.0 Diesel MT','DIESEL','MANUAL',1956.00,170.00,7,2299000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(156,78,'Excite Pro 50.3 kWh','ELECTRIC','AUTOMATIC',NULL,174.00,5,1899000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(157,78,'Essence 50.3 kWh','ELECTRIC','AUTOMATIC',NULL,174.00,5,2499000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(158,79,'Super 2.0 Twin Turbo Diesel AT','DIESEL','AUTOMATIC',1996.00,215.00,7,4099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(159,79,'Savvy 4x4 Diesel AT','DIESEL','AUTOMATIC',1996.00,215.00,7,4399000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL),(160,80,'Sharp 2.0 Twin Turbo Diesel AT','DIESEL','AUTOMATIC',1996.00,215.00,7,4099000.00,'2026-01-01 09:00:00','2026-01-01 09:00:00',NULL);
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
  KEY `verified_by_id` (`verified_by_id`),
  KEY `ix_cars_id` (`id`),
  CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `car_variants` (`id`),
  CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`),
  CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`verified_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
INSERT INTO `cars` VALUES (1,1,2,'GJ01DM1101','CZDEMOVIN00000001',2021,2021,'PETROL','MANUAL',1197.00,82.00,34500.00,'Speedy Blue',5,1,'FIRST_OWNER','EXCELLENT','ICICI Lombard','comprehensive','2027-03-14','valid','Ahmedabad','Gujarat','India','380015','Single-owner Swift, regularly serviced at the authorised workshop. Clean interior, no accident history.',560000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(2,3,2,'GJ05DM1102','CZDEMOVIN00000002',2020,2020,'DIESEL','MANUAL',1493.00,113.00,58200.00,'Phantom Black',5,1,'FIRST_OWNER','GOOD','HDFC Ergo','comprehensive','2027-01-22','valid','Surat','Gujarat','India','395009','Well-kept Creta SX diesel with panoramic sunroof, full service records and new tyres.',1250000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(3,4,2,'GJ06DM1103','CZDEMOVIN00000003',2022,2022,'PETROL','AMT',1199.00,118.00,21000.00,'Daytona Grey',5,1,'FIRST_OWNER','EXCELLENT','Tata AIG','comprehensive','2027-06-30','valid','Vadodara','Gujarat','India','390007','Nexon XZ+ with AMT. Under warranty, rear camera, touchscreen infotainment, six airbags.',890000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(4,5,2,'GJ03DM1104','CZDEMOVIN00000004',2019,2019,'PETROL','CVT',1498.00,119.00,47800.00,'Lunar Silver',5,2,'SECOND_OWNER','GOOD','Bajaj Allianz','comprehensive','2026-12-05','valid','Rajkot','Gujarat','India','360001','Smooth Honda City CVT. Second owner, always garaged, service done on time.',780000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(5,2,2,'GJ01DM1105','CZDEMOVIN00000005',2023,2023,'PETROL','AMT',1197.00,82.00,9800.00,'Fire Red',5,1,'FIRST_OWNER','EXCELLENT','New India Assurance','comprehensive','2027-09-10','valid','Ahmedabad','Gujarat','India','380054','Almost-new Swift ZXi AMT with under 10,000 km. Showroom condition.',760000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(6,6,2,'GJ01DM1106','CZDEMOVIN00000006',2022,2022,'ELECTRIC','AUTOMATIC',NULL,143.00,18400.00,'Teal Blue',5,1,'FIRST_OWNER','EXCELLENT','Tata AIG','comprehensive','2027-04-18','valid','Ahmedabad','Gujarat','India','380009','Nexon EV with 8-year battery warranty, home charger included, fast-charging capable.',1320000.00,1,'published',NULL,'2026-09-29 12:00:00',12,'2026-06-05 10:00:00','2026-09-29 12:00:00',NULL),(7,3,2,'GJ05DM1107','CZDEMOVIN00000007',2018,2018,'DIESEL','MANUAL',1493.00,113.00,86400.00,'Sleek Silver',5,2,'SECOND_OWNER','FAIR','Oriental Insurance','third_party','2026-11-30','valid','Surat','Gujarat','India','395007','Creta diesel awaiting admin review - used to demonstrate the approval queue.',900000.00,0,'pending_approval',NULL,NULL,NULL,'2026-06-05 10:00:00','2026-09-28 10:00:00',NULL),(8,1,2,'GJ05DM1108','CZDEMOVIN00000008',2015,2015,'PETROL','MANUAL',1197.00,82.00,121000.00,'Fiery Red',5,3,'THIRD_OWNER','FAIR','United India','third_party','2026-08-01','expired','Surat','Gujarat','India','395002','Older Swift - used to demonstrate a rejected submission.',230000.00,0,'rejected','Insurance has expired and the RC status could not be verified. Please update the documents and resubmit.',NULL,NULL,'2026-06-05 10:00:00','2026-09-28 10:00:00',NULL),(9,5,1,'GJ01DM1109','CZDEMOVIN00000009',2020,2020,'PETROL','CVT',1498.00,119.00,39800.00,'Metallic Blue',5,1,'FIRST_OWNER','GOOD','HDFC Ergo','comprehensive','2027-02-12','valid','Ahmedabad','Gujarat','India','380015','Added for service booking.',NULL,0,'approved',NULL,NULL,NULL,'2026-06-05 10:00:00','2026-09-28 10:00:00',NULL),(10,1,1,'GJ01DM1110','CZDEMOVIN00000010',2018,2018,'PETROL','MANUAL',1197.00,82.00,52300.00,'Red',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-05-01','valid','Ahmedabad','Gujarat','India','380015','Added for service booking.',NULL,0,'approved',NULL,NULL,NULL,'2026-06-05 10:00:00','2026-09-28 10:00:00',NULL),(11,60,4,'GJ01KT4821','CZDEMOVIN00000201',2021,2021,'DIESEL','AUTOMATIC',2755.00,201.00,38500.00,'Attitude Black',7,1,'FIRST_OWNER','EXCELLENT','HDFC Ergo','comprehensive','2027-03-18','valid','Ahmedabad','Gujarat','India','380015','Single-owner Fortuner Legender 4x2 automatic with full Toyota service history. Leather interiors, 360-degree camera and ventilated seats. Never driven off-road.',2850000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(12,1,5,'MH12RS3307','CZDEMOVIN00000202',2019,2019,'PETROL','MANUAL',1197.00,82.00,46200.00,'Solid Fire Red',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-01-09','valid','Pune','Maharashtra','India','411001','Zippy Swift VXi, serviced on time at the authorised workshop. Great first car with low running cost.',515000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(13,61,4,'GJ01HP7745','CZDEMOVIN00000203',2018,2018,'DIESEL','MANUAL',1582.00,126.00,61800.00,'Polar White',5,1,'FIRST_OWNER','GOOD','Bajaj Allianz','comprehensive','2027-02-26','valid','Ahmedabad','Gujarat','India','380015','Creta SX diesel (O) in Polar White. Sunroof, touchscreen, rear camera and new tyres fitted last year.',995000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-07-01 09:00:00','2026-09-20 12:00:00',NULL),(14,62,5,'MH12DN5568','CZDEMOVIN00000204',2018,2018,'PETROL','MANUAL',1198.00,110.00,52300.00,'Flame Blue',5,1,'FIRST_OWNER','GOOD','Tata AIG','comprehensive','2026-12-14','valid','Pune','Maharashtra','India','411001','Nexon XZ+ petrol with a five-star safety rating. Dual-tone roof, projector headlamps and a clean interior.',640000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(15,63,6,'TS09EQ2210','CZDEMOVIN00000205',2018,2018,'PETROL','CVT',1497.00,119.00,58900.00,'Lunar Silver',5,2,'SECOND_OWNER','GOOD','New India Assurance','comprehensive','2026-11-30','valid','Hyderabad','Telangana','India','500033','Honda City VX CVT, smooth and quiet. Second owner, always garaged, service records available.',780000.00,1,'published',NULL,'2026-09-17 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(16,64,6,'TS09FK9086','CZDEMOVIN00000206',2021,2021,'DIESEL','AUTOMATIC',2184.00,130.00,19800.00,'Red Rage',4,1,'FIRST_OWNER','EXCELLENT','Royal Sundaram','comprehensive','2027-06-21','valid','Hyderabad','Telangana','India','500033','New-gen Thar LX hard top diesel automatic. Barely used, with accessory pack and underbody protection.',1490000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(17,65,4,'GJ01JD1953','CZDEMOVIN00000207',2018,2018,'DIESEL','MANUAL',2393.00,148.00,92400.00,'Avant Garde Maroon',7,2,'SECOND_OWNER','GOOD','Oriental Insurance','comprehensive','2026-10-31','valid','Ahmedabad','Gujarat','India','380015','Innova Crysta 2.4 ZX 7-seater, the family workhorse. SOLD through CarZen.',1850000.00,1,'sold',NULL,'2026-09-04 12:00:00',12,'2026-09-01 09:00:00','2026-09-14 17:30:00',NULL),(18,66,5,'MH12TK6642','CZDEMOVIN00000208',2020,2020,'PETROL','MANUAL',1497.00,115.00,31200.00,'Intense Red',5,1,'FIRST_OWNER','EXCELLENT','HDFC Ergo','comprehensive','2027-05-02','valid','Pune','Maharashtra','India','411001','Kia Seltos HTX petrol with connected-car features, ventilated seats and a Bose-style audio setup.',1185000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(19,67,10,'KA01MP4417','CZDEMOVIN00000209',2018,2018,'PETROL','MANUAL',1591.00,121.00,68500.00,'Silky Silver',5,1,'FIRST_OWNER','GOOD','Digit Insurance','comprehensive','2027-01-27','valid','Bengaluru','Karnataka','India','560001','Verna SX 1.6 VTVT with sunroof and rear AC vents. Company-maintained, regular services.',695000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(20,68,10,'KA03NV2290','CZDEMOVIN00000210',2018,2018,'PETROL','MANUAL',1197.00,83.00,44800.00,'Nexa Blue',5,1,'FIRST_OWNER','GOOD','Digit Insurance','comprehensive','2027-04-08','valid','Bengaluru','Karnataka','India','560001','Baleno Zeta 1.2 awaiting admin review - use it to demo the approval queue.',580000.00,0,'pending_approval',NULL,NULL,NULL,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(21,69,6,'TS09BC8801','CZDEMOVIN00000211',2015,2015,'DIESEL','MANUAL',2179.00,140.00,118500.00,'Moondust Silver',7,3,'THIRD_OWNER','FAIR','United India','third_party','2026-08-15','expired','Hyderabad','Telangana','India','500033','XUV500 W8 submitted for review - rejected so you can demo a rejected car.',520000.00,0,'rejected','Insurance has expired and the RC copy is unreadable. Please upload valid documents and resubmit.',NULL,NULL,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(22,70,5,'MH12AX7075','CZDEMOVIN00000212',2021,2021,'ELECTRIC','AUTOMATIC',NULL,129.00,16400.00,'Teal Blue',5,1,'FIRST_OWNER','EXCELLENT','Tata AIG','comprehensive','2027-08-12','valid','Pune','Maharashtra','India','411001','Nexon EV XZ+ Prime with 8-year battery warranty. Home charger included, around 300 km real-world range.',1390000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(23,71,4,'GJ01LM3306','CZDEMOVIN00000213',2019,2019,'DIESEL','AUTOMATIC',3198.00,197.00,71200.00,'Sunset Bronze',7,1,'FIRST_OWNER','GOOD','HDFC Ergo','comprehensive','2027-03-03','valid','Ahmedabad','Gujarat','India','380015','Endeavour Titanium 3.2 4x4 automatic. Approved by CarZen; listing is still a draft.',2150000.00,1,'approved',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(24,72,10,'KA01HV9128','CZDEMOVIN00000214',2017,2017,'DIESEL','AUTOMATIC',1995.00,188.00,62500.00,'Estoril Blue',5,1,'FIRST_OWNER','EXCELLENT','Bajaj Allianz','comprehensive','2026-12-22','valid','Bengaluru','Karnataka','India','560001','BMW 320d Luxury Line with full BMW service history, sunroof and Harman Kardon sound.',2495000.00,1,'published',NULL,'2026-09-20 12:00:00',12,'2026-09-15 10:00:00','2026-09-20 12:00:00',NULL),(25,38,7,'MH02PQ6120','CZDEMOVIN00000215',2018,2018,'PETROL','AMT',1197.00,80.00,41800.00,'Pearl Midnight Blue',5,1,'FIRST_OWNER','GOOD','ICICI Lombard','comprehensive','2027-02-11','valid','Mumbai','Maharashtra','India','400076',NULL,NULL,0,'approved',NULL,NULL,NULL,'2026-05-01 09:00:00','2026-09-20 12:00:00',NULL),(26,73,8,'DL3CAY5402','CZDEMOVIN00000216',2017,2017,'PETROL','MANUAL',1197.00,83.00,57300.00,'Fire Red',5,1,'FIRST_OWNER','GOOD','Digit Insurance','comprehensive','2026-12-05','valid','New Delhi','Delhi','India','110075',NULL,NULL,0,'approved',NULL,NULL,NULL,'2026-02-20 09:00:00','2026-09-20 12:00:00',NULL),(27,74,9,'GJ06BR2718','CZDEMOVIN00000217',2017,2017,'DIESEL','MANUAL',2179.00,120.00,84900.00,'Pearl White',7,1,'FIRST_OWNER','FAIR','Oriental Insurance','comprehensive','2027-01-15','valid','Vadodara','Gujarat','India','390007',NULL,NULL,0,'approved',NULL,NULL,NULL,'2026-02-01 09:00:00','2026-09-20 12:00:00',NULL);
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
  KEY `ix_contacts_id` (`id`),
  KEY `ix_contacts_user_id` (`user_id`),
  KEY `ix_contacts_address_id` (`address_id`),
  CONSTRAINT `contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `contacts_ibfk_2` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
INSERT INTO `contacts` VALUES (1,4,4,'9825011201','WHATSAPP','BUYERS_ONLY',1,'2026-06-02 10:05:00','2026-06-02 10:05:00',NULL),(2,5,6,'9879022202','PHONE','PUBLIC',1,'2026-06-02 10:05:00','2026-06-02 10:05:00',NULL),(3,6,7,'9898033203','WHATSAPP','PUBLIC',1,'2026-06-02 10:05:00','2026-06-02 10:05:00',NULL),(4,10,12,'9687077207','EMAIL','BUYERS_ONLY',1,'2026-06-02 10:05:00','2026-06-02 10:05:00',NULL),(5,2,3,'9876500102','WHATSAPP','BUYERS_ONLY',1,'2026-06-03 10:05:00','2026-06-03 10:05:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (1,1,1,'2026-09-29 13:30:00'),(2,1,3,'2026-09-29 14:40:00'),(3,7,11,'2026-09-21 18:00:00'),(4,7,16,'2026-09-24 12:45:00'),(5,7,22,'2026-09-27 14:00:00'),(6,8,12,'2026-09-24 18:33:00'),(7,8,18,'2026-09-25 18:44:00'),(8,8,24,'2026-09-29 00:00:00'),(9,9,14,'2026-09-27 18:06:00'),(10,9,19,'2026-09-28 18:17:00'),(11,11,13,'2026-09-22 23:00:00'),(12,11,16,'2026-09-24 20:45:00'),(13,11,18,'2026-09-26 02:00:00'),(14,11,22,'2026-09-27 23:00:00'),(15,10,11,'2026-09-25 18:12:00'),(16,4,16,'2026-09-26 18:23:00'),(17,5,11,'2026-09-27 18:34:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiries`
--

LOCK TABLES `inquiries` WRITE;
/*!40000 ALTER TABLE `inquiries` DISABLE KEYS */;
INSERT INTO `inquiries` VALUES (1,2,1,2,'Service history of the Creta','Hi, do you have the service records for the last three years? Also, is the sunroof working smoothly?','CONTACTED','2026-09-29 20:00:00','2026-09-30 07:45:00'),(2,3,1,2,'Nexon warranty','Is the manufacturer warranty transferable to a new owner?','OPEN','2026-09-30 10:30:00','2026-09-30 10:30:00'),(3,7,11,4,'Fortuner service history and accident record','Hi Aarav, is the Fortuner free of any accident history? Also, do you have all service invoices from Toyota?','CONTACTED','2026-09-30 09:00:00','2026-10-01 20:30:00'),(4,18,7,10,'BMW 320d - insurance and tyres','Hello Vikram, how old are the tyres and is the insurance transferable? I can visit this weekend.','CONTACTED','2026-09-30 11:00:00','2026-10-01 12:10:00'),(5,16,9,5,'Nexon EV - battery health','Hi Pranav, what is the battery state of health and what real-world range do you get?','OPEN','2026-10-02 08:30:00','2026-10-02 08:30:00'),(6,12,8,6,'Thar - negotiation','Is there any room on the price of the Thar? I can pay quickly if the deal works.','CLOSED','2026-09-28 10:00:00','2026-09-30 18:00:00'),(7,10,11,5,'Nexon petrol - mileage','How many km/l do you get in the city?','OPEN','2026-10-02 21:00:00','2026-10-02 21:00:00'),(8,15,8,10,'Verna - owner and service','Is it company-maintained? Can I see the service book on a video call?','CONTACTED','2026-10-01 17:00:00','2026-10-02 10:30:00'),(9,9,9,4,'Creta diesel','Does the Creta have any pending loan or hypothecation?','CONTACTED','2026-09-25 09:00:00','2026-09-25 18:45:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry_messages`
--

LOCK TABLES `inquiry_messages` WRITE;
/*!40000 ALTER TABLE `inquiry_messages` DISABLE KEYS */;
INSERT INTO `inquiry_messages` VALUES (1,1,1,'Hi, do you have the service records for the last three years? Also, is the sunroof working smoothly?','2026-09-29 20:00:00'),(2,1,2,'Hello Rahul! Yes, all records are with the authorised workshop and I can share copies. The sunroof works perfectly.','2026-09-30 07:30:00'),(3,1,1,'Great, thank you. I will send a purchase request shortly.','2026-09-30 07:45:00'),(4,2,1,'Is the manufacturer warranty transferable to a new owner?','2026-09-30 10:30:00'),(5,3,11,'Hi Aarav, is the Fortuner free of any accident history? Also, do you have all service invoices from Toyota?','2026-09-30 09:00:00'),(6,3,4,'Hello Manav! No accident history at all. I have every Toyota service invoice since purchase and can share photos of them.','2026-09-30 12:30:00'),(7,3,11,'Great, please share them. I am also considering a pre-purchase inspection through CarZen Services.','2026-09-30 13:10:00'),(8,3,4,'Sure, I have uploaded the invoices to the shared drive. Feel free to inspect it any weekend.','2026-10-01 20:30:00'),(9,4,7,'Hello Vikram, how old are the tyres and is the insurance transferable? I can visit this weekend.','2026-09-30 11:00:00'),(10,4,10,'Hi Suresh. Tyres are 14 months old with ~70% tread. Comprehensive insurance runs till December and can be transferred.','2026-10-01 09:15:00'),(11,4,7,'Perfect. I will send a purchase request once I have seen the car.','2026-10-01 12:10:00'),(12,5,9,'Hi Pranav, what is the battery state of health and what real-world range do you get?','2026-10-02 08:30:00'),(13,6,8,'Is there any room on the price of the Thar? I can pay quickly if the deal works.','2026-09-28 10:00:00'),(14,6,6,'Hi Karan, the price is already very competitive for 19,800 km. I can drop 10,000 for a quick deal.','2026-09-28 16:00:00'),(15,6,8,'Understood. I will think about it and place an order if I decide to go ahead.','2026-09-30 18:00:00'),(16,7,11,'How many km/l do you get in the city?','2026-10-02 21:00:00'),(17,8,8,'Is it company-maintained? Can I see the service book on a video call?','2026-10-01 17:00:00'),(18,8,10,'Yes, serviced at the Hyundai authorised workshop. Happy to do a video call at 7 pm tomorrow.','2026-10-02 10:30:00'),(19,9,9,'Does the Creta have any pending loan or hypothecation?','2026-09-25 09:00:00'),(20,9,4,'No loan - the car is fully paid and the RC has no hypothecation entry.','2026-09-25 18:45:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listing_views`
--

LOCK TABLES `listing_views` WRITE;
/*!40000 ALTER TABLE `listing_views` DISABLE KEYS */;
INSERT INTO `listing_views` VALUES (1,7,7,'2026-09-27 09:00:00'),(2,12,7,'2026-09-28 10:07:00'),(3,16,7,'2026-09-29 11:14:00'),(4,18,7,'2026-09-29 12:21:00'),(5,11,7,'2026-09-28 13:28:00'),(6,14,7,'2026-09-29 14:35:00'),(7,7,8,'2026-09-27 15:42:00'),(8,8,8,'2026-09-28 16:49:00'),(9,12,8,'2026-09-29 17:56:00'),(10,13,8,'2026-09-27 09:03:00'),(11,15,8,'2026-09-28 10:10:00'),(12,10,9,'2026-09-29 11:17:00'),(13,15,9,'2026-09-27 12:24:00'),(14,9,9,'2026-09-28 13:31:00'),(15,16,9,'2026-09-29 14:38:00'),(16,7,11,'2026-09-27 15:45:00'),(17,9,11,'2026-09-28 16:52:00'),(18,12,11,'2026-09-29 17:59:00'),(19,14,11,'2026-09-27 09:06:00'),(20,16,11,'2026-09-28 10:13:00'),(21,7,10,'2026-09-29 11:20:00'),(22,12,10,'2026-09-27 12:27:00'),(23,12,4,'2026-09-28 13:34:00'),(24,14,4,'2026-09-29 14:41:00'),(25,7,5,'2026-09-27 15:48:00'),(26,18,5,'2026-09-28 16:55:00'),(27,16,6,'2026-09-29 17:02:00'),(28,7,6,'2026-09-27 09:09:00'),(29,4,1,'2026-09-29 14:10:00'),(30,4,11,'2026-09-29 17:05:00'),(31,4,8,'2026-09-30 09:30:00');
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
  `listing_status` enum('DRAFT','PENDING_REVIEW','APPROVED','REJECTED','ACTIVE','RESERVED','SOLD','EXPIRED','CANCELLED','REMOVED','SUSPENDED') DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
INSERT INTO `listings` VALUES (1,1,2,'SALE','2021 Maruti Suzuki Swift VXi - Single owner, 34,500 km','Single-owner Swift in excellent condition with full service history. Ready to drive away.',560000.00,1,'ACTIVE','2026-09-29 12:30:00','2027-03-31 23:59:59',32,'2026-09-28 10:00:00','2026-10-04 08:33:48',NULL),(2,2,2,'SALE','2020 Hyundai Creta SX Diesel - Sunroof, full service records','Well-maintained Creta diesel with panoramic sunroof, new tyres and complete service records.',1250000.00,1,'ACTIVE','2026-09-29 12:35:00','2027-03-31 23:59:59',32,'2026-09-28 10:00:00','2026-10-04 08:34:21',NULL),(3,3,2,'SALE','2022 Tata Nexon XZ+ AMT - 21,000 km, under warranty','Nexon XZ+ with AMT, still under manufacturer warranty. Six airbags and a five-star safety rating.',890000.00,1,'ACTIVE','2026-09-29 12:40:00','2027-03-31 23:59:59',38,'2026-09-28 10:00:00','2026-10-04 08:33:56',NULL),(4,4,2,'RESALE','2019 Honda City V CVT - Second owner, garage kept','Smooth CVT City, second owner, garage kept and serviced on time.',780000.00,1,'RESERVED','2026-09-29 12:45:00','2027-03-31 23:59:59',118,'2026-09-28 10:00:00','2026-09-28 10:00:00',NULL),(5,5,2,'SALE','2023 Maruti Suzuki Swift ZXi AMT - Under 10,000 km','Showroom-condition Swift ZXi AMT with under 10,000 km on the clock.',760000.00,0,'ACTIVE','2026-09-29 12:50:00','2027-03-31 23:59:59',31,'2026-09-28 10:00:00','2026-10-04 08:33:52',NULL),(6,6,2,'SALE','2022 Tata Nexon EV Empowered - Home charger included','Nexon EV with an 8-year battery warranty and home charger included.',1320000.00,1,'ACTIVE','2026-09-29 12:55:00','2027-03-31 23:59:59',39,'2026-09-28 10:00:00','2026-10-04 08:34:36',NULL),(7,11,4,'SALE','2021 Toyota Fortuner Legender 4x2 AT - 38,500 km','Single-owner Fortuner Legender 4x2 automatic with full Toyota service history. Leather interiors, 360-degree camera and ventilated seats. Never driven off-road.',2850000.00,1,'ACTIVE','2026-09-21 10:00:00','2027-03-31 23:59:59',191,'2026-09-21 10:00:00','2026-10-04 08:44:35',NULL),(8,12,5,'SALE','2019 Maruti Suzuki Swift VXi - 46,200 km','Zippy Swift VXi, serviced on time at the authorised workshop. Great first car with low running cost.',515000.00,1,'ACTIVE','2026-09-22 11:00:00','2027-03-31 23:59:59',144,'2026-09-22 11:00:00','2026-10-04 08:44:35',NULL),(9,13,4,'SALE','2018 Hyundai Creta SX 1.6 CRDi (O) - 61,800 km','Creta SX diesel (O) in Polar White. Sunroof, touchscreen, rear camera and new tyres fitted last year.',995000.00,1,'ACTIVE','2026-09-22 12:00:00','2027-03-31 23:59:59',103,'2026-09-22 12:00:00','2026-10-04 08:29:33',NULL),(10,14,5,'SALE','2018 Tata Motors Nexon XZ+ Petrol - 52,300 km','Nexon XZ+ petrol with a five-star safety rating. Dual-tone roof, projector headlamps and a clean interior.',640000.00,1,'ACTIVE','2026-09-23 09:30:00','2027-03-31 23:59:59',82,'2026-09-23 09:30:00','2026-10-04 08:29:33',NULL),(11,15,6,'RESALE','2018 Honda City VX CVT Petrol - 58,900 km','Honda City VX CVT, smooth and quiet. Second owner, always garaged, service records available.',780000.00,0,'RESERVED','2026-09-18 10:00:00','2027-03-31 23:59:59',121,'2026-09-18 10:00:00','2026-09-30 10:00:00',NULL),(12,16,6,'SALE','2021 Mahindra Thar LX Hard Top Diesel AT - 19,800 km','New-gen Thar LX hard top diesel automatic. Barely used, with accessory pack and underbody protection.',1490000.00,1,'ACTIVE','2026-09-24 08:45:00','2027-03-31 23:59:59',259,'2026-09-24 08:45:00','2026-10-04 08:29:33',NULL),(13,17,4,'RESALE','2018 Toyota Innova Crysta 2.4 ZX MT - 92,400 km','Innova Crysta 2.4 ZX 7-seater, the family workhorse. SOLD through CarZen.',1850000.00,1,'SOLD','2026-09-05 10:00:00','2027-03-31 23:59:59',167,'2026-09-05 10:00:00','2026-09-30 10:00:00',NULL),(14,18,5,'SALE','2020 Kia Seltos HTX 1.5 Petrol - 31,200 km','Kia Seltos HTX petrol with connected-car features, ventilated seats and a Bose-style audio setup.',1185000.00,1,'ACTIVE','2026-09-25 13:00:00','2027-03-31 23:59:59',94,'2026-09-25 13:00:00','2026-10-04 08:29:33',NULL),(15,19,10,'SALE','2018 Hyundai Verna SX 1.6 VTVT - 68,500 km','Verna SX 1.6 VTVT with sunroof and rear AC vents. Company-maintained, regular services.',695000.00,1,'ACTIVE','2026-09-26 10:30:00','2027-03-31 23:59:59',74,'2026-09-26 10:30:00','2026-10-04 08:29:33',NULL),(16,22,5,'SALE','2021 Tata Motors Nexon EV XZ+ Prime - 16,400 km','Nexon EV XZ+ Prime with 8-year battery warranty. Home charger included, around 300 km real-world range.',1390000.00,0,'RESERVED','2026-09-27 09:00:00','2027-03-31 23:59:59',188,'2026-09-27 09:00:00','2026-10-01 16:00:00',NULL),(17,23,4,'SALE','2019 Ford Endeavour Titanium 3.2 4x4 AT - 71,200 km','Endeavour Titanium 3.2 4x4 automatic. Approved by CarZen; listing is still a draft.',2150000.00,1,'DRAFT',NULL,NULL,0,'2026-09-29 10:00:00','2026-09-30 10:00:00',NULL),(18,24,10,'SALE','2017 BMW 3 Series 320d Luxury Line - 62,500 km','BMW 320d Luxury Line with full BMW service history, sunroof and Harman Kardon sound.',2495000.00,1,'ACTIVE','2026-09-28 16:00:00','2027-03-31 23:59:59',144,'2026-09-28 16:00:00','2026-10-04 08:29:56',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,12,'Car awaiting approval','A newly submitted car is waiting for admin approval.','admin',7,'car',0,'2026-09-29 11:00:00'),(2,12,'New service request','Rahul Patel requested Full Car Servicing for 08 Oct 2026.','system',1,'service_request',0,'2026-09-30 09:00:00'),(3,2,'New order received','A buyer placed an order for 2021 Maruti Suzuki Swift VXi.','order',1,'order',0,'2026-09-30 09:10:00'),(4,2,'New enquiry','Rahul Patel asked a question about the Nexon XZ+.','inquiry',2,'inquiry',0,'2026-09-30 10:30:00'),(5,2,'Car rejected','Your Swift submission was rejected. Please check the reason and resubmit.','listing',8,'car',1,'2026-09-29 11:30:00'),(6,1,'Service Request Submitted','Your request for \'Full Car Servicing\' on 2026-10-08 at 10:00:00 has been submitted.','system',1,'service_request',0,'2026-09-28 11:00:00'),(7,1,'Service request accepted','Your service request #2 has been accepted.','system',2,'service_request',0,'2026-09-29 10:00:00'),(8,1,'Service scheduled','Your service request #3 is scheduled for 2026-10-15 at 14:00.','system',3,'service_request',0,'2026-09-30 11:00:00'),(9,1,'Service completed','Your service request #5 has been completed.','system',5,'service_request',1,'2026-09-18 16:35:00'),(10,1,'Order confirmed','The seller confirmed your order for 2019 Honda City V CVT.','order',2,'order',0,'2026-09-30 08:05:00'),(11,1,'New reply from the seller','Ajay replied to your enquiry about the Creta.','inquiry',1,'inquiry',0,'2026-09-30 07:30:00'),(12,12,'Car awaiting approval','A newly submitted car (Baleno Zeta 1.2) is waiting for admin approval.','admin',20,'car',0,'2026-09-29 11:00:00'),(13,12,'Car rejected','A newly submitted car (XUV500 W8) was reviewed and rejected.','admin',21,'car',1,'2026-09-26 16:00:00'),(14,12,'New service request','Suresh Iyer requested Full Car Servicing + AC Service for 14 Oct 2026.','system',8,'service_request',0,'2026-10-01 10:00:00'),(15,12,'New service request','Vikram Singh requested Full Car Servicing + Exterior Polish for 18 Oct 2026.','system',19,'service_request',0,'2026-10-02 12:00:00'),(16,12,'New listing report','A report was filed on the BMW 3 Series listing (wrong information).','admin',24,'car',0,'2026-10-02 13:05:00'),(17,4,'New order received','Manav Joshi placed an order for the 2021 Toyota Fortuner.','order',6,'order',0,'2026-10-01 10:15:00'),(18,4,'New enquiry','Manav Joshi asked about the Fortuner service history.','inquiry',3,'inquiry',1,'2026-09-30 09:00:00'),(19,4,'Order completed','Your Innova Crysta sale to Karan Malhotra is complete.','order',4,'order',1,'2026-09-14 17:35:00'),(20,4,'Order cancelled','Ankit Desai cancelled the order for your Creta.','order',8,'order',1,'2026-09-27 10:30:00'),(21,4,'Car approved','Your Endeavour was approved and can now be published as a listing.','listing',23,'car',0,'2026-09-20 12:05:00'),(22,4,'Service completed','Your service request #16 has been completed.','system',16,'service_request',1,'2026-07-15 17:05:00'),(23,5,'New enquiry','Ankit Desai asked about the Nexon EV battery health.','inquiry',5,'inquiry',0,'2026-10-02 08:30:00'),(24,5,'New enquiry','Manav Joshi asked about the Nexon petrol mileage.','inquiry',7,'inquiry',0,'2026-10-02 21:00:00'),(25,5,'Order rejected','You rejected Suresh Iyer\'s offer on the Seltos.','order',9,'order',1,'2026-09-28 09:00:00'),(26,5,'Order in progress','Order for the Nexon EV is now being processed.','order',10,'order',0,'2026-10-01 16:00:00'),(27,6,'Order confirmed','You confirmed Suresh Iyer\'s order for the Honda City.','order',5,'order',1,'2026-09-30 08:05:00'),(28,6,'New order received','Karan Malhotra placed an order for your Thar.','order',7,'order',0,'2026-10-02 09:40:00'),(29,6,'Report resolved','The report on your Thar listing was reviewed and rejected.','admin',16,'car',1,'2026-09-28 11:05:00'),(30,10,'New order received','Ankit Desai placed an order for your Verna.','order',11,'order',0,'2026-10-02 19:20:00'),(31,10,'New enquiry','Suresh Iyer asked about the BMW tyres and insurance.','inquiry',4,'inquiry',1,'2026-09-30 11:00:00'),(32,10,'Service scheduled','Your service request #17 is scheduled for 10 Oct 2026 at 4:00 PM.','system',17,'service_request',0,'2026-10-02 09:00:00'),(33,10,'Service request submitted','Your request for Full Car Servicing + Exterior Polish has been submitted.','system',19,'service_request',0,'2026-10-02 12:00:00'),(34,7,'Service Request Submitted','Your request for Full Car Servicing + AC Service has been submitted.','system',8,'service_request',0,'2026-10-01 10:00:00'),(35,7,'Service request accepted','Your service request #9 has been accepted.','system',9,'service_request',0,'2026-10-02 10:00:00'),(36,7,'Service scheduled','Your service request #10 is scheduled for 7 Oct 2026 at 2:00 PM.','system',10,'service_request',0,'2026-10-02 11:00:00'),(37,7,'Order confirmed','The seller confirmed your order for the Honda City.','order',5,'order',0,'2026-09-30 08:05:00'),(38,7,'Order rejected','Your offer on the Kia Seltos was rejected.','order',9,'order',1,'2026-09-28 09:00:00'),(39,7,'New reply from the seller','Vikram replied to your enquiry about the BMW.','inquiry',4,'inquiry',0,'2026-10-01 09:15:00'),(40,8,'Service in progress','Work has started on your service request #11.','system',11,'service_request',0,'2026-10-03 09:05:00'),(41,8,'Purchase completed','Your purchase of the Innova Crysta is complete. Enjoy your new car!','order',4,'order',1,'2026-09-14 17:35:00'),(42,8,'Order submitted','Your order for the Mahindra Thar has been sent to the seller.','order',7,'order',0,'2026-10-02 09:40:00'),(43,8,'New reply from the seller','Vikram replied to your enquiry about the Verna.','inquiry',8,'inquiry',0,'2026-10-02 10:30:00'),(44,8,'Service completed','Your service request #12 has been completed.','system',12,'service_request',1,'2026-09-12 17:05:00'),(45,9,'Service request cancelled','Your service request #14 was cancelled.','system',14,'service_request',1,'2026-09-25 09:00:00'),(46,9,'Service request rejected','Your service request #15 could not be accepted.','system',15,'service_request',1,'2026-09-18 10:00:00'),(47,9,'Order submitted','Your order for the Hyundai Verna has been sent to the seller.','order',11,'order',0,'2026-10-02 19:20:00'),(48,9,'Report update','Your report on the BMW 3 Series listing is waiting for review.','admin',24,'car',0,'2026-10-02 13:05:00'),(49,11,'Order is being processed','Your order for the Nexon EV is now being processed.','order',10,'order',0,'2026-10-01 16:00:00'),(50,11,'New reply from the seller','Aarav replied to your enquiry about the Fortuner.','inquiry',3,'inquiry',0,'2026-10-01 20:30:00'),(51,11,'Order submitted','Your order for the Toyota Fortuner has been sent to the seller.','order',6,'order',1,'2026-10-01 10:15:00');
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
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED','UNPAID') NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,1,1,2,550000.00,'PENDING','UNPAID','Interested - can I see the car this weekend?','2026-09-30 09:10:00','2026-09-30 09:10:00',NULL),(2,4,4,1,2,775000.00,'CONFIRMED','UNPAID','Please keep it reserved until Saturday.','2026-09-29 18:20:00','2026-09-30 08:05:00',NULL),(3,5,5,1,2,740000.00,'CANCELLED','UNPAID','Changed my mind, thanks.','2026-09-29 15:00:00','2026-09-29 16:30:00',NULL),(4,13,17,8,4,1820000.00,'COMPLETED','PAID','Final price agreed after test drive. Paid in cash at the seller\'s home.','2026-09-08 11:00:00','2026-09-14 17:30:00','2026-09-14 17:30:00'),(5,11,15,7,6,760000.00,'CONFIRMED','UNPAID','Please keep the car reserved until Saturday - I will visit with my mechanic.','2026-09-29 18:20:00','2026-09-30 08:05:00',NULL),(6,7,11,11,4,2750000.00,'PENDING','UNPAID','Interested in the Fortuner. Is a pre-purchase inspection possible this weekend?','2026-10-01 10:15:00','2026-10-01 10:15:00',NULL),(7,12,16,8,6,1450000.00,'PENDING','UNPAID','Can we close at this price if I come with a cheque tomorrow?','2026-10-02 09:40:00','2026-10-02 09:40:00',NULL),(8,9,13,9,4,960000.00,'CANCELLED','UNPAID','Changed my mind - going for a petrol automatic instead.','2026-09-26 15:00:00','2026-09-27 10:30:00',NULL),(9,14,18,7,5,1120000.00,'REJECTED','UNPAID','Offer is below the asking price.','2026-09-27 12:00:00','2026-09-28 09:00:00',NULL),(10,16,22,11,5,1360000.00,'PROCESSING','UNPAID','Documents and charger handover are in progress.','2026-09-29 14:10:00','2026-10-01 16:00:00',NULL),(11,15,19,9,10,660000.00,'PENDING','UNPAID','Is the sunroof under warranty?','2026-10-02 19:20:00','2026-10-02 19:20:00',NULL);
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
  `currency` varchar(10) DEFAULT NULL,
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `provider_transaction_id` varchar(255) DEFAULT NULL,
  `status` enum('pending','processing','success','failed','cancelled','refunded') NOT NULL,
  `razorpay_order_id` varchar(255) DEFAULT NULL,
  `razorpay_payment_id` varchar(255) DEFAULT NULL,
  `razorpay_signature` varchar(512) DEFAULT NULL,
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
  KEY `ix_payments_id` (`id`),
  KEY `ix_payments_user_id` (`user_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,4,8,NULL,1820000.00,'INR','CASH',NULL,NULL,'success',NULL,NULL,NULL,'2026-09-14 17:30:00',NULL,'2026-09-14 17:30:00','2026-09-14 17:30:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prediction_features`
--

LOCK TABLES `prediction_features` WRITE;
/*!40000 ALTER TABLE `prediction_features` DISABLE KEYS */;
INSERT INTO `prediction_features` VALUES (1,1,'Manufacturing year','2021','2026-09-19 10:00:00'),(2,1,'Odometer (km)','38500','2026-09-19 10:00:00'),(3,1,'Fuel type','Diesel','2026-09-19 10:00:00'),(4,2,'Manufacturing year','2018','2026-09-20 10:00:00'),(5,2,'Odometer (km)','52300','2026-09-20 10:00:00'),(6,3,'Manufacturing year','2017','2026-09-25 10:00:00'),(7,3,'Odometer (km)','62500','2026-09-25 10:00:00'),(8,3,'Ownership','First owner','2026-09-25 10:00:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_predictions`
--

LOCK TABLES `price_predictions` WRITE;
/*!40000 ALTER TABLE `price_predictions` DISABLE KEYS */;
INSERT INTO `price_predictions` VALUES (1,11,4,'COMPLETED',2790000.00,2640000.00,2930000.00,88.50,'carzen-price-estimator','1.0.0','{\"km\": 38500, \"fuel\": \"diesel\", \"year\": 2021, \"brand\": \"Toyota\", \"model\": \"Fortuner\"}','2026-09-19 10:00:00','2026-09-19 10:00:00'),(2,14,5,'COMPLETED',655000.00,610000.00,700000.00,84.20,'carzen-price-estimator','1.0.0','{\"km\": 52300, \"fuel\": \"petrol\", \"year\": 2018, \"brand\": \"Tata\", \"model\": \"Nexon\"}','2026-09-20 10:00:00','2026-09-20 10:00:00'),(3,24,10,'COMPLETED',2420000.00,2280000.00,2560000.00,81.75,'carzen-price-estimator','1.0.0','{\"km\": 62500, \"fuel\": \"diesel\", \"year\": 2017, \"brand\": \"BMW\", \"model\": \"3 Series\"}','2026-09-25 10:00:00','2026-09-25 10:00:00');
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
  `reason` enum('fake_listing','wrong_information','fraud','duplicate_listing','suspicious_seller','inappropriate_content','other') NOT NULL,
  `description` text,
  `status` enum('pending','under_review','resolved','rejected') NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `resolved_by_id` bigint DEFAULT NULL,
  `admin_note` text,
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,9,18,24,'wrong_information','The listing says single owner but the registration documents mention two owners.','pending','2026-10-02 13:00:00',NULL,NULL,NULL),(2,11,8,12,'duplicate_listing','This Swift looks the same as another listing I saw on another website.','under_review','2026-10-01 15:30:00',NULL,NULL,'Checking registration number with the seller.'),(3,7,15,19,'suspicious_seller','Seller asked me to pay a token amount before meeting.','resolved','2026-09-28 09:00:00','2026-09-29 12:00:00',12,'Contacted the seller; the token request was removed. No further action.'),(4,8,12,16,'fake_listing','Photos look like stock images.','rejected','2026-09-27 10:00:00','2026-09-28 11:00:00',12,'Verified: these are the seller\'s own photos taken at the showroom.');
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
  KEY `ix_reviews_transaction_id` (`transaction_id`),
  KEY `ix_reviews_id` (`id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `reviews_ibfk_4` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,8,17,13,1,5,'Smooth purchase, car as described','Aarav was honest about everything. The Crysta was exactly as advertised and the RC transfer was quick.',1,'2026-09-16 10:00:00','2026-09-16 10:00:00',NULL),(2,7,15,11,NULL,4,'Very clean City','Saw the car in person - clean inside and out. Slightly high mileage for the year but fairly priced.',1,'2026-09-30 19:00:00','2026-09-30 19:00:00',NULL),(3,11,16,12,NULL,5,'Barely driven Thar','Looks almost new. Seller was responsive and flexible about viewing time.',1,'2026-10-01 11:00:00','2026-10-01 11:00:00',NULL),(4,9,24,18,NULL,2,'Not as described (hidden by admin)','Review contains personal contact details, hidden by moderation.',0,'2026-10-02 14:00:00','2026-10-02 15:00:00',NULL);
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
  `item_name` varchar(150) NOT NULL,
  `quantity` int DEFAULT NULL,
  `unit_cost` decimal(15,2) DEFAULT NULL,
  `total_cost` decimal(15,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_record_id` (`service_record_id`),
  KEY `ix_service_items_id` (`id`),
  CONSTRAINT `service_items_ibfk_1` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_items`
--

LOCK TABLES `service_items` WRITE;
/*!40000 ALTER TABLE `service_items` DISABLE KEYS */;
INSERT INTO `service_items` VALUES (1,1,'Engine oil (3.5 L)',1,1200.00,1200.00,'2026-09-18 16:30:00'),(2,1,'Oil filter',1,350.00,350.00,'2026-09-18 16:30:00'),(3,1,'Air filter',1,550.00,550.00,'2026-09-18 16:30:00'),(4,2,'Synthetic engine oil (3.5 L)',1,900.00,900.00,'2026-06-10 12:00:00'),(5,3,'Engine oil 5W-30 (3.5 L)',1,1200.00,1200.00,'2026-09-12 17:00:00'),(6,3,'Oil filter',1,350.00,350.00,'2026-09-12 17:00:00'),(7,3,'Air filter',1,450.00,450.00,'2026-09-12 17:00:00'),(8,3,'Cabin filter',1,350.00,350.00,'2026-09-12 17:00:00'),(9,4,'Engine oil 15W-40 (6 L)',1,900.00,900.00,'2026-08-20 17:00:00'),(10,4,'Oil filter',1,50.00,50.00,'2026-08-20 17:00:00'),(11,5,'Engine oil 5W-30 (4 L)',1,1400.00,1400.00,'2026-07-15 17:00:00'),(12,5,'Oil filter',1,350.00,350.00,'2026-07-15 17:00:00'),(13,5,'Air filter',1,550.00,550.00,'2026-07-15 17:00:00'),(14,5,'Brake cleaner',1,300.00,300.00,'2026-07-15 17:00:00'),(15,6,'Engine oil 5W-30 (3.5 L)',1,1200.00,1200.00,'2026-05-10 17:00:00'),(16,6,'Air filter',1,500.00,500.00,'2026-05-10 17:00:00'),(17,6,'Wiper blades',2,250.00,500.00,'2026-05-10 17:00:00'),(18,7,'Synthetic engine oil (3.5 L)',1,800.00,800.00,'2026-03-02 17:00:00'),(19,7,'Oil filter',1,100.00,100.00,'2026-03-02 17:00:00'),(20,8,'Engine oil (3.5 L)',1,800.00,800.00,'2026-02-11 17:00:00'),(21,8,'Oil filter',1,100.00,100.00,'2026-02-11 17:00:00');
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
  `status` enum('scheduled','completed','cancelled') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `car_id` (`car_id`),
  KEY `ix_service_records_id` (`id`),
  CONSTRAINT `service_records_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_records`
--

LOCK TABLES `service_records` WRITE;
/*!40000 ALTER TABLE `service_records` DISABLE KEYS */;
INSERT INTO `service_records` VALUES (1,10,NULL,'Full Car Servicing','2026-09-18',52300.00,4999.00,2100.00,2899.00,'Full service completed. Engine oil, oil filter and air filter replaced; brakes inspected; no issues found.','2027-03-18',62300.00,'completed','2026-09-18 16:30:00','2026-09-18 16:30:00'),(2,9,NULL,'Oil & Filter Change','2026-06-10',37400.00,1799.00,900.00,899.00,'Synthetic oil and filter replaced.','2026-12-10',42400.00,'completed','2026-06-10 12:00:00','2026-06-10 12:00:00'),(3,26,NULL,'Full Car Servicing','2026-09-12',57100.00,4999.00,2350.00,2649.00,'Full service done. Engine oil, oil filter, air filter and cabin filter replaced; brakes inspected; AC vents cleaned.','2027-03-12',67100.00,'completed','2026-09-12 17:00:00','2026-09-12 17:00:00'),(4,27,NULL,'Oil & Filter Change, Wheel Alignment & Balancing','2026-08-20',84600.00,3098.00,950.00,2148.00,'Oil and filter changed; four-wheel alignment and balancing done. Rear tyres at 40% tread.','2027-02-20',89600.00,'completed','2026-08-20 17:00:00','2026-08-20 17:00:00'),(5,13,NULL,'Full Car Servicing','2026-07-15',60400.00,4999.00,2600.00,2399.00,'Annual service completed. Front brake pads at 60%. No pending issues.','2027-01-15',70400.00,'completed','2026-07-15 17:00:00','2026-07-15 17:00:00'),(6,25,NULL,'Full Car Servicing','2026-05-10',38900.00,4999.00,2200.00,2799.00,'Regular service. Replaced air filter and wiper blades.','2026-11-10',48900.00,'completed','2026-05-10 17:00:00','2026-05-10 17:00:00'),(7,26,NULL,'Oil & Filter Change','2026-03-02',52800.00,1799.00,900.00,899.00,'Synthetic oil and filter replaced.','2026-09-02',62800.00,'completed','2026-03-02 17:00:00','2026-03-02 17:00:00'),(8,27,NULL,'Oil & Filter Change','2026-02-11',80400.00,1799.00,900.00,899.00,'Walk-in oil change.','2026-08-11',90400.00,'completed','2026-02-11 17:00:00','2026-02-11 17:00:00');
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
  `service_name` varchar(150) NOT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `duration_minutes` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_service_request_items_id` (`id`),
  KEY `ix_service_request_items_service_request_id` (`service_request_id`),
  KEY `ix_service_request_items_service_id` (`service_id`),
  CONSTRAINT `service_request_items_ibfk_1` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_request_items_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_request_items`
--

LOCK TABLES `service_request_items` WRITE;
/*!40000 ALTER TABLE `service_request_items` DISABLE KEYS */;
INSERT INTO `service_request_items` VALUES (1,1,1,'Full Car Servicing',4999.00,180,'2026-09-28 11:00:00'),(2,2,2,'Oil & Filter Change',1799.00,45,'2026-09-28 11:00:00'),(3,2,4,'Wheel Alignment & Balancing',1299.00,60,'2026-09-28 11:00:00'),(4,3,3,'Brake Pad Replacement',2599.00,90,'2026-09-28 11:00:00'),(5,3,4,'Wheel Alignment & Balancing',1299.00,60,'2026-09-28 11:00:00'),(6,4,5,'AC Service & Gas Top-up',2199.00,90,'2026-09-28 11:00:00'),(7,5,1,'Full Car Servicing',4999.00,180,'2026-09-28 11:00:00'),(8,6,6,'Interior Deep Cleaning',1499.00,120,'2026-09-28 11:00:00'),(9,7,8,'Pre-Purchase Inspection',999.00,60,'2026-09-28 11:00:00'),(10,8,1,'Full Car Servicing',4999.00,180,'2026-10-01 10:00:00'),(11,8,5,'AC Service & Gas Top-up',2199.00,90,'2026-10-01 10:00:00'),(12,9,2,'Oil & Filter Change',1799.00,45,'2026-10-01 10:00:00'),(13,10,3,'Brake Pad Replacement',2599.00,90,'2026-10-01 10:00:00'),(14,10,4,'Wheel Alignment & Balancing',1299.00,60,'2026-10-01 10:00:00'),(15,11,5,'AC Service & Gas Top-up',2199.00,90,'2026-10-02 18:00:00'),(16,12,1,'Full Car Servicing',4999.00,180,'2026-09-12 08:00:00'),(17,13,2,'Oil & Filter Change',1799.00,45,'2026-08-20 08:00:00'),(18,13,4,'Wheel Alignment & Balancing',1299.00,60,'2026-08-20 08:00:00'),(19,14,6,'Interior Deep Cleaning',1499.00,120,'2026-10-01 10:00:00'),(20,15,8,'Pre-Purchase Inspection',999.00,60,'2026-10-01 10:00:00'),(21,16,1,'Full Car Servicing',4999.00,180,'2026-07-15 08:00:00'),(22,17,7,'Battery Check & Replacement',3499.00,30,'2026-10-01 10:00:00'),(23,18,1,'Full Car Servicing',4999.00,180,'2026-05-10 08:00:00'),(24,19,1,'Full Car Servicing',4999.00,180,'2026-10-01 10:00:00'),(25,19,10,'Exterior Polish & Ceramic Wax',3999.00,150,'2026-10-01 10:00:00'),(26,20,2,'Oil & Filter Change',1799.00,45,'2026-03-02 08:00:00');
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
  `notes` text,
  `amount` decimal(15,2) NOT NULL,
  `payment_status` varchar(50) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `status` enum('requested','accepted','scheduled','in_progress','completed','cancelled','rejected') NOT NULL,
  `admin_note` text,
  `service_record_id` bigint DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_service_requests_user_id` (`user_id`),
  KEY `ix_service_requests_service_record_id` (`service_record_id`),
  KEY `ix_service_requests_payment_status` (`payment_status`),
  KEY `ix_service_requests_deleted_at` (`deleted_at`),
  KEY `ix_service_requests_id` (`id`),
  KEY `ix_service_requests_scheduled_date` (`scheduled_date`),
  KEY `ix_service_requests_address_id` (`address_id`),
  KEY `ix_service_requests_service_id` (`service_id`),
  KEY `ix_service_requests_car_id` (`car_id`),
  KEY `ix_service_requests_status` (`status`),
  CONSTRAINT `service_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `service_requests_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `service_requests_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `service_requests_ibfk_4` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `service_requests_ibfk_5` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_requests`
--

LOCK TABLES `service_requests` WRITE;
/*!40000 ALTER TABLE `service_requests` DISABLE KEYS */;
INSERT INTO `service_requests` VALUES (1,1,9,1,1,'2026-10-08','10:00:00','Please check the AC as well.',4999.00,'unpaid',NULL,'requested',NULL,NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(2,1,9,2,1,'2026-10-12','11:00:00',NULL,3098.00,'unpaid',NULL,'accepted','Accepted - we will confirm the exact time shortly.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(3,1,10,3,2,'2026-10-15','14:00:00','Squeaking noise from the front brakes.',3898.00,'unpaid',NULL,'scheduled','Scheduled for 15 Oct at 2:00 PM. Our mechanic will arrive at your address.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(4,1,10,5,1,'2026-10-02','09:00:00',NULL,2199.00,'unpaid',NULL,'in_progress','Work started.',NULL,'2026-09-28 11:00:00','2026-09-30 11:00:00',NULL),(5,1,10,1,1,'2026-09-18','10:00:00','Regular service before a long trip.',4999.00,'unpaid',NULL,'completed','Completed. Next service due in six months.',1,'2026-09-16 09:00:00','2026-09-18 16:30:00',NULL),(6,1,9,6,1,'2026-09-25','15:00:00',NULL,1499.00,'unpaid',NULL,'cancelled','Cancelled by user.',NULL,'2026-09-23 09:00:00','2026-09-24 10:00:00',NULL),(7,1,9,8,2,'2026-09-22','12:00:00','Need it before buying a used car.',999.00,'unpaid',NULL,'rejected','Sorry, inspections are not available at that location. Please book another time.',NULL,'2026-09-20 09:00:00','2026-09-21 10:00:00',NULL),(8,7,25,1,8,'2026-10-14','10:00:00','Please also check the AC cooling - it has become weak.',7198.00,'unpaid',NULL,'requested',NULL,NULL,'2026-10-01 10:00:00','2026-10-01 10:00:00',NULL),(9,7,25,2,8,'2026-10-09','11:00:00',NULL,1799.00,'unpaid',NULL,'accepted','Accepted - we will confirm the exact pickup time shortly.',NULL,'2026-10-01 10:00:00','2026-10-01 10:00:00',NULL),(10,7,25,3,9,'2026-10-07','14:00:00','Squeaking noise from the front brakes.',3898.00,'unpaid',NULL,'scheduled','Scheduled. Our mechanic will arrive at your Andheri office address.',NULL,'2026-10-01 10:00:00','2026-10-01 10:00:00',NULL),(11,8,26,5,10,'2026-10-03','09:00:00',NULL,2199.00,'unpaid',NULL,'in_progress','Work started - gas top-up and leak test in progress.',NULL,'2026-10-02 18:00:00','2026-10-02 18:00:00',NULL),(12,8,26,1,10,'2026-09-12','10:00:00','Regular service before a long trip.',4999.00,'paid','cash','completed','Completed. Next service due in six months.',3,'2026-09-10 09:00:00','2026-09-12 16:30:00',NULL),(13,9,27,2,11,'2026-08-20','11:00:00',NULL,3098.00,'paid','cash','completed','Completed. Rear tyres are wearing - replace within 5,000 km.',4,'2026-08-18 09:00:00','2026-08-20 16:30:00',NULL),(14,9,27,6,11,'2026-09-25','15:00:00',NULL,1499.00,'unpaid',NULL,'cancelled','Cancelled by user.',NULL,'2026-09-23 09:00:00','2026-09-24 10:00:00',NULL),(15,9,27,8,11,'2026-09-18','12:00:00','Need it before buying a used car.',999.00,'unpaid',NULL,'rejected','Sorry, inspections are not available at that location. Please book another time.',NULL,'2026-09-16 09:00:00','2026-09-17 10:00:00',NULL),(16,4,13,1,4,'2026-07-15','10:00:00','Annual service.',4999.00,'paid','cash','completed','Completed. No pending issues.',5,'2026-07-13 09:00:00','2026-07-15 16:30:00',NULL),(17,10,19,7,12,'2026-10-10','16:00:00','Battery is struggling to start in the morning.',3499.00,'unpaid',NULL,'scheduled','Scheduled for 10 Oct at 4:00 PM.',NULL,'2026-10-01 10:00:00','2026-10-01 10:00:00',NULL),(18,7,25,1,8,'2026-05-10','10:00:00',NULL,4999.00,'paid','cash','completed','Completed.',6,'2026-05-08 09:00:00','2026-05-10 16:30:00',NULL),(19,10,24,1,12,'2026-10-18','11:00:00','Full service plus ceramic wax before I sell the car.',8998.00,'unpaid',NULL,'requested',NULL,NULL,'2026-10-01 10:00:00','2026-10-01 10:00:00',NULL),(20,8,26,2,10,'2026-03-02','10:00:00',NULL,1799.00,'paid','cash','completed','Completed.',7,'2026-02-28 09:00:00','2026-03-02 16:30:00',NULL);
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
  `name` varchar(150) NOT NULL,
  `description` text,
  `price` decimal(15,2) NOT NULL,
  `duration_minutes` int DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_services_status` (`status`),
  KEY `ix_services_id` (`id`),
  KEY `ix_services_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,'Full Car Servicing','Complete multi-point service: engine oil and filter, air and cabin filters, brake and fluid check, battery test and a road test.',4999.00,180,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(2,'Oil & Filter Change','Engine oil and oil filter replacement with a quick fluid top-up and visual inspection.',1799.00,45,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(3,'Brake Pad Replacement','Front or rear brake pad replacement, disc inspection and brake fluid check.',2599.00,90,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(4,'Wheel Alignment & Balancing','Computerised four-wheel alignment and balancing for even tyre wear and a straighter drive.',1299.00,60,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(5,'AC Service & Gas Top-up','AC performance check, cabin filter cleaning, leak test and refrigerant top-up.',2199.00,90,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(6,'Interior Deep Cleaning','Vacuuming, steam cleaning of seats and mats, dashboard polish and odour treatment.',1499.00,120,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(7,'Battery Check & Replacement','Battery health test, terminal cleaning and replacement if needed (battery cost extra).',3499.00,30,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(8,'Pre-Purchase Inspection','A 100-point inspection by our mechanics before you buy a used car, with a written report.',999.00,60,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(9,'Underbody Coating','Rust-proof underbody coating. Currently not offered (shows as Inactive in the admin catalogue).',3999.00,150,NULL,'inactive','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL),(10,'Exterior Polish & Ceramic Wax','Machine polish and ceramic wax coat for a deep, long-lasting shine.',3999.00,150,NULL,'active','2026-01-10 10:00:00','2026-01-10 10:00:00',NULL);
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
  `payment_method` enum('CASH','UPI','CARD','BANK_TRANSFER','FINANCE','OTHER') DEFAULT NULL,
  `payment_status` enum('PENDING','PARTIAL','PAID','FAILED','REFUNDED','UNPAID') DEFAULT NULL,
  `transaction_status` enum('INITIATED','COMPLETED','CANCELLED','FAILED') DEFAULT NULL,
  `notes` text,
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,13,4,17,8,4,1820000.00,'2026-09-14 17:30:00','CASH','PAID','COMPLETED','Cash payment received at handover; RC transfer completed.','2026-09-14 17:30:00','2026-09-14 17:30:00');
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
  `role` enum('USER','ADMIN') NOT NULL,
  `status` enum('ACTIVE','INACTIVE','BLOCKED') NOT NULL,
  `profile_image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_username` (`username`),
  UNIQUE KEY `ix_users_email` (`email`),
  UNIQUE KEY `phone_number` (`phone_number`),
  KEY `ix_users_role` (`role`),
  KEY `ix_users_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Rahul','Patel','rahul.patel','rahul.patel@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500101','USER','ACTIVE',NULL,'2026-06-01 10:00:00','2026-06-01 10:00:00',NULL),(2,'Ajay','Mehta','ajay.mehta','ajay.mehta@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500102','USER','ACTIVE',NULL,'2026-06-01 10:00:00','2026-06-01 10:00:00',NULL),(3,'Nikhil','Patel','nikhil.patel','nikhil.patel@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9876500103','USER','ACTIVE',NULL,'2026-06-01 10:00:00','2026-06-01 10:00:00',NULL),(4,'Aarav','Shah','aarav.shah','aarav.shah@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9825011201','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(5,'Pranav','Nair','pranav.nair','pranav.nair@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9879022202','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(6,'Rohan','Verma','rohan.verma','rohan.verma@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9898033203','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(7,'Suresh','Iyer','suresh.iyer','suresh.iyer@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9909044204','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(8,'Karan','Malhotra','karan.malhotra','karan.malhotra@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9724055205','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(9,'Ankit','Desai','ankit.desai','ankit.desai@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9737066206','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(10,'Vikram','Singh','vikram.singh','vikram.singh@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9687077207','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(11,'Manav','Joshi','manav.joshi','manav.joshi@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9714088208','USER','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL),(12,'CarZen','Admin','admin','admin@gmail.com','$2b$12$hLwezUCY2MIHsaj3zQJGTO78W8R4N2BjCnVqEuqurV94ABf2vmpxO','9879099209','ADMIN','ACTIVE',NULL,'2026-01-05 10:00:00','2026-01-05 10:00:00',NULL);
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

-- Dump completed on 2026-10-05 11:33:58
