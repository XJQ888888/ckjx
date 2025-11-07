-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 192.168.10.22    Database: ckjx
-- ------------------------------------------------------
-- Server version	8.0.42

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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('order_type','customer','material') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_categories`
--

DROP TABLE IF EXISTS `order_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1528 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_categories`
--

LOCK TABLES `order_categories` WRITE;
/*!40000 ALTER TABLE `order_categories` DISABLE KEYS */;
INSERT INTO `order_categories` VALUES (1,'刀库','active'),(2,'部装','active'),(3,'防护','active'),(4,'伸缩护罩','active'),(5,'接水盘','active'),(6,'工装','active'),(7,'铜管','active'),(8,'不锈钢管','active'),(9,'散单','active'),(46,'测试','active'),(209,'红色件','active'),(1498,'护栏','active'),(1508,'管线支架','active');
/*!40000 ALTER TABLE `order_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_history`
--

DROP TABLE IF EXISTS `order_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_by` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_changed_at` (`changed_at`),
  CONSTRAINT `order_status_history_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_history`
--

LOCK TABLES `order_status_history` WRITE;
/*!40000 ALTER TABLE `order_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_log`
--

DROP TABLE IF EXISTS `order_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `old_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) NOT NULL DEFAULT '技术拆分',
  `changed_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `changed_by` int DEFAULT NULL,
  `status` enum('技术拆分','排版','激光切割','折弯','焊接','涂装','已交货','返修','二次交货') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '技术拆分',
  `start_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` datetime DEFAULT NULL,
  `hours` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_status_log_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_log`
--

LOCK TABLES `order_status_log` WRITE;
/*!40000 ALTER TABLE `order_status_log` DISABLE KEYS */;
INSERT INTO `order_status_log` VALUES (33,23,NULL,'技术拆分','2025-11-04 09:29:49',NULL,'技术拆分','2025-11-04 01:29:49','2025-11-05 11:51:27',12.36,'2025-11-04 01:29:49'),(34,24,NULL,'技术拆分','2025-11-04 11:30:50',NULL,'折弯','2025-11-04 03:30:50','2025-11-06 15:21:28',23.84,'2025-11-04 03:30:50'),(35,25,NULL,'技术拆分','2025-11-04 11:32:03',NULL,'激光切割','2025-11-04 03:32:03','2025-11-06 15:21:22',23.82,'2025-11-04 03:32:03'),(36,26,NULL,'技术拆分','2025-11-04 11:32:48',NULL,'排版','2025-11-04 03:32:48','2025-11-04 15:30:43',3.97,'2025-11-04 03:32:48'),(37,27,NULL,'技术拆分','2025-11-04 11:34:12',NULL,'排版','2025-11-04 03:34:12','2025-11-04 15:26:16',3.87,'2025-11-04 03:34:12'),(38,28,NULL,'技术拆分','2025-11-04 11:34:41',NULL,'排版','2025-11-04 03:34:41','2025-11-04 15:31:01',3.94,'2025-11-04 03:34:41'),(39,29,NULL,'技术拆分','2025-11-04 11:35:02',NULL,'排版','2025-11-04 03:35:02','2025-11-04 15:30:19',3.92,'2025-11-04 03:35:02'),(40,30,NULL,'技术拆分','2025-11-04 11:35:30',NULL,'排版','2025-11-04 03:35:30','2025-11-05 10:27:35',8.87,'2025-11-04 03:35:30'),(41,31,NULL,'技术拆分','2025-11-04 11:36:00',NULL,'排版','2025-11-04 03:36:00','2025-11-04 15:31:09',3.92,'2025-11-04 03:36:00'),(42,32,NULL,'技术拆分','2025-11-04 11:36:52',NULL,'排版','2025-11-04 03:36:52','2025-11-05 10:27:47',8.85,'2025-11-04 03:36:52'),(43,33,NULL,'技术拆分','2025-11-04 11:45:51',NULL,'排版','2025-11-04 03:45:51','2025-11-04 15:27:31',3.69,'2025-11-04 03:45:51'),(44,34,NULL,'技术拆分','2025-11-04 11:47:04',NULL,'排版','2025-11-04 03:47:04','2025-11-04 15:29:22',3.71,'2025-11-04 03:47:04'),(45,35,NULL,'技术拆分','2025-11-04 11:50:01',NULL,'排版','2025-11-04 03:50:01','2025-11-05 10:21:09',8.52,'2025-11-04 03:50:01'),(46,36,NULL,'技术拆分','2025-11-04 11:50:57',NULL,'排版','2025-11-04 03:50:57','2025-11-05 10:21:15',8.51,'2025-11-04 03:50:57'),(47,37,NULL,'技术拆分','2025-11-04 13:18:42',NULL,'技术拆分','2025-11-04 05:18:42','2025-11-04 15:27:08',2.14,'2025-11-04 05:18:42'),(48,38,NULL,'技术拆分','2025-11-04 13:42:00',NULL,'折弯','2025-11-04 05:42:00',NULL,0.00,'2025-11-04 05:42:00'),(49,39,NULL,'技术拆分','2025-11-04 14:01:38',NULL,'折弯','2025-11-04 06:01:38',NULL,0.00,'2025-11-04 06:01:38'),(50,40,NULL,'技术拆分','2025-11-04 14:04:52',NULL,'技术拆分','2025-11-04 06:04:52','2025-11-04 14:08:12',0.06,'2025-11-04 06:04:52'),(51,41,NULL,'技术拆分','2025-11-04 14:06:22',NULL,'折弯','2025-11-04 06:06:22',NULL,0.00,'2025-11-04 06:06:22'),(52,42,NULL,'技术拆分','2025-11-04 14:07:59',NULL,'折弯','2025-11-04 06:07:59',NULL,0.00,'2025-11-04 06:07:59'),(53,40,NULL,'技术拆分','2025-11-04 14:08:12',NULL,'折弯','2025-11-04 06:08:12',NULL,0.00,'2025-11-04 06:08:12'),(54,43,NULL,'技术拆分','2025-11-04 14:09:23',NULL,'折弯','2025-11-04 06:09:23',NULL,0.00,'2025-11-04 06:09:23'),(55,44,NULL,'技术拆分','2025-11-04 14:11:18',NULL,'折弯','2025-11-04 06:11:18',NULL,0.00,'2025-11-04 06:11:18'),(56,45,NULL,'技术拆分','2025-11-04 14:13:28',NULL,'折弯','2025-11-04 06:13:28',NULL,0.00,'2025-11-04 06:13:28'),(57,46,NULL,'技术拆分','2025-11-04 14:14:39',NULL,'折弯','2025-11-04 06:14:39',NULL,0.00,'2025-11-04 06:14:39'),(58,47,NULL,'技术拆分','2025-11-04 14:19:08',NULL,'折弯','2025-11-04 06:19:08',NULL,0.00,'2025-11-04 06:19:08'),(59,48,NULL,'技术拆分','2025-11-04 14:20:42',NULL,'折弯','2025-11-04 06:20:42',NULL,0.00,'2025-11-04 06:20:42'),(60,49,NULL,'技术拆分','2025-11-04 14:22:39',NULL,'折弯','2025-11-04 06:22:39',NULL,0.00,'2025-11-04 06:22:39'),(61,50,NULL,'技术拆分','2025-11-04 14:24:24',NULL,'折弯','2025-11-04 06:24:24',NULL,0.00,'2025-11-04 06:24:24'),(62,51,NULL,'技术拆分','2025-11-04 14:25:32',NULL,'折弯','2025-11-04 06:25:32',NULL,0.00,'2025-11-04 06:25:32'),(63,52,NULL,'技术拆分','2025-11-04 14:32:52',NULL,'折弯','2025-11-04 06:32:52',NULL,0.00,'2025-11-04 06:32:52'),(64,53,NULL,'技术拆分','2025-11-04 14:34:44',NULL,'折弯','2025-11-04 06:34:44',NULL,0.00,'2025-11-04 06:34:44'),(65,54,NULL,'技术拆分','2025-11-04 14:37:04',NULL,'技术拆分','2025-11-04 06:37:04','2025-11-04 14:41:53',0.08,'2025-11-04 06:37:04'),(66,55,NULL,'技术拆分','2025-11-04 14:38:20',NULL,'折弯','2025-11-04 06:38:20',NULL,0.00,'2025-11-04 06:38:20'),(67,56,NULL,'技术拆分','2025-11-04 14:41:40',NULL,'折弯','2025-11-04 06:41:40',NULL,0.00,'2025-11-04 06:41:40'),(68,54,NULL,'技术拆分','2025-11-04 14:41:53',NULL,'折弯','2025-11-04 06:41:53',NULL,0.00,'2025-11-04 06:41:53'),(69,57,NULL,'技术拆分','2025-11-04 14:43:37',NULL,'折弯','2025-11-04 06:43:37',NULL,0.00,'2025-11-04 06:43:37'),(70,58,NULL,'技术拆分','2025-11-04 14:54:19',NULL,'技术拆分','2025-11-04 06:54:19',NULL,0.00,'2025-11-04 06:54:19'),(71,27,NULL,'技术拆分','2025-11-04 15:26:16',NULL,'焊接','2025-11-04 07:26:16',NULL,0.00,'2025-11-04 07:26:16'),(72,37,NULL,'技术拆分','2025-11-04 15:27:08',NULL,'焊接','2025-11-04 07:27:08',NULL,0.00,'2025-11-04 07:27:08'),(73,33,NULL,'技术拆分','2025-11-04 15:27:31',NULL,'折弯','2025-11-04 07:27:31','2025-11-05 10:21:02',4.89,'2025-11-04 07:27:31'),(74,34,NULL,'技术拆分','2025-11-04 15:29:22',NULL,'已交货','2025-11-04 07:29:22',NULL,0.00,'2025-11-04 07:29:22'),(75,29,NULL,'技术拆分','2025-11-04 15:30:19',NULL,'激光切割','2025-11-04 07:30:19','2025-11-06 15:20:56',19.84,'2025-11-04 07:30:19'),(76,26,NULL,'技术拆分','2025-11-04 15:30:43',NULL,'折弯','2025-11-04 07:30:43','2025-11-06 15:21:16',19.84,'2025-11-04 07:30:43'),(77,28,NULL,'技术拆分','2025-11-04 15:31:01',NULL,'激光切割','2025-11-04 07:31:01','2025-11-06 15:20:49',19.83,'2025-11-04 07:31:01'),(78,31,NULL,'技术拆分','2025-11-04 15:31:09',NULL,'激光切割','2025-11-04 07:31:09','2025-11-06 15:21:04',19.83,'2025-11-04 07:31:09'),(79,33,NULL,'技术拆分','2025-11-05 10:21:02',NULL,'焊接','2025-11-05 02:21:02',NULL,NULL,'2025-11-05 02:21:02'),(80,35,NULL,'技术拆分','2025-11-05 10:21:09',NULL,'焊接','2025-11-05 02:21:09',NULL,NULL,'2025-11-05 02:21:09'),(81,36,NULL,'技术拆分','2025-11-05 10:21:15',NULL,'焊接','2025-11-05 02:21:15',NULL,NULL,'2025-11-05 02:21:15'),(82,30,NULL,'技术拆分','2025-11-05 10:27:35',NULL,'激光切割','2025-11-05 02:27:35','2025-11-06 15:21:00',14.89,'2025-11-05 02:27:35'),(83,32,NULL,'技术拆分','2025-11-05 10:27:47',NULL,'激光切割','2025-11-05 02:27:47','2025-11-06 15:21:09',14.89,'2025-11-05 02:27:47'),(84,23,NULL,'技术拆分','2025-11-05 11:51:27',NULL,'折弯','2025-11-05 03:51:27',NULL,NULL,'2025-11-05 03:51:27'),(85,28,NULL,'技术拆分','2025-11-06 15:20:49',NULL,'焊接','2025-11-06 07:20:49',NULL,NULL,'2025-11-06 07:20:49'),(86,29,NULL,'技术拆分','2025-11-06 15:20:56',NULL,'焊接','2025-11-06 07:20:56',NULL,NULL,'2025-11-06 07:20:56'),(87,30,NULL,'技术拆分','2025-11-06 15:21:00',NULL,'焊接','2025-11-06 07:21:00',NULL,NULL,'2025-11-06 07:21:00'),(88,31,NULL,'技术拆分','2025-11-06 15:21:04',NULL,'焊接','2025-11-06 07:21:04',NULL,NULL,'2025-11-06 07:21:04'),(89,32,NULL,'技术拆分','2025-11-06 15:21:09',NULL,'焊接','2025-11-06 07:21:09',NULL,NULL,'2025-11-06 07:21:09'),(90,26,NULL,'技术拆分','2025-11-06 15:21:16',NULL,'焊接','2025-11-06 07:21:16',NULL,NULL,'2025-11-06 07:21:16'),(91,25,NULL,'技术拆分','2025-11-06 15:21:22',NULL,'焊接','2025-11-06 07:21:22',NULL,NULL,'2025-11-06 07:21:22'),(92,24,NULL,'技术拆分','2025-11-06 15:21:28',NULL,'焊接','2025-11-06 07:21:28',NULL,NULL,'2025-11-06 07:21:28');
/*!40000 ALTER TABLE `order_status_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_date` date DEFAULT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `material_long_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ck_material_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specification` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `weight` decimal(10,2) DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(12,2) DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `status` enum('技术拆分','排版','激光切割','折弯','焊接','涂装','已交货','返修','二次交货') COLLATE utf8mb4_unicode_ci DEFAULT '技术拆分',
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deleted_at` date DEFAULT NULL,
  `tax_unit_price` decimal(10,2) DEFAULT NULL,
  `doc_number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_customer_name` (`customer_name`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_status` (`status`),
  KEY `idx_delivery_date` (`delivery_date`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (23,'2025-11-04','小巨人','不锈钢管','不锈钢管',NULL,'027301L0011','CK0001L0011','φ12','根',22,NULL,NULL,990.00,'2025-12-01','折弯',NULL,'2025-11-04 01:29:49','2025-11-05 03:51:27',0,NULL,45.00,'CGSQ20251015-0199',14),(24,'2025-11-04','致微精密','弯管机工作台','工装',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-10','焊接',NULL,'2025-11-04 03:30:50','2025-11-06 07:21:28',0,NULL,NULL,NULL,14),(25,'2025-11-04','奥斯雅','奥斯雅第一批订单','散单',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,2200.00,'2025-11-10','焊接',NULL,'2025-11-04 03:32:03','2025-11-06 08:29:48',0,NULL,2200.00,NULL,14),(26,'2025-11-04','苏州墨颢','苏州墨颢油分钣金','散单',NULL,NULL,NULL,NULL,'套',30,NULL,NULL,NULL,'2025-11-10','焊接',NULL,'2025-11-04 03:32:48','2025-11-06 07:21:16',0,NULL,NULL,NULL,14),(27,'2025-11-04','小巨人','HCN8800 L 60T刀库外围钣金2套','刀库',NULL,NULL,NULL,NULL,'套',2,NULL,NULL,NULL,'2025-11-30','焊接',NULL,'2025-11-04 03:34:12','2025-11-04 07:26:16',0,NULL,NULL,NULL,14),(28,'2025-11-04','小巨人','HCN6000 L 80T刀库外围钣金2套','刀库',NULL,NULL,NULL,NULL,'套',2,NULL,NULL,NULL,'2025-11-24','焊接',NULL,'2025-11-04 03:34:41','2025-11-06 07:20:49',0,NULL,NULL,NULL,14),(29,'2025-11-04','小巨人','HCN8800 L 120T刀库外围钣金1套','刀库',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-24','焊接',NULL,'2025-11-04 03:35:02','2025-11-06 07:20:56',0,NULL,NULL,NULL,14),(30,'2025-11-04','小巨人','HCN6000 L 60T刀库外围钣金1套','刀库',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-24','焊接',NULL,'2025-11-04 03:35:30','2025-11-06 07:21:00',0,NULL,NULL,NULL,14),(31,'2025-11-04','小巨人','HCN8800 L 160T刀库外围钣金1套','刀库',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-30','焊接',NULL,'2025-11-04 03:36:00','2025-11-06 07:21:04',0,NULL,NULL,NULL,14),(32,'2025-11-04','小巨人','HCN8800 L 60T刀库外围钣金1套','刀库',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-28','焊接',NULL,'2025-11-04 03:36:52','2025-11-06 07:21:09',0,NULL,NULL,NULL,14),(33,'2025-11-04','小巨人','6800管路支架','管线支架',NULL,NULL,NULL,NULL,'套',4,NULL,NULL,NULL,'2025-11-28','焊接',NULL,'2025-11-04 03:45:51','2025-11-05 02:21:02',0,NULL,NULL,NULL,14),(34,'2025-11-04','苏州墨颢','苏州墨颢螺旋下料  10.30','散单',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-07','已交货',NULL,'2025-11-04 03:47:04','2025-11-04 07:29:22',0,NULL,NULL,NULL,14),(35,'2025-11-04','铭跃达','伸缩护罩2种各10套  11.3','伸缩护罩',NULL,NULL,NULL,NULL,'套',20,NULL,NULL,NULL,'2025-11-24','焊接',NULL,'2025-11-04 03:50:01','2025-11-05 02:21:09',0,NULL,NULL,NULL,14),(36,'2025-11-04','乔锋','伸缩护罩','伸缩护罩',NULL,NULL,NULL,NULL,'套',1,NULL,NULL,NULL,'2025-11-07','焊接',NULL,'2025-11-04 03:50:57','2025-11-05 02:21:15',0,NULL,NULL,NULL,14),(37,'2025-11-04','小巨人','工装第一批 11.4','工装',NULL,NULL,NULL,NULL,'公斤',1,18.00,NULL,NULL,'2025-11-05','焊接',NULL,'2025-11-04 05:18:42','2025-11-04 07:27:08',0,NULL,NULL,NULL,14),(38,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'CK0001L0031',NULL,'φ12','根',11,NULL,NULL,539.00,'2025-12-01','折弯',NULL,'2025-11-04 05:42:00','2025-11-04 05:42:00',0,NULL,49.00,'CGSQ20251015-0199',14),(39,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027301L0041','CK0001L0041','φ12','根',11,NULL,NULL,385.00,'2025-12-01','折弯',NULL,'2025-11-04 06:01:38','2025-11-04 06:01:38',0,NULL,35.00,'CGSQ20251015-0199',14),(40,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0010','CK0007L0010','φ8','根',6,NULL,NULL,222.00,'2025-12-01','折弯',NULL,'2025-11-04 06:04:52','2025-11-04 06:08:12',0,NULL,37.00,'CGSQ20251015-0199',14),(41,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0020','CK0007L0020','φ8','根',6,0.01,NULL,264.00,'2025-12-01','折弯',NULL,'2025-11-04 06:06:22','2025-11-04 06:06:22',0,NULL,44.00,'CGSQ20251015-0199',14),(42,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0030','CK0007L0030','φ8','根',6,NULL,NULL,264.00,'2025-12-01','折弯',NULL,'2025-11-04 06:07:59','2025-11-04 06:07:59',0,NULL,44.00,'CGSQ20251015-0199',14),(43,'2025-11-04','致微精密','铜管','铜管',NULL,'027307L0041','CK0007L0041','φ8','根',5,NULL,NULL,320.00,'2025-12-01','折弯',NULL,'2025-11-04 06:09:23','2025-11-04 06:09:23',0,NULL,64.00,'CGSQ20251015-0199',14),(44,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0D6131L0060','CK0031L0060','φ6','根',4,NULL,NULL,80.00,'2025-12-01','折弯',NULL,'2025-11-04 06:11:18','2025-11-04 06:11:18',0,NULL,20.00,'CGSQ20251015-0199',14),(45,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0E000200270','CK000200270','φ12','根',3,NULL,NULL,168.00,'2025-12-01','折弯',NULL,'2025-11-04 06:13:28','2025-11-04 06:13:28',0,NULL,56.00,'CGSQ20251015-0199',14),(46,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0E008502060','CK008502060','φ12','根',3,NULL,NULL,66.00,'2025-12-01','折弯',NULL,'2025-11-04 06:14:39','2025-11-04 06:15:31',0,NULL,22.00,'CGSQ20251015-0199',14),(47,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0D6131L0060','CK0031L0060','φ6','根',1,NULL,NULL,20.00,'2025-12-01','折弯',NULL,'2025-11-04 06:19:08','2025-11-04 06:19:08',0,NULL,20.00,'CGSQ20251023-0009',14),(48,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027201L0030','CGSQ20251023-0008','φ12','套',2,NULL,NULL,288.00,'2025-11-22','折弯',NULL,'2025-11-04 06:20:42','2025-11-04 06:38:33',0,NULL,144.00,'CK0001L0030',14),(49,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0010','CK0007L0010','φ8','根',1,NULL,NULL,37.00,'2025-11-24','折弯',NULL,'2025-11-04 06:22:39','2025-11-04 06:22:39',0,NULL,37.00,'CGSQ20251023-0008',14),(50,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0020','CK0007L0020','φ8','根',1,NULL,NULL,44.00,'2025-12-10','折弯',NULL,'2025-11-04 06:24:24','2025-11-04 06:24:24',0,NULL,44.00,'CGSQ20251023-0008',14),(51,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'027307L0030','CK0007L0030','φ8','根',1,NULL,NULL,44.00,'2025-12-10','折弯',NULL,'2025-11-04 06:25:32','2025-11-04 06:25:32',0,NULL,44.00,'CGSQ20251023-0008',14),(52,'2025-11-04','致微精密','铜管','铜管',NULL,'027307L0041','CK0007L0041','φ8','根',1,NULL,NULL,64.00,'2025-12-10','折弯',NULL,'2025-11-04 06:32:52','2025-11-04 06:34:54',0,NULL,64.00,'CGSQ20251023-0008',14),(53,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0E0037L0840','CK0037L0840','φ16','根',1,NULL,NULL,145.00,'2025-12-10','折弯',NULL,'2025-11-04 06:34:44','2025-11-04 06:34:44',0,NULL,145.00,'CGSQ20251023-0008',14),(54,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0E0037L0830','CK0037L0830','φ16','根',3,NULL,NULL,519.00,'2025-11-20','折弯',NULL,'2025-11-04 06:37:04','2025-11-04 06:41:53',0,NULL,173.00,'CGSQ20251029-0007',14),(55,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0E0037L0840','CK0037L0840','φ16','根',3,NULL,NULL,435.00,'2025-12-01','折弯',NULL,'2025-11-04 06:38:20','2025-11-04 06:38:20',0,NULL,145.00,'CGSQ20251029-0006',14),(56,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0D3336L1000','0D3336L1000CK','φ16','根',1,NULL,NULL,48.00,'2025-11-05','折弯',NULL,'2025-11-04 06:41:40','2025-11-04 06:41:40',0,NULL,48.00,'CGSQ20251025-0019',14),(57,'2025-11-04','致微精密','不锈钢管','不锈钢管',NULL,'0D3236T6290','0D3236T6290CK','φ16','根',12,NULL,NULL,600.00,'2025-11-05','折弯',NULL,'2025-11-04 06:43:37','2025-11-04 06:43:37',0,NULL,50.00,'CGSQ20251015-01971',14),(58,'2025-11-04','小巨人','护栏第一批  11.4','护栏',NULL,NULL,NULL,NULL,'件',16,NULL,NULL,NULL,'2025-11-20','技术拆分',NULL,'2025-11-04 06:54:19','2025-11-04 06:54:55',0,NULL,NULL,NULL,14);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spec_options`
--

DROP TABLE IF EXISTS `spec_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spec_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `value` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spec_options`
--

LOCK TABLES `spec_options` WRITE;
/*!40000 ALTER TABLE `spec_options` DISABLE KEYS */;
INSERT INTO `spec_options` VALUES (5,'φ10'),(6,'φ12'),(7,'φ14'),(8,'φ16'),(9,'φ18'),(1,'φ2'),(10,'φ20'),(2,'φ4'),(3,'φ6'),(4,'φ8');
/*!40000 ALTER TABLE `spec_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `cfg_key` varchar(100) NOT NULL,
  `cfg_value` varchar(500) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cfg_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES ('print_template','<h1>{{order_name}}</h1><p>客户：{{customer_name}}</p>','2025-11-01 10:36:40'),('print_template_file','å°å·¨äººåºåºå01.xlsx','2025-11-04 01:59:47'),('show_amount','1','2025-11-04 08:40:27'),('spec_options','[\"φ2\",\"φ4\",\"φ6\",\"φ8\",\"φ10\",\"φ12\",\"φ14\",\"φ16\",\"φ18\",\"φ20\",\"φ24\"]','2025-10-31 05:56:28'),('unit_options','[\"根\",\"套\"]','2025-10-31 00:31:03');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unit_options`
--

DROP TABLE IF EXISTS `unit_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unit_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `value` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unit_options`
--

LOCK TABLES `unit_options` WRITE;
/*!40000 ALTER TABLE `unit_options` DISABLE KEYS */;
INSERT INTO `unit_options` VALUES (2,'套'),(1,'根');
/*!40000 ALTER TABLE `unit_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_permissions` (
  `user_id` int NOT NULL,
  `perm_code` varchar(60) NOT NULL,
  PRIMARY KEY (`user_id`,`perm_code`),
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
INSERT INTO `user_permissions` VALUES (1,'analytics.read'),(1,'backup.run'),(1,'categories.write'),(1,'dashboard.read'),(1,'orders.add'),(1,'orders.del'),(1,'orders.edit'),(1,'orders.read'),(1,'orders.recycle.clear'),(1,'orders.recycle.permanent'),(1,'orders.recycle.read'),(1,'orders.recycle.restore'),(1,'orders.status'),(1,'print.template'),(1,'specs.write'),(1,'system.config'),(1,'system.show'),(1,'units.write'),(1,'users.add'),(1,'users.del'),(1,'users.read'),(1,'users.toggle'),(13,'analytics.read'),(13,'dashboard.read'),(13,'orders.read'),(13,'orders.status'),(13,'system.show'),(14,'analytics.read'),(14,'dashboard.read'),(14,'orders.add'),(14,'orders.del'),(14,'orders.edit'),(14,'orders.read'),(14,'orders.status'),(14,'system.show'),(15,'analytics.read'),(15,'dashboard.read'),(15,'orders.read'),(15,'system.show'),(16,'analytics.read'),(16,'dashboard.read'),(16,'orders.read'),(16,'system.show');
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user') COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `last_login` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'谢军强','$2b$10$gIKSCKRr0/1bPKbO1s9u.e8Z5f5f5f5f5f5f5f5f5f5f5f5f5f5f5','admin',NULL,1,'2025-11-01 11:26:21','2025-11-01 11:26:21','active',NULL),(12,'admin','$2b$10$KNmevI1iElB2NXULiwi1rOtQfD/D.n.ZjdBoeStxElZWnvweP1kY.','admin',NULL,1,'2025-11-01 11:40:36','2025-11-03 14:18:59','active',NULL),(13,'丁成梅','$2b$10$rIIJvZntDEJ/mpSojoSTNOfa9ZmtZkzWhvZmOyIEZecntEVueNh52','user',NULL,1,'2025-11-01 11:56:17','2025-11-01 11:56:17','active',NULL),(14,'赵建帆','$2b$10$EY1kdgNAwUY1QsYNHN7t5.gWCe8ouP2EZZXtsN6dB4Jf4YbvZSzHu','user',NULL,1,'2025-11-04 01:15:40','2025-11-04 01:15:40','active',NULL),(15,'户宏伟','$2b$10$KdmUsp.N/uTYjHgrvhjmZeuMUlCIs/mSziTOhPN1O.8W7Qgr4Zdqa','user',NULL,1,'2025-11-04 01:54:47','2025-11-04 01:54:47','active',NULL),(16,'郭涛','$2b$10$Wzl3YCJlaJ.ctQZ5li7FP.DVIKkupMphlPxdqiQUS/eRE91Zvbu6q','user',NULL,1,'2025-11-04 01:55:15','2025-11-04 01:55:15','active',NULL);
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

-- Dump completed on 2025-11-06 16:48:39
