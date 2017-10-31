-- MySQL dump 10.13  Distrib 5.5.53, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: freekbs2
-- ------------------------------------------------------
-- Server version	5.5.53-0+deb8u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `arguments`
--

DROP TABLE IF EXISTS `arguments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arguments` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ParentFormulaID` int(11) DEFAULT NULL,
  `ValueType` enum('formula','string','variable') DEFAULT NULL,
  `KeyID` int(11) DEFAULT NULL,
  `Value` blob,
  PRIMARY KEY (`ID`),
  KEY `ParentFormulaID` (`ParentFormulaID`),
  KEY `Value` (`Value`(256))
) ENGINE=MyISAM AUTO_INCREMENT=2327308 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asserters`
--

DROP TABLE IF EXISTS `asserters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asserters` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Asserter` blob,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contexts`
--

DROP TABLE IF EXISTS `contexts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contexts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Context` blob,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=244 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `formulae`
--

DROP TABLE IF EXISTS `formulae`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `formulae` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ParentFormulaID` int(11) DEFAULT NULL,
  `ArgumentID` int(11) DEFAULT NULL,
  `Arity` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=702180 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metadata` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `FormulaID` int(11) DEFAULT NULL,
  `ContextID` int(11) DEFAULT NULL,
  `AsserterID` int(11) DEFAULT NULL,
  `Date` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FormulaID` (`FormulaID`)
) ENGINE=MyISAM AUTO_INCREMENT=136073 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-07-26 18:16:59
