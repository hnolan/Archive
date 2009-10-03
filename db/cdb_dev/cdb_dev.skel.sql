-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_dev
-- ------------------------------------------------------
-- Server version	5.0.45

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
-- Table structure for table `cdb_counters`
--

DROP TABLE IF EXISTS `cdb_counters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_counters` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_object_id` int(10) unsigned NOT NULL,
  `counter_name` varchar(50) NOT NULL,
  `is_percent` bit(1) NOT NULL default '\0',
  `in_extract` bit(1) NOT NULL default '\0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_counter_name_unique` USING BTREE (`cdb_object_id`,`counter_name`),
  CONSTRAINT `FK_counter_object` FOREIGN KEY (`cdb_object_id`) REFERENCES `cdb_objects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_customers`
--

DROP TABLE IF EXISTS `cdb_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_customers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefix` varchar(20) default NULL,
  `customer_name` varchar(100) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_prefix_unique` USING BTREE (`prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_dataset_map`
--

DROP TABLE IF EXISTS `cdb_dataset_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_dataset_map` (
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`cdb_datasource_id`,`cdc_dataset_id`),
  KEY `FK_map_dataset` USING BTREE (`cdb_dataset_id`),
  CONSTRAINT `FK_map_dataset` FOREIGN KEY (`cdb_dataset_id`) REFERENCES `cdb_datasets` (`id`),
  CONSTRAINT `FK_map_datasource` FOREIGN KEY (`cdb_datasource_id`) REFERENCES `cdb_datasources` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_datasets`
--

DROP TABLE IF EXISTS `cdb_datasets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_datasets` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_counter_id` int(10) unsigned NOT NULL,
  `created_at` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt10_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt20_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt30_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt40_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt50_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `cdb_prefix` varchar(20) default NULL,
  `cdb_path` varchar(250) default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_dataset_unique` USING BTREE (`cdb_instance_id`,`cdb_counter_id`),
  UNIQUE KEY `IDX_dataset_path_unique` (`cdb_prefix`,`cdb_path`),
  KEY `FK_dataset_counter` USING BTREE (`cdb_counter_id`),
  CONSTRAINT `FK_dataset_counter` FOREIGN KEY (`cdb_counter_id`) REFERENCES `cdb_counters` (`id`),
  CONSTRAINT `FK_dataset_instance` FOREIGN KEY (`cdb_instance_id`) REFERENCES `cdb_instances` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16329 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_datasources`
--

DROP TABLE IF EXISTS `cdb_datasources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_datasources` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `source_server` varchar(45) NOT NULL,
  `source_app` varchar(45) NOT NULL,
  `target_table` varchar(45) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_datasource_customer` USING BTREE (`cdb_customer_id`),
  CONSTRAINT `FK_datasource_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `cdb_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_instances`
--

DROP TABLE IF EXISTS `cdb_instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_instances` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_machine_id` int(10) unsigned NOT NULL,
  `cdb_object_id` int(10) unsigned NOT NULL,
  `instance_name` varchar(250) default NULL,
  `parent_name` varchar(50) default NULL,
  `instance_index` varchar(50) default NULL,
  `first_status_time` datetime default NULL,
  `latest_status_time` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_instance_name_unique` USING BTREE (`cdb_machine_id`,`cdb_object_id`,`instance_name`),
  KEY `FK_instance_object` USING BTREE (`cdb_object_id`),
  CONSTRAINT `FK_instance_machine` FOREIGN KEY (`cdb_machine_id`) REFERENCES `cdb_machines` (`id`),
  CONSTRAINT `FK_instance_object` FOREIGN KEY (`cdb_object_id`) REFERENCES `cdb_objects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3045 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_log`
--

DROP TABLE IF EXISTS `cdb_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_log` (
  `id` int(11) NOT NULL auto_increment,
  `dt` datetime NOT NULL,
  `pn` varchar(80) default NULL,
  `txt` varchar(1024) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_machines`
--

DROP TABLE IF EXISTS `cdb_machines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_machines` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `machine_name` varchar(100) NOT NULL,
  `machine_type` varchar(50) NOT NULL default 'unknown',
  `subtype` varchar(50) NOT NULL default 'unknown',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_machine_name_unique` USING BTREE (`cdb_customer_id`,`machine_name`),
  CONSTRAINT `FK_machine_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `cdb_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=688 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_objects`
--

DROP TABLE IF EXISTS `cdb_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_objects` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `object_name` varchar(50) NOT NULL,
  `type` varchar(50) default NULL,
  `subsystem` varchar(50) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_object_name_unique` USING BTREE (`object_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `dataset_details`
--

DROP TABLE IF EXISTS `dataset_details`;
/*!50001 DROP VIEW IF EXISTS `dataset_details`*/;
/*!50001 CREATE TABLE `dataset_details` (
  `cdb_dataset_id` int(10) unsigned,
  `cdb_prefix` varchar(20),
  `cdb_machine` varchar(100),
  `cdb_object` varchar(50),
  `cdb_instance` varchar(250),
  `cdb_counter` varchar(50)
) ENGINE=MyISAM */;

--
-- Table structure for table `dt15_nagios_events`
--

DROP TABLE IF EXISTS `dt15_nagios_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dt15_nagios_events` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(512) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dt20_hourly_data`
--

DROP TABLE IF EXISTS `dt20_hourly_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dt20_hourly_data` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dt30_daily_data`
--

DROP TABLE IF EXISTS `dt30_daily_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dt30_daily_data` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `cdb_shift_id` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  `sample_week` int(10) unsigned NOT NULL,
  `sample_month` int(10) unsigned NOT NULL,
  `sample_year` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`,`cdb_shift_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `event_instances`
--

DROP TABLE IF EXISTS `event_instances`;
/*!50001 DROP VIEW IF EXISTS `event_instances`*/;
/*!50001 CREATE TABLE `event_instances` (
  `c_id` int(10) unsigned,
  `m_id` int(10) unsigned,
  `o_id` int(10) unsigned,
  `i_id` int(10) unsigned,
  `cdb_prefix` varchar(20),
  `cdb_customer` varchar(100),
  `cdb_machine` varchar(100),
  `cdb_object` varchar(50),
  `cdb_instance` varchar(250)
) ENGINE=MyISAM */;

--
-- Table structure for table `hourly_data_cwnt`
--

DROP TABLE IF EXISTS `hourly_data_cwnt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_cwnt` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_lahc`
--

DROP TABLE IF EXISTS `hourly_data_lahc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_lahc` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_sthc`
--

DROP TABLE IF EXISTS `hourly_data_sthc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_sthc` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_vltx`
--

DROP TABLE IF EXISTS `hourly_data_vltx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_vltx` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_stan`
--

DROP TABLE IF EXISTS `nagios_events_stan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_stan` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(512) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_sthc`
--

DROP TABLE IF EXISTS `nagios_events_sthc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_sthc` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(512) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_vltx`
--

DROP TABLE IF EXISTS `nagios_events_vltx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_vltx` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(512) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `t1`
--

DROP TABLE IF EXISTS `t1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t1` (
  `i_id` int(10) unsigned NOT NULL,
  `min_start` datetime,
  `next_start` datetime
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template_ds`
--

DROP TABLE IF EXISTS `template_ds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_ds` (
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `cdc_machine` varchar(45) NOT NULL,
  `cdc_object` varchar(45) NOT NULL,
  `cdc_instance` varchar(45) NOT NULL,
  `cdc_counter` varchar(45) NOT NULL,
  `speed` bigint(20) unsigned NOT NULL,
  `description` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template_dt`
--

DROP TABLE IF EXISTS `template_dt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_dt` (
  `sample_date` date NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  `sample_time` datetime default NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template_ev`
--

DROP TABLE IF EXISTS `template_ev`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_ev` (
  `i_id` int(10) unsigned default '0',
  `svc_id` int(10) unsigned NOT NULL,
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(512) NOT NULL,
  KEY `IDX_svc_id` (`svc_id`),
  KEY `IDX_entry_type` (`entry_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template_in`
--

DROP TABLE IF EXISTS `template_in`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_in` (
  `i_id` int(10) unsigned NOT NULL default '0',
  `m_id` int(10) unsigned NOT NULL default '0',
  `o_id` int(10) unsigned NOT NULL default '0',
  `svc_id` int(10) unsigned NOT NULL,
  `host` varchar(100) NOT NULL,
  `service` varchar(100) NOT NULL,
  `first_status_time` datetime default NULL,
  `latest_status_time` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test1`
--

DROP TABLE IF EXISTS `test1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test1` (
  `i_id` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'cdb_dev'
--
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_check_datasets` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_check_datasets`(
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*
This procedure expects a table called tempds to exist
with at least the following columns:

  cdc_dataset_id int(10) unsigned not null,
  cdc_machine varchar(45) not null,
  cdc_object varchar(45) not null,
  cdc_instance varchar(45) not null,
  cdc_counter varchar(45) not null

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_check_datasets';
declare rc integer default 0;
declare dsrcid integer default 0;

-- Check whether a unique datasource exists
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

-- Create datasource if one was not found
if rc = 0 then
  call cdb_create_datasource( p_prefix, p_srcsrv, p_srcapp );
  select count(*) from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into rc;
 end if;

-- Double check for valid datasource
if rc = 1 then
  select ds.id from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- Check for unmapped datasets
select count(*) from tempds tds
 where cdc_dataset_id not in (
   select cdc_dataset_id from m07_dataset_map where cdb_datasource_id = dsrcid
   )
 into rc;

-- Exit routine silently, if no new datasets were found
if rc = 0 then
  leave main;
 end if;

-- Log valid entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- Create input table for cdb_create_datasets
create temporary table if not exists temp_datasets (
  cdc_dataset_id int unsigned not null,
  cdc_prefix varchar(50) NOT NULL,
  cdc_machine varchar(50) NOT NULL,
  cdc_object varchar(50) NOT NULL,
  cdc_instance varchar(50) NOT NULL,
  cdc_counter varchar(50) NOT NULL,
  cdc_path varchar(512) NOT NULL
  ) DEFAULT CHARSET=latin1
  select cdc_dataset_id, p_prefix as cdc_prefix, cdc_machine, cdc_object, cdc_instance, cdc_counter,
	convert( concat( '\\\\', cdc_machine, '\\', cdc_object, '(', cdc_instance, ')\\', cdc_counter ) using latin1 ) AS cdc_path
 from tempds tds where cdc_dataset_id not in (
  select cdc_dataset_id from m07_dataset_map where cdb_datasource_id = dsrcid
  );

-- select * from temp_datasets;
call cdb_create_datasets();

-- Update Map table with new dataset mappings
insert into m07_dataset_map ( cdb_datasource_id, cdc_dataset_id, cdb_dataset_id )
  select dsrcid, t.cdc_dataset_id, d.id
    from temp_datasets t
     join m05_datasets d on t.cdc_prefix = d.cdb_prefix and t.cdc_path = d.cdb_path;

set rc = row_count();

drop temporary table temp_datasets;

-- Log results on exit
call cdb_logit( pn, concat( 'Exit - ', rc, ' new dataset mappings created' ) );

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_create_datasets` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_create_datasets`()
BEGIN

/*

This procedure creates new datasets by updating the underlying metadata tables.

It expects a temporary table called temp_datasets to exist containing the following columns :
	cdc_prefix        [varchar] (20) NOT NULL
	cdc_machine       [varchar] (200) NOT NULL
	cdc_object        [varchar] (50) NOT NULL
	cdc_instance      [varchar] (50) NULL
	cdc_counter       [varchar] (50) NOT NULL
	cdc_path          [varchar] (512) NOT NULL
If the table contains additional fields they will be ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_create_datasets';
declare rc integer default 0;

declare rcout integer default 0;

declare done int default 0;

-- Log entry
call cdb_logit( pn, concat( 'Enter' ) );

-- Create and populate temporary table to hold dataset details
create temporary table tt10 DEFAULT CHARSET=latin1
 select distinct c.id AS p_id, 0 AS m_id, 0 AS o_id, 0 AS i_id, 0 AS c_id,
	t.cdc_machine, t.cdc_object, t.cdc_instance, t.cdc_counter, t.cdc_prefix, t.cdc_path
 from temp_datasets t
  join m00_customers c on c.prefix = t.cdc_prefix
 where t.cdc_path not in (
	SELECT d.cdb_path FROM m05_datasets AS d where d.cdb_prefix = t.cdc_prefix
  );

-- Check for entries in tt10
select count(*) from tt10 into rc;

-- describe tt10;

-- Exit here if no data was found
if rc <= 0 then
  call cdb_logit( pn, concat( 'Exit - no new (valid) datasets found' ) );

  drop temporary table tt10;

  leave main;
 end if;

-- select * from tt10;

-- Log info message
call cdb_logit( pn, concat( 'Found ', rc, ' new (valid) datasets' ) );

-- select distinct 'tt10-machine',collation(cdb_machine) from tt10;
-- select distinct 'm01-machine', collation(name) from m01_machines;

-- ============
--   Machines
-- ============

-- Create entries for all new Machines
insert into m01_machines ( cdb_customer_id, name )
 select distinct t.p_id, t.cdc_machine from tt10 t
  where t.cdc_machine not in (
 select m.name from m01_machines m where m.cdb_customer_id = t.p_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new machines created' ) );
 end if;

 -- Update temp table with Machine IDs
update tt10 t join m01_machines m
 on t.p_id = m.cdb_customer_id and t.cdc_machine = m.name
 SET t.m_id = m.id;

-- ============
--   Objects
-- ============

-- create entries for all new objects
insert into m02_objects ( name )
 select distinct t.cdc_object from tt10 t
 where t.cdc_object not in ( select distinct name from m02_objects );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new objects created' ) );
 end if;

-- update temp table with object ids
update tt10 t join m02_objects o on t.cdc_object = o.name
 set t.o_id = o.id;

-- ============
--   Instances
-- ============

-- Create entries for all new Instances
insert into m03_instances ( cdb_machine_id, cdb_object_id, name )
 select distinct t.m_id, t.o_id, t.cdc_instance
 from tt10 t where t.cdc_instance not in (
	select name from m03_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new instances created' ) );
 end if;

-- Update temp table with Instance IDs
update tt10 t join m03_instances i on
 t.cdc_instance = i.name and t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id
 set t.i_id = i.id;

-- ============
--   Counters
-- ============

-- Create entries for all new Counters
insert into m04_counters ( cdb_object_id, name )
 select distinct t.o_id, t.cdc_counter from tt10 t
 where t.cdc_counter not in (
	select c.name from m04_counters c where c.cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new counters created' ) );
 end if;

-- Update temp table with Counter IDs
update tt10 t join m04_counters c
 on t.cdc_counter = c.name and t.o_id = c.cdb_object_id
 set t.c_id = c.id;


-- ====================
-- ... and finally, Datasets
-- ====================

-- Create entries for all the new DataSets
insert into m05_datasets (
 cdb_instance_id, cdb_counter_id, created_on, cdb_prefix, cdb_path )
 select t.i_id, t.c_id, now(), t.cdc_prefix, t.cdc_path
 from tt10 as t;

set rc = row_count();

-- Log results on exit
call cdb_logit( pn, concat( 'Exit - ', rc, ' new datasets created' ) );

select concat( 'cdb_create_datasets: ', rc, ' new datasets created' ) as msg;

-- Finally drop the temporary table
drop temporary table tt10;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_create_datasource` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_create_datasource`(
        p_prefix varchar(10),
        p_srcsrv varchar(50),
        p_srcapp varchar(50)
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_create_datasource';
declare rc integer default 0;
declare dsrcid integer default 0;
declare tabnam varchar(50);
declare pfxid int;

call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- Check for prefix
select count(*) from m00_customers where prefix = p_prefix into rc;

if rc = 1 then
  select id from m00_customers where prefix = p_prefix into pfxid;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - customer not found ***' ) );
  leave main;
 end if;

-- Check whether the datasource already exists
select count(*) from m06_datasources ds join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc >= 1 then
  call cdb_logit( pn, concat( 'Exit. *** Error - datasource already exists ***' ) );
  leave main;
 end if;

-- Check for data table type
if p_srcapp = 'nagevt' then
  set tabnam = concat( 'nagios_events_', lower(p_prefix) );
  set @sql = concat( 'create table if not exists ', tabnam, ' like dt15_nagios_events;' );
 else
  set tabnam = concat( 'hourly_data_', lower(p_prefix) );
  set @sql = concat( 'create table if not exists ', tabnam, ' like dt20_hourly_data;' );
 end if;

-- Create table if necessary
prepare nt from @sql;
execute nt;

-- Create new datasource
set @sql = concat( 'insert into m06_datasources ( cdb_customer_id, source_server, source_app, target_table ) ' );
set @sql = concat( @sql, ' values ( ', pfxid, ', ''', p_srcsrv, ''', ''', p_srcapp, ''', ''', tabnam, ''' );' );
prepare nd from @sql;
execute nd;

call cdb_logit( pn, concat( 'Exit - created datasource for table ', tabnam, ' ' ) );

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_import_data` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_import_data`(
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*
This procedure expects a table called tempdt to exist
with at least the following columns:

  sample_date date not null,
  sample_hour int(10) unsigned not null,
  cdc_dataset_id int(10) unsigned not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int(10) unsigned not null

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_import_data';
declare rc integer default 0;
declare dsrcid integer default 0;
declare hourtab varchar(50) default 'dt20_hourly_data';
declare sd date;
declare ed date;

-- log entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- ---------------------------
-- Validate datasource
-- ---------------------------

-- Check that a unique datasource exists
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.target_table from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, hourtab;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- Populate new columns
update tempdt dt join m07_dataset_map dm
 on dt.cdc_dataset_id = dm.cdc_dataset_id and dm.cdb_datasource_id = dsrcid
  set dt.cdb_dataset_id = dm.cdb_dataset_id,
      dt.sample_time = date_add(dt.sample_date, interval dt.sample_hour hour );

-- Delete duplicate data or unknown datasets
delete from tempdt where cdb_dataset_id = 0;

set @sql = concat( 'delete from tempdt dt using tempdt dt join ', hourtab, ' ht ' );
set @sql = concat( @sql, '  on dt.cdb_dataset_id = ht.cdb_dataset_id and ht.sample_time = dt.sample_time' );

prepare deldup from @sql;
execute deldup;

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( 'Discarded ', rc, ' duplicate rows' ) );
 end if;

-- Get bounds for date range to limit search of existing table data
select min(sample_date), max(date_add( sample_date, interval 1 day )) from tempdt into sd, ed;

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new mapped data
set @sql = concat( 'insert into ', hourtab, ' ' );
set @sql = concat( @sql, ' select sample_time, cdb_dataset_id, sample_date, sample_hour, ' );
set @sql = concat( @sql, '   data_min, data_max, data_sum, data_count from tempdt' );

prepare insnew from @sql;
execute insnew;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  call cdb_logit( pn, concat( 'Exit. No new data found' ) );
  select concat( 'cdb_import_data: No new data found'  ) as msg;
  leave main;
 end if;

-- update latest times in m05_datasets
set @sql = concat( 'update m05_datasets ds join ( ' );
set @sql = concat( @sql, '  select cdb_dataset_id, max(sample_time) as ''latest'' from ', hourtab, ' ' );
set @sql = concat( @sql, '   where sample_time between ''', sd, ''' and ''', ed, ''' group by cdb_dataset_id ' );
set @sql = concat( @sql, '   ) as t on ds.id = t.cdb_dataset_id set ds.dt20_latest=t.latest; ' );

prepare upd from @sql;
execute upd;

-- Log valid entry
call cdb_logit( pn, concat( 'Exit. Inserted ', rc, ' data rows into ', hourtab ) );

select concat( 'cdb_import_data: Inserted ', rc, ' data rows into ', hourtab  ) as msg;

-- End of main block
END;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_logit` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_logit`(pn varchar(80), txt varchar(1024))
BEGIN
insert into cdb_log (dt,pn,txt) values (now(),pn,txt);
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_update_dt30` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdb_update_dt30`(
        update_upto varchar(50),
        days_before int
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

/*
This procedure uses built in functions to determine the day of the week for a
given date and the week of the year for a date. The following conventions are
used here:

Day of week is determined using the DAYOFWEEK(date) function which returns the
days numbered from 1 to 7 with 1=Sunday and 7=Saturday.

Week of year is determined using the WEEK(date,mode) function with a mode of 0.
This returns the weeks numbered between 0 and 53. Weeks start on a Sunday and
week 1 is the first week containing a Sunday.

*/
-- Declare variables and cursors
declare pn varchar(50) default 'cdb_update_dt30';
declare rc integer default 0;
declare pfx varchar(10);
declare rcnew integer default 0;

declare done int default 0;
declare tabnam varchar(50);

declare sd datetime;
declare ed datetime;

-- Get list of data table prefixes (each prefix that has a datasource)
declare tabcur cursor for select distinct prefix from m00_customers m0 join m06_datasources m6 on m0.id = m6.cdb_customer_id;
declare continue handler for not found set done = 1;

if update_upto = '' then
  set ed = now();
 else
  set ed = cast(update_upto as datetime);
 end if;

if days_before <= 0 then
  set sd = date_sub( ed, interval 14 day );
 else
  set sd = date_sub( ed, interval days_before day );
 end if;

call cdb_logit( pn, concat( 'Enter (',update_upto,', ',days_before,') [ From ', sd, ' to ', ed, ' ]' ) );

-- Log entry
-- call cdb_logit( pn, concat( 'Enter - data update - daily' ) );

-- Create the temporary table with columns from dt20_hourly_data
-- and a column for day of week (dow : sun=1, mon=2 ..... sat=7)

create temporary table temp_data (
  sample_time datetime NOT NULL,
  cdb_dataset_id int(10) unsigned NOT NULL,
  sample_date datetime NOT NULL,
  sample_hour int(10) unsigned NOT NULL,
  data_min float NOT NULL,
  data_max float NOT NULL,
  data_sum float NOT NULL,
  data_count int(10) unsigned NOT NULL,
  sample_dow int
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

open tabcur;
-- Get first row from cursor
fetch next from tabcur into pfx;

-- Get data from each source table
repeat

--   select source data newer than latest target data
--   round down latest hourly data to a whole day and select data earlier

  set @sql = 'insert into temp_data ';
  set @sql = CONCAT( @sql, 'select dt.*, dayofweek(dt.sample_date) as sample_dow from hourly_data_', lower(pfx), ' dt ' );
  set @sql = CONCAT( @sql, '   inner join m05_datasets d on dt.cdb_dataset_id = d.id ' );
  set @sql = CONCAT( @sql, '  where dt.sample_date > d.dt30_latest and dt.sample_time < date(d.dt20_latest) ' );
  set @sql = CONCAT( @sql, '    and dt.sample_time between ''', sd, ''' and ''', ed, '''; ' );

  prepare itd from @sql;
  execute itd;

  set rc = row_count();
  call cdb_logit( pn, concat( 'Found ', rc, ' hourly data rows for prefix ', pfx ) );

  fetch next from tabcur into pfx;

 until done end repeat;

close tabcur;

select count(*) from temp_data into rc;

-- Exit here if no data was found
if rc <= 0 then
  drop temporary table temp_data;
  call cdb_logit( pn, concat( 'Exit - no new data found' ) );
  leave main;
 end if;

-- select * from temp_data;

-- insert daily data rows (shift 1 : 24x7)
insert into dt30_daily_data ( sample_time, cdb_dataset_id, cdb_shift_id, data_min, data_max,
	 data_sum, data_count, sample_week, sample_month, sample_year )
 select dt.sample_date, dt.cdb_dataset_id, 1 as shift_id,
    min(dt.data_min) as data_min, max(dt.data_max) as data_max,
    sum(dt.data_sum) as data_sum, sum(dt.data_count) as data_count,
    week(sample_date,0), month(sample_date), year(sample_date)
  from temp_data as dt
  group by dt.sample_date, dt.cdb_dataset_id;

set rc = row_count();
set rcnew = rcnew + rc;

-- Exit here if no data was found
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' daily data rows inserted (shift 1)' ) );
 end if;

-- insert daily data rows (shift 2 : M-F, 07:00 - 18:00)
insert into dt30_daily_data ( sample_time, cdb_dataset_id, cdb_shift_id, data_min, data_max,
	 data_sum, data_count, sample_week, sample_month, sample_year )
 select dt.sample_date, dt.cdb_dataset_id, 2 as shift_id,
    min(dt.data_min) as data_min, max(dt.data_max) as data_max,
    sum(dt.data_sum) as data_sum, sum(dt.data_count) as data_count,
    week(sample_date,0), month(sample_date), year(sample_date)
  from temp_data as dt
   where dt.sample_hour >= 7 and dt.sample_hour <= 18 and dt.sample_dow >=2 and dt.sample_dow <=6
  group by dt.sample_date, dt.cdb_dataset_id;

set rc = row_count();
set rcnew = rcnew + rc;

-- Exit here if no data was found
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' daily data rows inserted (shift 2)' ) );
 end if;

-- update latest dates in m05_datasets
if rcnew > 0 then
  update m05_datasets ds join (
   select cdb_dataset_id, max(sample_time) as 'latest' from dt30_daily_data group by cdb_dataset_id
   ) as t on ds.id = t.cdb_dataset_id
  set ds.dt30_latest=t.latest;
 end if;

-- report results
call cdb_logit( pn, concat( 'Exit - ', rcnew, ' daily data rows inserted' ) );

-- Finally drop the temporary table
drop table temp_data;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `event_info` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `event_info`(
        p_prefix varchar(10),
        p_start datetime,
        p_end datetime
        )
BEGIN

declare p_total int;
set p_total = TIMESTAMPDIFF(SECOND,p_start,p_end);

select entry_type,
 count(*), sum( TIMESTAMPDIFF( SECOND,
 CASE when start_time < p_start then p_start else start_time END,
 CASE when end_time is null then p_end when end_time > p_end then p_end else end_time END
 )) dur,
 100 * sum( TIMESTAMPDIFF( SECOND,
 CASE when start_time < p_start then p_start else start_time END,
 CASE when end_time is null then p_end when end_time > p_end then p_end else end_time END
 )) / p_total as '% dur'
 from nagios_events_sthc e
 where e.start_time < p_end and ( end_time > p_start or end_time is null )
 group by entry_type;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `lsr` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `lsr`()
BEGIN
  select * from cdb_log order by id desc limit 100;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `nag_check_instances` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `nag_check_instances`(
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*

The procedure creates new machine and instance records as required.

Input table: tempin

The table is expected to exist with at least the following columns:

  `svc_id` varchar(100) NOT NULL,
  `host` varchar(100) NOT NULL,
  `service` varchar(100) default NULL,
  `first_status_time` datetime NOT NULL,
  `latest_status_time` datetime  NOT NULL

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'nag_check_instances';
declare msg varchar(250) default '';
declare rc integer default 0;
declare mrc integer default 0;
declare irc integer default 0;
declare dsrcid integer default 0;
declare custid integer default 0;

-- ---------------------------------------
-- Check that a unique datasource exists
-- ---------------------------------------
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.cdb_customer_id from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, custid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  set msg = concat( '*** Error - ', rc, ' datasources found ***' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- ---------------------------------------
--  Create machines from any new hosts
-- ---------------------------------------
insert into m01_machines ( cdb_customer_id, name )
 select custid, t.host
  from ( select distinct host from tempin ) t
 where t.host not in ( select name from m01_machines m where m.cdb_customer_id = custid );

set mrc = row_count();

-- Report machine creation, if any were found
if mrc > 0 then
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  set msg = concat( mrc, ' new machines created, ' );
 end if;

-- Populate tempin with machine IDs
update tempin t join m01_machines m
 on m.name = t.host and m.cdb_customer_id = custid
 set t.m_id = m.id;

-- ---------------------------------------
-- Populate tempin with object IDs
-- ---------------------------------------
update tempin t join m02_objects o
 on o.name = IF(service= _latin1 '', _latin1 'NagiosHostEvent', _latin1 'NagiosServiceEvent')
 set t.o_id = o.id;

-- ---------------------------------------
 -- Create entries for all new Instances
-- ---------------------------------------
insert into m03_instances ( cdb_machine_id, cdb_object_id, name, first_status_time, latest_status_time )
 select t.m_id, t.o_id, t.service, t.first_status_time, t.latest_status_time
 from tempin t where t.service not in (
  select name from m03_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id
  );

set irc = row_count();

-- Handle instance creation, if any were found
if irc > 0 then

  if mrc = 0 then
    call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
   end if;

  set msg = concat( msg, irc, ' new instances created.' );

  end if;

-- Populate tempin with instance IDs
update tempin t join m03_instances i
  on t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id and t.service = i.name
 set t.i_id = i.id;

-- Update tempev with Instance IDs
update tempev e join tempin i on e.svc_id = i.svc_id
 set e.i_id = i.i_id;

-- Update instance table with latest times
update m03_instances i join tempin t on t.i_id = i.id
 set i.latest_status_time = t.latest_status_time;

if msg <> '' then
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
 end if;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `nag_import_events` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `nag_import_events`(
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*
This procedure expects a table called tempdt to exist
with at least the following columns:

  sample_date date not null,
  sample_hour int(10) unsigned not null,
  cdc_dataset_id int(10) unsigned not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int(10) unsigned not null

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'nag_import_events';
declare rc integer default 0;
declare dsrcid integer default 0;
declare eventtab varchar(50) default 'dt15_nagios_events';
declare msg varchar(250) default '';

-- log entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- ---------------------------
-- Validate datasource
-- ---------------------------

-- Check that a unique datasource exists
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.target_table from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, eventtab;
 else
  set msg = concat( '*** Error - ', rc, ' datasources found ***' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- ---------------------------
-- Obtain instance lookup table
-- ---------------------------
call nag_check_instances( p_prefix, p_srcsrv, p_srcapp );

-- ---------------------------
-- Discard duplicate data
-- ---------------------------

-- Discard events that already exist
set @sql = concat( 'delete tempev t from tempev t join ', eventtab, ' e '  );
set @sql = concat( @sql, '   on t.start_time = e.start_time and t.i_id = e.cdb_instance_id ' );

prepare dup from @sql;
execute dup;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  set msg = concat( 'Discarded ', rc, ' duplicate events' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;


-- -------------------------------
-- Process CURRENT_x_STATE events
-- -------------------------------

-- Discard 'current' events if they already exist in the same state
set @sql = concat( 'delete tempev t from tempev t join ', eventtab, ' e on t.i_id = e.cdb_instance_id ' );
set @sql = concat( @sql, '  and t.ev_state = e.ev_state ' ); -- and t.hard_soft = e.hard_soft
set @sql = concat( @sql, ' where t.entry_type in ( ''CURRENT HOST STATE'', ''CURRENT SERVICE STATE'' ) and e.end_time is null ' );
set @sql = concat( @sql, '   and t.start_time >= e.start_time and t.end_time is null ' );

prepare dup from @sql;
execute dup;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  set msg = concat( 'Discarded ', rc, ' open but unchanged current state entries' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;

-- Close any open events that match current states
set @sql = concat( 'update ', eventtab, ' e join tempev t on t.i_id = e.cdb_instance_id ' );
set @sql = concat( @sql, '  and t.ev_state = e.ev_state ' ); --  and t.hard_soft = e.hard_soft
set @sql = concat( @sql, ' set t.svc_id = 0, e.end_time = t.end_time, e.next_state = t.next_state, ' );
set @sql = concat( @sql, '   e.duration = timestampdiff(SECOND,e.start_time,t.end_time) ' );
set @sql = concat( @sql, ' where t.entry_type in ( ''CURRENT HOST STATE'', ''CURRENT SERVICE STATE'' ) and e.end_time is null ' );
set @sql = concat( @sql, '   and t.start_time >= e.start_time and t.end_time is not null ' );

prepare upd from @sql;
execute upd;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  -- rc is twice the no of events closed since an update was made to both tables
  set rc = rc / 2;
  set msg = concat( 'Closed ', rc, ' existing open events from current state entries' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;

-- Discard the current state events that closed existing events
delete from tempev where svc_id = 0;

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new event data
set @sql = concat( 'insert into ', eventtab, ' (start_time, cdb_instance_id, cdb_datasource_id, ' );
set @sql = concat( @sql, '  end_time, duration, ev_state, hard_soft, next_state, entry_type, message) ' );
set @sql = concat( @sql, ' select start_time, i_id, ', dsrcid, ', end_time, duration, ev_state, ' );
set @sql = concat( @sql, '   hard_soft, next_state, entry_type, message  from tempev' );

prepare imp from @sql;
execute imp;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  set msg = concat( 'No new events found' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- Log valid entry
set msg = concat( 'Inserted ', rc, ' event rows into ', eventtab );
call cdb_logit( pn, concat( 'Exit. ', msg ) );

-- Return a resultset consisting of the exit message
select msg;

-- End of main block
END;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `web_get_chart_data` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `web_get_chart_data`(
 p_prefix varchar(50),
 p_seltype varchar(50),
 p_selection varchar(50),
 p_startdate datetime,
 p_enddate datetime,
 p_period int
 )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare done int default 0;
-- declare piv varchar(50);
-- declare pivcur cursor for select pivot from pivot;

declare sd datetime;
declare ed datetime;

declare continue handler for 1051 set done = 1;

drop table if exists TempDatasets;
drop table if exists TempData;
drop table if exists TempSeries;

-- *************** Param validation ***************

set sd = p_startdate;
set ed = p_enddate;

-- *************** Dataset Selection ***************

create temporary table TempDatasets (
  dataset_id int not null,
  prefix varchar(50) not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

if p_seltype = 'Machine' then
  -- Machine selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.dataset_id, dd.prefix, dd.counter as selection, dd.instance as series
    from dataset_details dd
   where dd.prefix = p_prefix and dd.machine = p_selection;
 else
  -- Counter selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.dataset_id, dd.prefix, dd.machine as selection, dd.instance as series
    from dataset_details dd
   where dd.prefix = p_prefix and dd.counter = p_selection;
 end if;

-- select * from TempDatasets;
-- drop table TempDatasets;


-- *************** Table specific portion ***************

create temporary table TempData (
  sample_time datetime not null,
  dataset_id int not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int not null
  );

if p_period = 21 then
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select date_add(''1900-01-01'', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, ''' ' );
  set @sql = concat( @sql, ' group by sample_hour, cdb_dataset_id;' );
  prepare tmpd from @sql;
  execute tmpd;
 elseif p_period = 20 then
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, '''; ' );
  prepare tmpd from @sql;
  execute tmpd;
 else
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from dt30_daily_data dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= sd and sample_time < ed;
 end if;

-- select * from TempData limit 10;

-- *************** Data Processing portion ***************

create temporary table TempSeries (
  sample_time datetime not null,
  data_type varchar(20) not null,
  data_val float not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Min', data_min, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Max', data_max, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Avg', data_sum / data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Cnt', data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

drop table TempDatasets;
drop table TempData;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
DELIMITER ;

--
-- Final view structure for view `dataset_details`
--

/*!50001 DROP TABLE `dataset_details`*/;
/*!50001 DROP VIEW IF EXISTS `dataset_details`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `dataset_details` AS select `m5`.`id` AS `cdb_dataset_id`,`m0`.`prefix` AS `cdb_prefix`,`m1`.`machine_name` AS `cdb_machine`,`m2`.`object_name` AS `cdb_object`,`m3`.`instance_name` AS `cdb_instance`,`m4`.`counter_name` AS `cdb_counter` from (((((`cdb_datasets` `m5` join `cdb_counters` `m4` on((`m4`.`id` = `m5`.`cdb_counter_id`))) join `cdb_instances` `m3` on((`m3`.`id` = `m5`.`cdb_instance_id`))) join `cdb_objects` `m2` on((`m2`.`id` = `m3`.`cdb_object_id`))) join `cdb_machines` `m1` on((`m1`.`id` = `m3`.`cdb_machine_id`))) join `cdb_customers` `m0` on((`m0`.`id` = `m1`.`cdb_customer_id`))) */;

--
-- Final view structure for view `event_instances`
--

/*!50001 DROP TABLE `event_instances`*/;
/*!50001 DROP VIEW IF EXISTS `event_instances`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `event_instances` AS select `c`.`id` AS `c_id`,`m`.`id` AS `m_id`,`o`.`id` AS `o_id`,`i`.`id` AS `i_id`,`c`.`prefix` AS `cdb_prefix`,`c`.`customer_name` AS `cdb_customer`,`m`.`machine_name` AS `cdb_machine`,`o`.`object_name` AS `cdb_object`,`i`.`instance_name` AS `cdb_instance` from (((`cdb_customers` `c` join `cdb_machines` `m` on((`c`.`id` = `m`.`cdb_customer_id`))) join `cdb_instances` `i` on((`i`.`cdb_machine_id` = `m`.`id`))) join `cdb_objects` `o` on((`o`.`id` = `i`.`cdb_object_id`))) where (`o`.`type` = _utf8'event') */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_dev
-- ------------------------------------------------------
-- Server version	5.0.45

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
-- Table structure for table `cdb_customers`
--

DROP TABLE IF EXISTS `cdb_customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_customers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefix` varchar(20) default NULL,
  `customer_name` varchar(100) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_prefix_unique` USING BTREE (`prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdb_customers`
--

LOCK TABLES `cdb_customers` WRITE;
/*!40000 ALTER TABLE `cdb_customers` DISABLE KEYS */;
INSERT INTO `cdb_customers` VALUES (57,'AAML','Arts Alliance Media Ltd',NULL,NULL),(58,'ABCO','Askham Bryan College',NULL,NULL),(59,'APTO','Apetito Limited',NULL,NULL),(60,'BIFL','Bishop Fleming',NULL,NULL),(61,'BLNW','Business Link Northwest',NULL,NULL),(62,'BRCC','Bristol City Council',NULL,NULL),(63,'CLNH','Clarendon House',NULL,NULL),(64,'CLRH','Claire House',NULL,NULL),(65,'CWNT','Chelsea & Westminster NHS Trust',NULL,NULL),(66,'DIDA','DiData',NULL,NULL),(67,'EDET','eDT',NULL,NULL),(68,'EMSI','ems-Internet',NULL,NULL),(69,'FANL','Fantasy League',NULL,NULL),(70,'HRDS','Harrods Limited',NULL,NULL),(71,'IKON','IKON',NULL,NULL),(72,'IMJA','IMERJA Limited',NULL,NULL),(73,'INVM','Invmo Limited',NULL,NULL),(74,'ITRM','IT Resource Management',NULL,NULL),(75,'KWBC','Knowsley Metropolitan Borough Council',NULL,NULL),(76,'KWHT','Knowsley Housing Trust',NULL,NULL),(77,'LBRE','London Borough of Redbridge',NULL,NULL),(78,'LORO','London Overground Rail Operations Ltd',NULL,NULL),(79,'MAFR','Manchester Fire and Rescue',NULL,NULL),(80,'MPAY','MiPay',NULL,NULL),(81,'MRCO','Medical Research Council',NULL,NULL),(82,'NELC','North East Lincolnshire Council',NULL,NULL),(83,'NOBI','Nobisco',NULL,NULL),(84,'NWLG','North West Learning Grid',NULL,NULL),(85,'OTWO','O2',NULL,NULL),(86,'PTOP','Point to Point',NULL,NULL),(87,'REDE','Retail Decisions',NULL,NULL),(88,'RNLI','RNLI LifeBoat',NULL,NULL),(89,'RWAL','Rockwood Additives Limited',NULL,NULL),(90,'SABC','Salford MBC',NULL,NULL),(91,'SDSO','Specialist Data Solutions',NULL,NULL),(92,'SEBC','Sefton MBC',NULL,NULL),(93,'STHC','St.Helens MBC',NULL,NULL),(94,'SNTX','Synetrix',NULL,NULL),(95,'SOUN','Southampton University',NULL,NULL),(96,'SPEN','Sport England',NULL,NULL),(97,'STAN','St Andrews',NULL,NULL),(98,'SUDI','Supporter Direct',NULL,NULL),(99,'SUHI','Sussex HIS',NULL,NULL),(100,'TAPL','Talentplan / Clicks and Links',NULL,NULL),(101,'TRHT','Trafford Housing Trust',NULL,NULL),(102,'TOTE','Totesport',NULL,NULL),(103,'UNPA','Unity Partnership',NULL,NULL),(104,'VIME','Virgin Media',NULL,NULL),(105,'VLTX','Vaultex UK',NULL,NULL),(106,'WKBC','Wakefield Metopolitan District Council',NULL,NULL),(107,'WRBC','Warrington Borough Council',NULL,NULL),(108,'LAHC','Lancashire Health Community',NULL,NULL),(109,'SELF','Selfridges Ltd',NULL,NULL),(110,'STJP','St James Place',NULL,NULL);
/*!40000 ALTER TABLE `cdb_customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cdb_objects`
--

DROP TABLE IF EXISTS `cdb_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_objects` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `object_name` varchar(50) NOT NULL,
  `type` varchar(50) default NULL,
  `subsystem` varchar(50) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_object_name_unique` USING BTREE (`object_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdb_objects`
--

LOCK TABLES `cdb_objects` WRITE;
/*!40000 ALTER TABLE `cdb_objects` DISABLE KEYS */;
INSERT INTO `cdb_objects` VALUES (1,'Interface','capacity',NULL,NULL,NULL),(2,'NagiosHostEvent','event',NULL,NULL,NULL),(3,'NagiosServiceEvent','event',NULL,NULL,NULL),(4,'NagiosOtherEvent','event',NULL,NULL,NULL);
/*!40000 ALTER TABLE `cdb_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cdb_datasources`
--

DROP TABLE IF EXISTS `cdb_datasources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_datasources` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `source_server` varchar(45) NOT NULL,
  `source_app` varchar(45) NOT NULL,
  `target_table` varchar(45) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_datasource_customer` USING BTREE (`cdb_customer_id`),
  CONSTRAINT `FK_datasource_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `cdb_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdb_datasources`
--

LOCK TABLES `cdb_datasources` WRITE;
/*!40000 ALTER TABLE `cdb_datasources` DISABLE KEYS */;
INSERT INTO `cdb_datasources` VALUES (1,108,'lancsman','rtg','hourly_data_lahc',NULL,NULL),(2,108,'lancsman','rtg2','hourly_data_lahc',NULL,NULL),(3,93,'sthman3','rtg','hourly_data_sthc',NULL,NULL),(4,105,'vaultexman2','rtg','hourly_data_vltx',NULL,NULL),(5,65,'chelseaman2','rtg','hourly_data_cwnt',NULL,NULL),(6,93,'sthman3','nagevt','nagios_events_sthc',NULL,NULL),(7,105,'vaultexman2','nagevt','nagios_events_vltx',NULL,NULL),(8,97,'staman2','nagevt','nagios_events_stan',NULL,NULL);
/*!40000 ALTER TABLE `cdb_datasources` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
