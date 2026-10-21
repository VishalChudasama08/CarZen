CREATE DATABASE  IF NOT EXISTS `carzen_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `carzen_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: carzen_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (1,3,'01, C G Road','firrjfnhrv',' Municipal Market','surat','Gujarat','India','380009',23.0225000,72.5714000,1,'2026-10-07 14:22:56','2026-10-07 14:22:56',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_brands`
--

LOCK TABLES `car_brands` WRITE;
/*!40000 ALTER TABLE `car_brands` DISABLE KEYS */;
INSERT INTO `car_brands` VALUES (1,'Toyota','toyota','Japan','https://upload.wikimedia.org/wikipedia/commons/9/9d/Toyota_carlogo.svg','Japanese automobile manufacturer offering SUVs, sedans, hatchbacks, MPVs, and hybrid vehicles.',1,'2026-10-07 14:19:12','2026-10-07 14:19:12',NULL);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_features`
--

LOCK TABLES `car_features` WRITE;
/*!40000 ALTER TABLE `car_features` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_models`
--

LOCK TABLES `car_models` WRITE;
/*!40000 ALTER TABLE `car_models` DISABLE KEYS */;
INSERT INTO `car_models` VALUES (1,1,'Land Cruiser','toyota-land-cruiser','SUV',7,'A premium full-size SUV combining luxury, durability, advanced technology, and exceptional off-road capability.',1,'2026-10-07 14:19:24','2026-10-07 14:19:24',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car_variants`
--

LOCK TABLES `car_variants` WRITE;
/*!40000 ALTER TABLE `car_variants` DISABLE KEYS */;
INSERT INTO `car_variants` VALUES (1,1,'ZX 2.0 Hybrid CVT','HYBRID','AUTOMATIC',1987.00,184.00,7,3000000.00,'2026-10-07 14:19:39','2026-10-07 14:19:39',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
INSERT INTO `cars` VALUES (1,1,3,'MH01AB1237',NULL,2021,NULL,'PETROL','MANUAL',NULL,NULL,50000.00,'White',NULL,1,NULL,'GOOD',NULL,NULL,NULL,NULL,'Mumbai','Maharashtra','India',NULL,NULL,NULL,0,'approved',NULL,NULL,NULL,'2026-10-07 14:21:35','2026-10-08 13:13:32',NULL);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiries`
--

LOCK TABLES `inquiries` WRITE;
/*!40000 ALTER TABLE `inquiries` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inquiry_messages`
--

LOCK TABLES `inquiry_messages` WRITE;
/*!40000 ALTER TABLE `inquiry_messages` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listings`
--

LOCK TABLES `listings` WRITE;
/*!40000 ALTER TABLE `listings` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,3,'Service Request Submitted','Your request for \'Battery Inspection\' on 2026-10-10 at 10:30:00 has been submitted.','system',1,'service_request',0,'2026-10-07 14:23:13'),(2,3,'Service Request Accepted','Your service request for \'Battery Inspection\' has been accepted by CarZen.','system',1,'service_request',0,'2026-10-07 14:24:28'),(3,3,'Service In Progress','Work on your car for \'Battery Inspection\' has begun.','system',1,'service_request',0,'2026-10-07 14:24:46'),(4,3,'Service Completed','Service for \'Battery Inspection\' on your car has been completed successfully.','system',1,'service_request',0,'2026-10-07 14:26:04'),(5,3,'Service Payment Successful','Online payment of INR 3179.00 for service request #1 was verified.','payment',1,'service_payment',0,'2026-10-07 15:13:29'),(6,3,'Service Request Submitted','Your request for \'Battery Inspection\' on 2026-10-10 at 10:30:00 has been submitted.','system',2,'service_request',0,'2026-10-07 15:48:13'),(7,3,'Service Request Submitted','Your request for \'Battery Inspection\' on 2026-10-10 at 10:30:00 has been submitted.','system',3,'service_request',0,'2026-10-08 13:11:29'),(8,3,'Service Request Accepted','Your service request for \'Battery Inspection\' has been accepted by CarZen.','system',3,'service_request',0,'2026-10-08 13:12:27'),(9,3,'Service In Progress','Work on your car for \'Battery Inspection\' has begun.','system',3,'service_request',0,'2026-10-08 13:13:01'),(10,3,'Service Completed','Service for \'Battery Inspection\' on your car has been completed successfully.','system',3,'service_request',0,'2026-10-08 13:13:32');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
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
  KEY `ix_payments_service_request_id` (`service_request_id`),
  KEY `ix_payments_user_id` (`user_id`),
  KEY `ix_payments_id` (`id`),
  KEY `ix_payments_order_id` (`order_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,NULL,NULL,3,1,3179.00,'INR','UPI','razorpay',NULL,'success','order_Tl3L1cJBJSUAV1','pay_test_1791385984808','76523a8501a58546d7909ecf14b81627cadeca2645c0c87a351ef0410459b05a','2026-10-07 15:13:29','{\"gateway_amount\": 317900, \"service_request_id\": 1}','2026-10-07 14:34:14','2026-10-07 15:13:29'),(2,NULL,NULL,3,3,749.00,'INR','UPI','razorpay',NULL,'pending','order_TlQVqlF56bmNHR',NULL,NULL,NULL,'{\"gateway_amount\": 74900, \"service_request_id\": 3}','2026-10-08 13:14:26','2026-10-08 13:14:26');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  KEY `ix_reviews_transaction_id` (`transaction_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`id`),
  CONSTRAINT `reviews_ibfk_4` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`)
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_items`
--

LOCK TABLES `service_items` WRITE;
/*!40000 ALTER TABLE `service_items` DISABLE KEYS */;
INSERT INTO `service_items` VALUES (1,1,'Battery Inspection',1,299.00,299.00,'2026-10-07 14:26:04'),(2,2,'Battery Inspection',1,299.00,299.00,'2026-10-08 13:13:32');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_records`
--

LOCK TABLES `service_records` WRITE;
/*!40000 ALTER TABLE `service_records` DISABLE KEYS */;
INSERT INTO `service_records` VALUES (1,1,NULL,'Battery Inspection','2026-10-10',145230.00,299.00,2530.00,350.00,'car is service','2026-12-29',201101.00,'completed','2026-10-07 14:26:04','2026-10-07 14:26:04'),(2,1,NULL,'Battery Inspection','2026-10-10',50000.00,299.00,0.00,450.00,'car is service','2026-12-25',100000.00,'completed','2026-10-08 13:13:32','2026-10-08 13:13:32');
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
  KEY `ix_service_request_items_service_id` (`service_id`),
  KEY `ix_service_request_items_id` (`id`),
  KEY `ix_service_request_items_service_request_id` (`service_request_id`),
  CONSTRAINT `service_request_items_ibfk_1` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_request_items_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_request_items`
--

LOCK TABLES `service_request_items` WRITE;
/*!40000 ALTER TABLE `service_request_items` DISABLE KEYS */;
INSERT INTO `service_request_items` VALUES (1,1,1,'Battery Inspection',299.00,30,'2026-10-07 14:23:13'),(2,2,1,'Battery Inspection',299.00,30,'2026-10-07 15:48:13'),(3,3,1,'Battery Inspection',299.00,30,'2026-10-08 13:11:29');
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
  `base_amount` decimal(15,2) NOT NULL,
  `parts_cost` decimal(15,2) NOT NULL,
  `labor_cost` decimal(15,2) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
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
  KEY `ix_service_requests_status` (`status`),
  KEY `ix_service_requests_car_id` (`car_id`),
  KEY `ix_service_requests_service_record_id` (`service_record_id`),
  KEY `ix_service_requests_user_id` (`user_id`),
  KEY `ix_service_requests_payment_status` (`payment_status`),
  KEY `ix_service_requests_deleted_at` (`deleted_at`),
  KEY `ix_service_requests_id` (`id`),
  KEY `ix_service_requests_scheduled_date` (`scheduled_date`),
  KEY `ix_service_requests_address_id` (`address_id`),
  KEY `ix_service_requests_service_id` (`service_id`),
  CONSTRAINT `service_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `service_requests_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`),
  CONSTRAINT `service_requests_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `service_requests_ibfk_4` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `service_requests_ibfk_5` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_requests`
--

LOCK TABLES `service_requests` WRITE;
/*!40000 ALTER TABLE `service_requests` DISABLE KEYS */;
INSERT INTO `service_requests` VALUES (1,3,1,1,1,'2026-10-10','10:30:00','Please check engine oil, brakes, and general vehicle condition. Also inspect any unusual noise from the front side.',299.00,2530.00,350.00,3179.00,3179.00,'paid','online','completed','car is service',1,'2026-10-07 14:23:13','2026-10-07 15:13:29',NULL),(2,3,1,1,1,'2026-10-10','10:30:00','Please check engine oil, brakes, and general vehicle condition. Also inspect any unusual noise from the front side.',299.00,0.00,0.00,299.00,299.00,'unpaid',NULL,'requested',NULL,NULL,'2026-10-07 15:48:13','2026-10-07 15:48:13',NULL),(3,3,1,1,1,'2026-10-10','10:30:00','Please check engine oil, brakes, and general vehicle condition. Also inspect any unusual noise from the front side.',299.00,0.00,450.00,749.00,749.00,'unpaid',NULL,'completed','car is service',2,'2026-10-08 13:11:29','2026-10-08 13:13:32',NULL);
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
  KEY `ix_services_deleted_at` (`deleted_at`),
  KEY `ix_services_id` (`id`),
  KEY `ix_services_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,'Battery Inspection','Battery health check, voltage testing, terminal cleaning and charging-system inspection.',299.00,30,'https://example.com/images/battery-service.jpg','active','2026-10-07 13:57:12','2026-10-07 13:57:12',NULL);
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
  `role` enum('USER','ADMIN') NOT NULL,
  `status` enum('ACTIVE','INACTIVE','BLOCKED') NOT NULL,
  `profile_image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_email` (`email`),
  UNIQUE KEY `ix_users_username` (`username`),
  UNIQUE KEY `phone_number` (`phone_number`),
  KEY `ix_users_id` (`id`),
  KEY `ix_users_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'boghara','ayush','ayushboghara','boghara@gmail.com','$2b$12$fnskDnyy9iits6NluuNBz.rflh1d2ekN9b7ePDFpBQNbcipMdT8hi','9757463210','USER','ACTIVE',NULL,'2026-10-07 13:56:09','2026-10-07 13:56:09',NULL),(2,'admin','admin','admin','admin@gmail.com','$2b$12$4t5UpLPEWvDRqlSOKa4.IukiKsiijFGVnkv4OPZpTMM2jnainCk8K','1354567890','ADMIN','ACTIVE',NULL,'2026-10-07 13:56:29','2026-10-07 13:56:29',NULL),(3,'tirth','tirth','tirth','tirth@gmail.com','$2b$12$3plMxfhGYCJuY8oBPx6di.xM0fztyZvVPiG.n2fjT.pMLl16bu3U6','9757463299','USER','ACTIVE',NULL,'2026-10-07 14:20:33','2026-10-07 14:20:33',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'carzen_db'
--

--
-- Dumping routines for database 'carzen_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-08 18:58:41
