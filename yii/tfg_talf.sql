-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: tfg_talf
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `answer`
--

DROP TABLE IF EXISTS `answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `test_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `answers_json` text NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `answer_test_id` (`test_id`) USING BTREE,
  KEY `answer_user_id` (`user_id`) USING BTREE,
  KEY `idx-answer-score` (`score`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answer`
--

LOCK TABLES `answer` WRITE;
/*!40000 ALTER TABLE `answer` DISABLE KEYS */;
INSERT INTO `answer` VALUES (1,14,1,0.00,'[{\"question_index\":0,\"selected\":[]},{\"question_index\":1,\"selected\":[]},{\"question_index\":2,\"selected\":[]}]','2025-11-08 14:36:40'),(2,15,NULL,0.00,'[[],[],[]]','2025-11-09 16:26:36'),(3,16,1,5.57,'[[1],[1],[0]]','2025-11-09 16:27:02'),(4,17,1,0.00,'[[],[],[]]','2025-11-09 16:34:03'),(5,18,1,0.00,'[[0],[0],[0]]','2025-11-09 16:34:10');
/*!40000 ALTER TABLE `answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migration`
--

DROP TABLE IF EXISTS `migration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migration` (
  `version` varchar(180) NOT NULL,
  `apply_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migration`
--

LOCK TABLES `migration` WRITE;
/*!40000 ALTER TABLE `migration` DISABLE KEYS */;
INSERT INTO `migration` VALUES ('m000000_000000_base',1762536907),('m251107_000001_create_answer_table',1762549022),('m251107_000002_create_user_table',1762536957),('m251107_000003_add_fk_answer_user',1762536957),('m251107_000004_add_score_to_answer',1762544520),('m251107_000005_alter_answer_user_id_nullable',1762550872),('m251108_000001_create_test_table_if_missing',1762608735);
/*!40000 ALTER TABLE `migration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question`
--

DROP TABLE IF EXISTS `question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` int(11) DEFAULT NULL,
  `question_form` longtext DEFAULT NULL,
  `is_multiple` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question`
--

LOCK TABLES `question` WRITE;
/*!40000 ALTER TABLE `question` DISABLE KEYS */;
INSERT INTO `question` VALUES (64,1,'{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:27:04'),(65,1,'{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:28:32'),(66,1,'{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:29:13'),(85,10,'{\"title\":\"Pregunta del tema 10\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:31:46'),(86,10,'{\"title\":\"Pregunta del tema 10\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:31:46'),(87,10,'{\"title\":\"Pregunta del tema 10\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"1\"]}',0,'2025-10-24 11:31:47'),(88,7,'{\"title\":\"Pregunta del tema 7\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"2\"]}',0,'2025-10-24 11:32:03'),(89,7,'{\"title\":\"Pregunta del tema 7\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"2\"]}',0,'2025-10-24 11:32:04'),(90,7,'{\"title\":\"Pregunta del tema 7\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"2\"]}',0,'2025-10-24 11:32:04'),(91,3,'{\"title\":\"Pregunta del tema 3\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',0,'2025-10-24 11:32:08'),(92,3,'{\"title\":\"Pregunta del tema 3\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',0,'2025-10-24 11:32:09'),(93,3,'{\"title\":\"Pregunta del tema 3\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',0,'2025-10-24 11:32:09'),(97,4,'{\"title\":\"Pregunta del tema 4\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',1,'2025-10-24 11:36:32'),(98,4,'{\"title\":\"Pregunta del tema 4\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',1,'2025-10-24 11:36:33'),(99,4,'{\"title\":\"Pregunta del tema 4\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\", \"Opción C\"],\"correct_choices\":[\"0\"]}',1,'2025-10-24 11:36:33'),(100,13,'{\"title\":\"asdasd\",\"stem\":\"asdasdasd\",\"image\":\"https:\\/\\/i.imgur.com\\/hmSvl3X_d.png\",\"choices\":[\"asda\",\"asdasd\",\"asdasd\"],\"correct_choices\":[\"2\"]}',0,'2025-10-25 07:27:13');
/*!40000 ALTER TABLE `question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  `questions` text NOT NULL,
  `evaluation` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx-test-date_created` (`date_created`),
  KEY `idx-test-evaluation` (`evaluation`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test`
--

LOCK TABLES `test` WRITE;
/*!40000 ALTER TABLE `test` DISABLE KEYS */;
INSERT INTO `test` VALUES (1,'2025-10-26 00:04:23','','classic'),(2,'2025-10-26 00:08:11','','classic'),(3,'2025-11-07 14:49:32','',''),(4,'2025-11-07 15:03:32','',''),(5,'2025-11-07 16:26:00','',''),(6,'2025-11-07 16:31:43','',''),(7,'2025-11-07 16:31:51','',''),(8,'2025-11-07 16:36:09','',''),(9,'2025-11-07 21:54:13','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(10,'2025-11-07 21:54:30','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(11,'2025-11-07 21:54:45','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(12,'2025-11-07 21:57:10','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(13,'2025-11-07 21:57:27','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(14,'2025-11-08 14:36:38','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(15,'2025-11-09 16:26:34','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(16,'2025-11-09 16:26:55','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(17,'2025-11-09 16:34:01','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic'),(18,'2025-11-09 16:34:07','[{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\",\"Opción C\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null},{\"title\":\"Pregunta del tema 1\",\"stem\":\"Selecciona la respuesta correcta:\",\"image\":\"\",\"choices\":[\"Opción A\",\"Opción B\"],\"correct_choices\":[\"1\"],\"is_multiple\":false,\"subject\":null}]','classic');
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `auth_key` varchar(64) DEFAULT NULL,
  `access_token` varchar(128) DEFAULT NULL,
  `status` smallint(6) NOT NULL DEFAULT 10,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','$2y$10$pTUZSpbLVcwJ5XnBwA2l6.F2FTyzp9MrtXxTmt9vJmgnuzzul.f8i','X-Ti_UgP_sdyMirFXSTmXqZC5zKZSDO4','admin-token',10,'2025-11-07 13:35:57','2025-11-07 13:35:57'),(2,'demo','$2y$10$rHZN/xz2YEDi586UP6OneOYCxvmfOU9b9t0ipLz2uHWAz2WFFt9wm','C5HBPVe5EGTtmUaE-RNX0OnytDtEvbLA','demo-token',10,'2025-11-07 13:35:57','2025-11-07 13:35:57');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-23 12:38:42
