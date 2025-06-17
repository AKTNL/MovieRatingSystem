use MovieRatingSystem
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: movieratingsystem
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Temporary view structure for view `actormoviesview`
--

DROP TABLE IF EXISTS `actormoviesview`;
/*!50001 DROP VIEW IF EXISTS `actormoviesview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `actormoviesview` AS SELECT 
 1 AS `ActorID`,
 1 AS `name`,
 1 AS `Title`,
 1 AS `ReleaseYear`,
 1 AS `Genre`,
 1 AS `Rating`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `actors`
--

DROP TABLE IF EXISTS `actors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actors` (
  `ActorID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Gender` enum('男','女','未知') DEFAULT '未知',
  `BirthDate` date DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ActorID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actors`
--

LOCK TABLES `actors` WRITE;
/*!40000 ALTER TABLE `actors` DISABLE KEYS */;
INSERT INTO `actors` VALUES (1,'蒂姆·罗宾斯','男','1958-10-16','美国'),(2,'张国荣','男','1956-09-12','中国'),(3,'莱昂纳多·迪卡普里奥','男','1974-11-11','美国');
/*!40000 ALTER TABLE `actors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `directormoviesview`
--

DROP TABLE IF EXISTS `directormoviesview`;
/*!50001 DROP VIEW IF EXISTS `directormoviesview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `directormoviesview` AS SELECT 
 1 AS `directorID`,
 1 AS `name`,
 1 AS `Title`,
 1 AS `ReleaseYear`,
 1 AS `Genre`,
 1 AS `Rating`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `directors`
--

DROP TABLE IF EXISTS `directors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `directors` (
  `DirectorID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Gender` enum('男','女','未知') DEFAULT '未知',
  `BirthDate` date DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`DirectorID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `directors`
--

LOCK TABLES `directors` WRITE;
/*!40000 ALTER TABLE `directors` DISABLE KEYS */;
INSERT INTO `directors` VALUES (1,'弗兰克·德拉邦特','男','1959-01-28','美国'),(2,'陈凯歌','男','1952-08-12','中国'),(3,'克里斯托弗·诺兰','男','1970-07-30','英国');
/*!40000 ALTER TABLE `directors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movieactors`
--

DROP TABLE IF EXISTS `movieactors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movieactors` (
  `MovieID` int NOT NULL,
  `ActorID` int NOT NULL,
  PRIMARY KEY (`MovieID`,`ActorID`),
  KEY `ActorID` (`ActorID`),
  CONSTRAINT `movieactors_ibfk_1` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `movieactors_ibfk_2` FOREIGN KEY (`ActorID`) REFERENCES `actors` (`ActorID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movieactors`
--

LOCK TABLES `movieactors` WRITE;
/*!40000 ALTER TABLE `movieactors` DISABLE KEYS */;
INSERT INTO `movieactors` VALUES (1,1),(2,2),(3,3);
/*!40000 ALTER TABLE `movieactors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `moviedetailsview`
--

DROP TABLE IF EXISTS `moviedetailsview`;
/*!50001 DROP VIEW IF EXISTS `moviedetailsview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `moviedetailsview` AS SELECT 
 1 AS `MovieID`,
 1 AS `Title`,
 1 AS `ReleaseYear`,
 1 AS `Duration`,
 1 AS `Genre`,
 1 AS `Language`,
 1 AS `Country`,
 1 AS `Synopsis`,
 1 AS `Rating`,
 1 AS `group_concat(distinct directors.name)`,
 1 AS `group_concat(distinct actors.name)`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `moviedirectors`
--

DROP TABLE IF EXISTS `moviedirectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `moviedirectors` (
  `MovieID` int NOT NULL,
  `DirectorID` int NOT NULL,
  PRIMARY KEY (`MovieID`,`DirectorID`),
  KEY `DirectorID` (`DirectorID`),
  CONSTRAINT `moviedirectors_ibfk_1` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `moviedirectors_ibfk_2` FOREIGN KEY (`DirectorID`) REFERENCES `directors` (`DirectorID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `moviedirectors`
--

LOCK TABLES `moviedirectors` WRITE;
/*!40000 ALTER TABLE `moviedirectors` DISABLE KEYS */;
INSERT INTO `moviedirectors` VALUES (1,1),(2,2),(3,3);
/*!40000 ALTER TABLE `moviedirectors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `movieratingstatsview`
--

DROP TABLE IF EXISTS `movieratingstatsview`;
/*!50001 DROP VIEW IF EXISTS `movieratingstatsview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `movieratingstatsview` AS SELECT 
 1 AS `MovieID`,
 1 AS `Title`,
 1 AS `ReviewCount`,
 1 AS `AverageRating`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `movies`
--

DROP TABLE IF EXISTS `movies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movies` (
  `MovieID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `ReleaseYear` int DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `Genre` varchar(50) DEFAULT NULL,
  `Language` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL,
  `Synopsis` text,
  `Rating` decimal(3,1) DEFAULT '0.0',
  PRIMARY KEY (`MovieID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movies`
--

LOCK TABLES `movies` WRITE;
/*!40000 ALTER TABLE `movies` DISABLE KEYS */;
INSERT INTO `movies` VALUES (1,'肖申克的救赎',1994,142,'剧情','英语','美国','一名银行家被冤入狱，最终通过智慧重获自由。',5.0),(2,'霸王别姬',1993,171,'爱情/历史','汉语','中国','两位京剧演员跨越半个世纪的悲欢离合。',4.8),(3,'盗梦空间',2010,148,'科幻/悬疑','英语','美国','通过潜入梦境窃取和植入思想的冒险故事。',4.5);
/*!40000 ALTER TABLE `movies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `popularmoviesview`
--

DROP TABLE IF EXISTS `popularmoviesview`;
/*!50001 DROP VIEW IF EXISTS `popularmoviesview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `popularmoviesview` AS SELECT 
 1 AS `MovieID`,
 1 AS `Title`,
 1 AS `ReleaseYear`,
 1 AS `Genre`,
 1 AS `Rating`,
 1 AS `ReviewCount`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `ReviewID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `MovieID` int DEFAULT NULL,
  `Comment` text,
  `Rating` decimal(2,1) DEFAULT NULL,
  `ReviewDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReviewID`),
  KEY `UserID` (`UserID`),
  KEY `MovieID` (`MovieID`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`MovieID`) REFERENCES `movies` (`MovieID`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK ((`Rating` between 0 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,1,'这部电影教会了我什么是希望。',5.0,'2025-05-23 09:06:42'),(2,2,2,'华语电影的巅峰之作！',4.8,'2025-05-23 09:06:42'),(3,3,3,'梦境与现实交织，脑洞大开！',4.5,'2025-05-23 09:06:42');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `RegistrationDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `Role` enum('user','admin') NOT NULL DEFAULT 'user',
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'user1','123456','user1@example.com','2025-05-23 09:05:04','user'),(2,'user2','abcdef','user2@example.com','2025-05-23 09:05:04','user'),(3,'user3','qwerty','user3@example.com','2025-05-23 09:05:04','user'),(4,'white_tree','ck041121','ck2474508686@163.com','2025-05-23 09:18:55','admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `actormoviesview`
--

/*!50001 DROP VIEW IF EXISTS `actormoviesview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `actormoviesview` AS select `actors`.`ActorID` AS `ActorID`,`actors`.`Name` AS `name`,`movies`.`Title` AS `Title`,`movies`.`ReleaseYear` AS `ReleaseYear`,`movies`.`Genre` AS `Genre`,`movies`.`Rating` AS `Rating` from ((`actors` join `movieactors` on((`actors`.`ActorID` = `movieactors`.`ActorID`))) join `movies` on((`movieactors`.`MovieID` = `movies`.`MovieID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `directormoviesview`
--

/*!50001 DROP VIEW IF EXISTS `directormoviesview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `directormoviesview` AS select `directors`.`DirectorID` AS `directorID`,`directors`.`Name` AS `name`,`movies`.`Title` AS `Title`,`movies`.`ReleaseYear` AS `ReleaseYear`,`movies`.`Genre` AS `Genre`,`movies`.`Rating` AS `Rating` from ((`directors` join `moviedirectors` on((`directors`.`DirectorID` = `moviedirectors`.`DirectorID`))) join `movies` on((`moviedirectors`.`MovieID` = `movies`.`MovieID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `moviedetailsview`
--

/*!50001 DROP VIEW IF EXISTS `moviedetailsview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `moviedetailsview` AS select `movies`.`MovieID` AS `MovieID`,`movies`.`Title` AS `Title`,`movies`.`ReleaseYear` AS `ReleaseYear`,`movies`.`Duration` AS `Duration`,`movies`.`Genre` AS `Genre`,`movies`.`Language` AS `Language`,`movies`.`Country` AS `Country`,`movies`.`Synopsis` AS `Synopsis`,`movies`.`Rating` AS `Rating`,group_concat(distinct `directors`.`Name` separator ',') AS `group_concat(distinct directors.name)`,group_concat(distinct `actors`.`Name` separator ',') AS `group_concat(distinct actors.name)` from ((((`movies` left join `moviedirectors` on((`movies`.`MovieID` = `moviedirectors`.`MovieID`))) left join `directors` on((`moviedirectors`.`DirectorID` = `directors`.`DirectorID`))) left join `movieactors` on((`movies`.`MovieID` = `movieactors`.`MovieID`))) left join `actors` on((`movieactors`.`ActorID` = `actors`.`ActorID`))) group by `movies`.`MovieID` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `movieratingstatsview`
--

/*!50001 DROP VIEW IF EXISTS `movieratingstatsview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `movieratingstatsview` AS select `movies`.`MovieID` AS `MovieID`,`movies`.`Title` AS `Title`,count(`reviews`.`ReviewID`) AS `ReviewCount`,avg(`reviews`.`Rating`) AS `AverageRating` from (`movies` left join `reviews` on((`movies`.`MovieID` = `reviews`.`MovieID`))) group by `movies`.`MovieID` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `popularmoviesview`
--

/*!50001 DROP VIEW IF EXISTS `popularmoviesview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `popularmoviesview` AS select `movies`.`MovieID` AS `MovieID`,`movies`.`Title` AS `Title`,`movies`.`ReleaseYear` AS `ReleaseYear`,`movies`.`Genre` AS `Genre`,`movies`.`Rating` AS `Rating`,`movieratingstatsview`.`ReviewCount` AS `ReviewCount` from (`movies` join `movieratingstatsview` on((`movies`.`MovieID` = `movieratingstatsview`.`MovieID`))) order by `movieratingstatsview`.`AverageRating` desc,`movieratingstatsview`.`ReviewCount` desc limit 10 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-17 15:57:07
