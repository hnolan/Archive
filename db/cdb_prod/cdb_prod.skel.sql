-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_prod
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
  `counter_type` varchar(45) default NULL,
  `counter_subtype` varchar(45) default NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=3346 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_event_states`
--

DROP TABLE IF EXISTS `cdb_event_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_event_states` (
  `id` int(11) NOT NULL default '0',
  `o_id` int(11) default NULL,
  `event_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
  `event_grade` enum('HARD','SOFT') NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdb_event_status`
--

DROP TABLE IF EXISTS `cdb_event_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdb_event_status` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_status` (`ev_state`,`hard_soft`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
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
  `speed` bigint(20) unsigned default NULL,
  `description` varchar(250) default NULL,
  `service_type` enum('AVAIL','THRESH','INFO') NOT NULL default 'AVAIL',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_instance_name_unique` USING BTREE (`cdb_machine_id`,`cdb_object_id`,`instance_name`),
  KEY `FK_instance_object` USING BTREE (`cdb_object_id`),
  CONSTRAINT `FK_instance_machine` FOREIGN KEY (`cdb_machine_id`) REFERENCES `cdb_machines` (`id`),
  CONSTRAINT `FK_instance_object` FOREIGN KEY (`cdb_object_id`) REFERENCES `cdb_objects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6287 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
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
) ENGINE=InnoDB AUTO_INCREMENT=16304 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
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
) ENGINE=InnoDB AUTO_INCREMENT=1185 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
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
  `parent_name` varchar(50),
  `inst_desc` varchar(250),
  `cdb_counter` varchar(50),
  `counter_type` varchar(45),
  `counter_subtype` varchar(45)
) ENGINE=MyISAM */;

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
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`,`cdb_shift_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
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
  `cdb_instance` varchar(250),
  `first_status_time` datetime,
  `latest_status_time` datetime,
  `service_type` enum('AVAIL','THRESH','INFO')
) ENGINE=MyISAM */;

--
-- Table structure for table `evt_stats_daily`
--

DROP TABLE IF EXISTS `evt_stats_daily`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evt_stats_daily` (
  `sample_date` date NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `event_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
  `event_grade` enum('HARD','SOFT') NOT NULL,
  `event_duration` int(10) unsigned NOT NULL,
  `event_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`sample_date`,`cdb_instance_id`,`event_state`,`event_grade`),
  KEY `IDX_event_state` (`event_state`),
  KEY `IDX_event_grade` (`event_grade`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evt_stats_monthly`
--

DROP TABLE IF EXISTS `evt_stats_monthly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evt_stats_monthly` (
  `sample_year` int(10) unsigned NOT NULL,
  `sample_month` int(10) unsigned NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `event_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
  `event_grade` enum('HARD','SOFT') NOT NULL,
  `event_duration` int(10) unsigned NOT NULL,
  `event_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`sample_year`,`sample_month`,`cdb_instance_id`,`event_state`,`event_grade`),
  KEY `IDX_event_state` (`event_state`),
  KEY `IDX_event_grade` (`event_grade`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_chwe0d`
--

DROP TABLE IF EXISTS `hourly_data_chwe0d`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_chwe0d` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` USING BTREE (`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_lahc0n`
--

DROP TABLE IF EXISTS `hourly_data_lahc0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_lahc0n` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_merge`
--

DROP TABLE IF EXISTS `hourly_data_merge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_merge` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
) ENGINE=MRG_MyISAM DEFAULT CHARSET=utf8 UNION=(`hourly_data_chwe0d`,`hourly_data_lahc0n`,`hourly_data_sthc0n`,`hourly_data_vltx0n`);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_sthc0n`
--

DROP TABLE IF EXISTS `hourly_data_sthc0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_sthc0n` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hourly_data_vltx0n`
--

DROP TABLE IF EXISTS `hourly_data_vltx0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hourly_data_vltx0n` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `interface_details`
--

DROP TABLE IF EXISTS `interface_details`;
/*!50001 DROP VIEW IF EXISTS `interface_details`*/;
/*!50001 CREATE TABLE `interface_details` (
  `cdb_dataset_id` int(10) unsigned,
  `cdb_prefix` varchar(20),
  `cdb_machine` varchar(100),
  `cdb_object` varchar(50),
  `i_id` int(10) unsigned,
  `cdb_instance` varchar(250),
  `parent_name` varchar(50),
  `inst_desc` varchar(250),
  `cdb_counter` varchar(50),
  `counter_type` varchar(45),
  `counter_subtype` varchar(45)
) ENGINE=MyISAM */;

--
-- Temporary table structure for view `interface_util_details`
--

DROP TABLE IF EXISTS `interface_util_details`;
/*!50001 DROP VIEW IF EXISTS `interface_util_details`*/;
/*!50001 CREATE TABLE `interface_util_details` (
  `cdb_dataset_id` int(10) unsigned,
  `cdb_prefix` varchar(20),
  `cdb_machine` varchar(100),
  `cdb_object` varchar(50),
  `i_id` int(10) unsigned,
  `cdb_instance` varchar(250),
  `parent_name` varchar(50),
  `inst_desc` varchar(250),
  `cdb_counter` varchar(50),
  `counter_type` varchar(45),
  `counter_subtype` varchar(45)
) ENGINE=MyISAM */;

--
-- Table structure for table `nagios_events_chwe0d`
--

DROP TABLE IF EXISTS `nagios_events_chwe0d`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_chwe0d` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_lahc0n`
--

DROP TABLE IF EXISTS `nagios_events_lahc0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_lahc0n` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_merge`
--

DROP TABLE IF EXISTS `nagios_events_merge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_merge` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MRG_MyISAM DEFAULT CHARSET=utf8 UNION=(`nagios_events_chwe0d`,`nagios_events_lahc0n`,`nagios_events_self0d`,`nagios_events_stah0d`,`nagios_events_sthc0n`,`nagios_events_vltx0n`);
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_self0d`
--

DROP TABLE IF EXISTS `nagios_events_self0d`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_self0d` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_stah0d`
--

DROP TABLE IF EXISTS `nagios_events_stah0d`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_stah0d` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_sthc0n`
--

DROP TABLE IF EXISTS `nagios_events_sthc0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_sthc0n` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nagios_events_vltx0n`
--

DROP TABLE IF EXISTS `nagios_events_vltx0n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nagios_events_vltx0n` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prf_monthly_data`
--

DROP TABLE IF EXISTS `prf_monthly_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prf_monthly_data` (
  `sample_year` int(10) unsigned NOT NULL,
  `sample_month` int(10) unsigned NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `cdb_shift_id` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_year`,`sample_month`,`cdb_dataset_id`,`cdb_shift_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
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
  `min_start` datetime default NULL,
  `next_start` datetime default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tds`
--

DROP TABLE IF EXISTS `tds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tds` (
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
-- Table structure for table `tempin`
--

DROP TABLE IF EXISTS `tempin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tempin` (
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
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  KEY `IDX_svc_id` (`svc_id`),
  KEY `IDX_entry_type` (`entry_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template_hourly_data`
--

DROP TABLE IF EXISTS `template_hourly_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_hourly_data` (
  `sample_time` datetime NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  `sample_date` datetime NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`cdb_dataset_id`),
  KEY `IDX_dsid` (`cdb_dataset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
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
-- Table structure for table `template_nagios_events`
--

DROP TABLE IF EXISTS `template_nagios_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template_nagios_events` (
  `start_time` datetime NOT NULL,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `end_time` datetime default NULL,
  `duration` int(10) unsigned default '0',
  `ev_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN') NOT NULL,
  `hard_soft` enum('HARD','SOFT') NOT NULL,
  `next_state` enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','CLOSED') default NULL,
  `entry_type` enum('CURRENT HOST STATE','CURRENT SERVICE STATE','HOST ALERT','SERVICE ALERT') NOT NULL,
  `message` varchar(1024) NOT NULL,
  PRIMARY KEY  (`start_time`,`cdb_instance_id`),
  KEY `IDX_end_time` (`end_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'cdb_prod'
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
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

-- Create datasource if one was not found
if rc = 0 then
  call cdb_create_datasource( p_prefix, p_srcsrv, p_srcapp );
  select count(*) from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into rc;
 end if;

-- Double check for valid datasource
if rc = 1 then
  select ds.id from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
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
   select cdc_dataset_id from cdb_dataset_map where cdb_datasource_id = dsrcid
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
  ) DEFAULT CHARSET=utf8
  select cdc_dataset_id, p_prefix as cdc_prefix, cdc_machine, cdc_object, cdc_instance, cdc_counter,
	convert( concat( '\\\\', cdc_machine, '\\', cdc_object, '(', cdc_instance, ')\\', cdc_counter ) using utf8 ) AS cdc_path
 from tempds tds where cdc_dataset_id not in (
  select cdc_dataset_id from cdb_dataset_map where cdb_datasource_id = dsrcid
  );

-- select * from temp_datasets;
call cdb_create_datasets();

-- Update Map table with new dataset mappings
insert into cdb_dataset_map ( cdb_datasource_id, cdc_dataset_id, cdb_dataset_id )
  select dsrcid, t.cdc_dataset_id, d.id
    from temp_datasets t
     join cdb_datasets d on t.cdc_prefix = d.cdb_prefix and t.cdc_path = d.cdb_path;

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
create temporary table tt10 DEFAULT CHARSET=utf8
 select distinct c.id AS p_id, 0 AS m_id, 0 AS o_id, 0 AS i_id, 0 AS c_id,
	t.cdc_machine, t.cdc_object, t.cdc_instance, t.cdc_counter, t.cdc_prefix, t.cdc_path
 from temp_datasets t
  join cdb_customers c on c.prefix = t.cdc_prefix
 where t.cdc_path not in (
	SELECT d.cdb_path FROM cdb_datasets AS d where d.cdb_prefix = t.cdc_prefix
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

-- ============
--   Machines
-- ============

-- Create entries for all new Machines
insert into cdb_machines ( cdb_customer_id, machine_name )
 select distinct t.p_id, t.cdc_machine from tt10 t
  where t.cdc_machine not in (
 select m.machine_name from cdb_machines m where m.cdb_customer_id = t.p_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new machines created' ) );
 end if;

 -- Update temp table with Machine IDs
update tt10 t join cdb_machines m
 on t.p_id = m.cdb_customer_id and t.cdc_machine = m.machine_name
 SET t.m_id = m.id;

-- ============
--   Objects
-- ============

-- create entries for all new objects
insert into cdb_objects ( object_name )
 select distinct t.cdc_object from tt10 t
 where t.cdc_object not in ( select distinct object_name from cdb_objects );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new objects created' ) );
 end if;

-- update temp table with object ids
update tt10 t join cdb_objects o on t.cdc_object = o.object_name
 set t.o_id = o.id;

-- ============
--   Instances
-- ============

-- Create entries for all new Instances
insert into cdb_instances ( cdb_machine_id, cdb_object_id, instance_name )
 select distinct t.m_id, t.o_id, t.cdc_instance
 from tt10 t where t.cdc_instance not in (
	select instance_name from cdb_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new instances created' ) );
 end if;

-- Update temp table with Instance IDs
update tt10 t join cdb_instances i on
 t.cdc_instance = i.instance_name and t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id
 set t.i_id = i.id;

-- ============
--   Counters
-- ============

-- Create entries for all new Counters
insert into cdb_counters ( cdb_object_id, counter_name )
 select distinct t.o_id, t.cdc_counter from tt10 t
 where t.cdc_counter not in (
	select c.counter_name from cdb_counters c where c.cdb_object_id = t.o_id );

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' new counters created' ) );
 end if;

-- Update temp table with Counter IDs
update tt10 t join cdb_counters c
 on t.cdc_counter = c.counter_name and t.o_id = c.cdb_object_id
 set t.c_id = c.id;


-- ====================
-- ... and finally, Datasets
-- ====================

-- Create entries for all the new DataSets
insert into cdb_datasets (
 cdb_instance_id, cdb_counter_id, created_at, cdb_prefix, cdb_path )
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
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
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
select count(*) from cdb_customers where prefix = p_prefix into rc;

if rc = 1 then
  select id from cdb_customers where prefix = p_prefix into pfxid;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - customer not found ***' ) );
  leave main;
 end if;

-- Check whether the datasource already exists
select count(*) from cdb_datasources ds join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc >= 1 then
  call cdb_logit( pn, concat( 'Exit. *** Error - datasource already exists ***' ) );
  leave main;
 end if;

-- Check for data table type
if p_srcapp = 'nagevt' then
  set tabnam = concat( 'nagios_events_', lower(p_prefix) );
  set @sql = concat( 'create table if not exists ', tabnam, ' like template_nagios_events;' );
 else
  set tabnam = concat( 'hourly_data_', lower(p_prefix) );
  set @sql = concat( 'create table if not exists ', tabnam, ' like template_hourly_data;' );
 end if;

-- Create table if necessary
prepare nt from @sql;
execute nt;

-- Create new datasource
set @sql = concat( 'insert into cdb_datasources ( cdb_customer_id, source_server, source_app, target_table ) ' );
set @sql = concat( @sql, ' values ( ', pfxid, ', ''', p_srcsrv, ''', ''', p_srcapp, ''', ''', tabnam, ''' );' );
prepare nd from @sql;
execute nd;

call cdb_logit( pn, concat( 'Exit - created datasource for table ', tabnam, ' ' ) );

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_import_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
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
declare hourtab varchar(50) default 'template_hourly_data';
declare sd date;
declare ed date;

-- log entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- ---------------------------
-- Validate datasource
-- ---------------------------

-- Check that a unique datasource exists
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, hourtab;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- Populate new columns
update tempdt dt join cdb_dataset_map dm
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

-- update latest times in cdb_datasets
set @sql = concat( 'update cdb_datasets ds join ( ' );
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
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
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
declare tabcur cursor for select distinct prefix from cdb_customers m0 join cdb_datasources m6 on m0.id = m6.cdb_customer_id where source_app = 'rtg';
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

-- Create the temporary table with columns from template_hourly_data
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

open tabcur;
-- Get first row from cursor
fetch next from tabcur into pfx;

-- Get data from each source table
repeat

--   select source data newer than latest target data
--   round down latest hourly data to a whole day and select data earlier

  set @sql = 'insert into temp_data ';
  set @sql = CONCAT( @sql, 'select dt.*, dayofweek(dt.sample_date) as sample_dow from hourly_data_', lower(pfx), ' dt ' );
  set @sql = CONCAT( @sql, '   inner join cdb_datasets d on dt.cdb_dataset_id = d.id ' );
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

-- update latest dates in cdb_datasets
if rcnew > 0 then
  update cdb_datasets ds join (
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
/*!50003 DROP PROCEDURE IF EXISTS `evt_update_stats_daily` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `evt_update_stats_daily`(
        update_upto varchar(50),
        days_before int
        )
BEGIN

-- Declare variables
declare pn varchar(50) default 'evt_update_stats_daily';
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);

-- ---------------------
--  Validate params
-- ---------------------

if update_upto = '' then
  set ed = now();
 else
  set ed = cast(update_upto as date);
 end if;

if days_before <= 0 then
  set sd = date_sub( ed, interval 14 day );
 else
  set sd = date_sub( ed, interval days_before day );
 end if;

call cdb_logit( pn, concat( 'Enter (',update_upto,', ',days_before,') [ From ', sd, ' to ', ed, ' ]' ) );

-- ---------------------
--  Generate slot table
-- ---------------------

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
 slot_start date,
 slot_end date,
 slot_duration int
 );

-- Generate time slots; populate table with daily dates
set d1 = sd;
while d1 < ed do
  set d2 = date_add( d1, interval 1 day );
  insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, timestampdiff( second, d1, d2 ) );
  set d1 = d2;
 end while;

ALTER TABLE temp_slots ADD INDEX `IDX_slot_start`(`slot_start`);
ALTER TABLE temp_slots ADD INDEX `IDX_slot_end`(`slot_end`);

-- select * from temp_slots;

-- ----------------------------
--  Select/Slice events to slots
-- ----------------------------
create temporary table temp_event_slots
 select slot_start as sample_date, cdb_instance_id, ev_state as event_state, hard_soft as event_grade,
   TIMESTAMPDIFF( SECOND, greatest(start_time,slot_start), least(end_time,slot_end) ) as effective_duration
 from nagios_events_merge e
  cross join temp_slots s
   -- Select only completed events - ignore events with NULL end_time
 where start_time < ed and end_time > sd
  and start_time < slot_end and end_time > slot_start;

-- select * from temp_event_slots order by sample_date, cdb_instance_id;

-- ----------------------------
--  Aggregate slot data
-- ----------------------------

-- Aggregate event data to temp table
create temporary table temp_agg_event_slots
 select sample_date, cdb_instance_id, event_state, event_grade,
  sum(effective_duration) as event_duration, count(*) as event_count
 from temp_event_slots
  group by sample_date, cdb_instance_id, event_state, event_grade;

-- select * from temp_agg_event_slots order by sample_date, cdb_instance_id;

-- ----------------------------
--  Update daily table
-- ----------------------------

-- Insert new event data into daily table
insert into evt_stats_daily ( sample_date, cdb_instance_id, event_state, event_grade, event_duration, event_count )
 select t1.sample_date, t1.cdb_instance_id, t1.event_state, t1.event_grade, t1.event_duration, t1.event_count
  from temp_agg_event_slots t1
  where t1.sample_date not in (
   select t2.sample_date from evt_stats_daily t2
   where t2.cdb_instance_id = t1.cdb_instance_id and t2.event_state = t1.event_state and t2.event_grade = t1.event_grade
  );

-- Log exit
set rc = row_count();
call cdb_logit( pn, concat( 'Exit -  ',rc,' new rows inserted' ) );

-- Tidy up, before exit
drop temporary table if exists temp_slots;
drop temporary table if exists temp_event_slots;
drop temporary table if exists temp_agg_event_slots;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `evt_update_stats_monthly` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `evt_update_stats_monthly`(
        p_year int,
        p_month int
        )
BEGIN

/*
Update monthly table from daily data
*/
-- Declare variables and cursors
declare pn varchar(50) default 'evt_update_stats_monthly';
declare rc_upd integer default 0;
declare rc_ins integer default 0;
declare sd datetime;
declare ed datetime;

-- Log entry
call cdb_logit( pn, concat( 'Enter - event stats update - monthly ( ', p_year, ', ', p_month, ' )' ) );

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);


-- Update existing data for given month
update evt_stats_monthly md join (
    select cdb_instance_id, event_state, event_grade, sum(event_duration) as m_duration, sum(event_count) as m_count
      from evt_stats_daily
     where sample_date >= sd and sample_date < ed
      group by cdb_instance_id, event_state, event_grade
    ) dts on md.cdb_instance_id = dts.cdb_instance_id and md.event_state = dts.event_state and md.event_grade = dts.event_grade
  set event_duration = m_duration, event_count = m_count
  where sample_year = p_year and sample_month = p_month
   -- Only update entries that have additional events
   and m_count > event_count;

set rc_upd = row_count();

-- Insert new data for given month
insert into evt_stats_monthly ( sample_year, sample_month, cdb_instance_id, event_state, event_grade, event_duration, event_count )
 select year(sample_date), month(sample_date), cdb_instance_id, event_state, event_grade, sum(event_duration), sum(event_count)
   from evt_stats_daily e1
  where sample_date >= sd and sample_date < ed and cdb_instance_id not in (
    select cdb_instance_id from evt_stats_monthly as e2
     where sample_year = p_year and sample_month = p_month
      and e2.event_state = e1.event_state and e2.event_grade = e1.event_grade
    )
  group by year(sample_date), month(sample_date), cdb_instance_id, event_state, event_grade;

set rc_ins = row_count();

-- report results
if rc_upd > 0 then
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted, ', rc_upd, ' rows updated' ) );
 else
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted' ) );
 end if;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `get_avail_chart_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `get_avail_chart_data`(
        p_prefix varchar(10),
        p_machine varchar(250),
        p_instance varchar(250),
        p_start_date varchar(30),
        p_end_date varchar(30),
        p_slot_size varchar(20),
        p_hard_soft varchar(20)
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);
declare event_table varchar(50);
declare slot_size varchar(20);
declare hard_or_soft varchar(20);

-- ---------------------
--  Validate params
-- ---------------------

-- Check that an event table is defined for this prefix
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_app = 'nagevt'
 into rc;

if rc >= 1 then
  select distinct ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_app = 'nagevt'
   into event_table;
 else
  set msg = concat( 'Exit. *** Error - ', rc, ' datasources found ***' );
  call cdb_logit( 'event_info', msg );
--  select msg;
--  leave main;
  set event_table = 'template_nagios_events';
 end if;

-- Validate input dates
if p_end_date = '' then
  set ed = cast(now() as date);
 else
  set ed = cast(p_end_date as date);
 end if;

if p_start_date = '' then
  set sd = date_sub( ed, interval 30 day );
 else
  set sd = cast(p_start_date as date);
 end if;


if lcase(p_hard_soft) = 'hard' then
  set hard_or_soft = 'HARD';
 elseif lcase(p_hard_soft) = 'soft' then
  set hard_or_soft = 'SOFT';
 else
  set hard_or_soft = 'BOTH';
 end if;

set slot_size = lcase(p_slot_size);

-- ---------------------
--  Generate slot table
-- ---------------------

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
 slot_start date,
 slot_end date,
 slot_duration int
 );

-- Generate time slots
if slot_size = 'day' or slot_size = 'daily' then
    -- Populate table with daily dates
    set d1 = sd;
    while d1 < ed do
      set d2 = date_add( d1, interval 1 day );
      insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, timestampdiff( second, d1, d2 ) );
      set d1 = d2;
     end while;
 else
    -- Populate table with a single timeslot
   insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( sd, ed, timestampdiff( second, sd, ed ) );
 end if;

-- ------------------------
--  Select matching instances
-- ------------------------

drop temporary table if exists temp_selections;

create temporary table temp_selections
 select i_id, first_status_time, latest_status_time,
   concat( cdb_machine, if(cdb_instance='','',':'), cdb_instance ) as selection
  from event_instances
    -- select based upon customer, machine and instance
   where cdb_prefix = p_prefix and cdb_machine like p_machine and cdb_instance like p_instance
    -- also exclude any instance whose first appearance is after this period
    -- or whose last status update was before the period started
    and first_status_time < ed and latest_status_time > sd;

-- select * from temp_selections;

-- ----------------------------
--  Select matching event data
-- ----------------------------

drop temporary table if exists temp_events;

set @sql = concat( 'create temporary table temp_events ' );
set @sql = concat( @sql, 'select i_id, start_time, end_time, first_status_time, latest_status_time, ' );
set @sql = concat( @sql, '  selection, concat( ev_state, '' - '', hard_soft ) as series ' );
set @sql = concat( @sql, ' from ', event_table, ' e join temp_selections s on e.cdb_instance_id = s.i_id ' );
set @sql = concat( @sql, '  where e.start_time < ''', ed, ''' and ( e.end_time > ''', sd, ''' or e.end_time is null ) ' );

if hard_or_soft = 'HARD' or hard_or_soft = 'SOFT' then
  set @sql = concat( @sql, '  and hard_soft = ''', hard_or_soft, ''' ' );
 end if;

prepare evtsel from @sql;
execute evtsel;

-- select * from temp_events;

-- ------------------------
--  Calculate outage slots
-- ------------------------

drop temporary table if exists temp_outage_slots;

-- Calculate outages due to events
create temporary table temp_outage_slots
select slot_start, slot_duration, selection, series,
 count(*) as event_count,
 sum(
   TIMESTAMPDIFF(
     SECOND,
     CASE
       when start_time <= slot_start then slot_start
       else start_time END,
     CASE
       when end_time is null then least(slot_end,latest_status_time)
       when end_time >= slot_end then slot_end
       else end_time END
     )
   ) event_duration
 from temp_events e join temp_slots s
  on start_time < slot_end and (
       end_time > slot_start or  ( end_time is null and latest_status_time > slot_start )
       )
 group by slot_start, slot_duration, selection, series;

-- Calculate outage attributable to absence of monitoring data
insert into temp_outage_slots
select slot_start, slot_duration, selection, 'NO DATA' as series,
   1 as event_count,
   TIMESTAMPDIFF(
     SECOND,
     slot_start,
     CASE
       when first_status_time >= slot_end then slot_end
       when first_status_time <= slot_start then slot_start
       else first_status_time END
     ) +
   TIMESTAMPDIFF(
     SECOND,
     CASE
       when latest_status_time <= slot_start then slot_start
       when latest_status_time >= slot_end then slot_end
       else latest_status_time END,
     slot_end
     ) as event_duration
--
 from temp_slots slot join temp_selections sel
  on first_status_time > slot_start or latest_status_time < slot_end;

/*
select * from temp_outage_slots
 order by selection, slot_start, series;

select slot_start, selection, sum(event_duration) as down_time
     from temp_outage_slots group by slot_start, selection;
*/
-- ------------------------
--  Calculate uptime slots
-- ------------------------

drop temporary table if exists temp_uptime_slots;

create temporary table temp_uptime_slots
select e.selection,
   case
     when instr(e.selection,':') then 'OK'
     else 'UP'
    end as series,
   s.slot_start as category,
   1 as event_count, s.slot_duration, s.slot_duration - ifnull(o.down_time,0) as event_duration
  from temp_slots s
   cross join temp_selections e
   left join (
    select slot_start, selection, sum(event_duration) as down_time
     from temp_outage_slots group by slot_start, selection
    ) o on s.slot_start = o.slot_start and e.selection = o.selection;

-- ------------------------
--  Combine up and out time
-- ------------------------
select selection, category, series, slot_duration, event_count, event_duration, round(100 * event_duration / slot_duration,2) as 'event_percent'
  from temp_uptime_slots where event_duration > 0
 union
  select selection, slot_start as category, series,
    slot_duration, event_count, event_duration, round(100 * event_duration / slot_duration,2) as 'event_percent'
   from temp_outage_slots
 order by selection, series, category;

END; -- end of 'main' block

-- Tidy up, before exit
drop temporary table if exists temp_uptime_slots;
drop temporary table if exists temp_outage_slots;
drop temporary table if exists temp_events;
drop temporary table if exists temp_selections;
drop temporary table if exists temp_slots;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `get_event_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `get_event_data`(
        p_prefix varchar(10),
        p_machine varchar(250),
        p_instance varchar(250),
        p_start_date varchar(30),
        p_end_date varchar(30),
        p_hard_soft varchar(20),
        p_summary varchar(20)
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);
declare event_table varchar(50);
declare hard_or_soft varchar(20);

-- ---------------------
--  Validate params
-- ---------------------

-- Check that an event table is defined for this prefix
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_app = 'nagevt'
 into rc;

if rc >= 1 then
  select distinct ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_app = 'nagevt'
   into event_table;
 else
  set msg = concat( 'Exit. *** Error - ', rc, ' datasources found ***' );
  call cdb_logit( 'event_info', msg );
--  select msg;
--  leave main;
  set event_table = 'template_nagios_events';
 end if;

-- Validate input dates
if p_end_date = '' then
  set ed = cast(now() as date);
 else
  set ed = cast(p_end_date as date);
 end if;

if p_start_date = '' then
  set sd = date_sub( ed, interval 30 day );
 else
  set sd = cast(p_start_date as date);
 end if;


if lcase(p_hard_soft) = 'hard' then
  set hard_or_soft = 'HARD';
 elseif lcase(p_hard_soft) = 'soft' then
  set hard_or_soft = 'SOFT';
 else
  set hard_or_soft = 'BOTH';
 end if;

-- ----------------------------
--  Select matching event data
-- ----------------------------

drop temporary table if exists temp_events;

set @sql = concat( 'create temporary table temp_events ' );
set @sql = concat( @sql, 'select cdb_prefix, cdb_machine, cdb_instance, start_time, end_time, duration, ' );
set @sql = concat( @sql, '  ev_state, hard_soft, message ' );
set @sql = concat( @sql, ' from ', event_table, ' e join event_instances i on e.cdb_instance_id = i.i_id ' );

-- select based upon customer, machine and instance
set @sql = concat( @sql, '  where cdb_prefix = ''', p_prefix, ''' and cdb_machine like ''', p_machine, ''' and cdb_instance like ''', p_instance, ''' ' );

-- select events that fall within the specified range
set @sql = concat( @sql, '   and e.start_time < ''', ed, ''' and ( e.end_time > ''', sd, ''' or e.end_time is null ) ' );

-- Select hard or soft or both
if hard_or_soft = 'HARD' or hard_or_soft = 'SOFT' then
  set @sql = concat( @sql, '  and hard_soft = ''', hard_or_soft, ''' ' );
 end if;

prepare evtsel from @sql;
execute evtsel;

-- ----------------------------
--  Present event data
-- ----------------------------

if p_summary = '' then
  select * from temp_events;
 else
  select cdb_prefix, cdb_machine, cdb_instance, ev_state, hard_soft,
    count(*) as event_count, sum(duration) as total_duration, min(start_time) as earliest_start, max(end_time) as latest_end
   from temp_events
   group by cdb_prefix, cdb_machine, cdb_instance, ev_state, hard_soft
   order by cdb_prefix, cdb_machine, cdb_instance, ev_state, hard_soft;
 end if;

END; -- end of 'main' block

-- Tidy up, before exit
drop temporary table if exists temp_events;
drop temporary table if exists temp_selections;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `get_perf_chart_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `get_perf_chart_data`(
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
declare fmt varchar(30);

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
  series varchar(250) not null,
  counter_subtype varchar(50)
  );

if p_seltype = 'Machine' then
  -- Machine selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.cdb_dataset_id, dd.cdb_prefix,
   if (isnull(dd.parent_name), dd.cdb_counter, concat( dd.cdb_counter, ' (', dd.parent_name, ')' ) ) as selection,
   dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_machine = p_selection;

 elseif p_seltype = 'MachineInOut' then
  -- MachineInOut selected
  insert into TempDatasets ( dataset_id, prefix, selection, series, counter_subtype )
   select dd.cdb_dataset_id, dd.cdb_prefix,
   if (isnull(dd.parent_name), dd.counter_type, concat( dd.counter_type, ' (', dd.parent_name, ')' ) ) as selection,
   concat(dd.cdb_instance,' (',dd.counter_subtype,')') as series, dd.counter_subtype
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_machine = p_selection;

 else
  -- Counter selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.cdb_dataset_id, dd.cdb_prefix, dd.cdb_machine as selection, dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_counter = p_selection;
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
  set fmt = '%H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select date_add(''1900-01-01'', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, ''' ' );
  set @sql = concat( @sql, ' group by sample_hour, cdb_dataset_id;' );
  prepare tmpd from @sql;
  execute tmpd;
 elseif p_period = 20 then
  set fmt = '%Y-%m-%d %H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, '''; ' );
  prepare tmpd from @sql;
  execute tmpd;
 else
  set fmt = '%Y-%m-%d';
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from dt30_daily_data dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= sd and sample_time < ed and cdb_shift_id = 1;
 end if;

-- select * from TempData;

-- *************** Data Processing portion ***************

create temporary table TempSeries (
  sample_time varchar(30) not null,
  data_type varchar(20) not null,
  data_val float not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

if p_seltype = 'MachineInOut' then
  insert into TempSeries ( sample_time, data_type, data_val, selection, series )
   select date_format(sample_time,fmt), 'Avg', IF(counter_subtype = 'Out', ( data_sum / data_count ) * -1 , data_sum / data_count ),
    selection, series from TempData dt
   inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;
 else
  insert into TempSeries ( sample_time, data_type, data_val, selection, series )
   select date_format(sample_time,fmt), 'Avg', data_sum / data_count, selection, series from TempData dt
   inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;
 end if;

drop table TempDatasets;
drop table TempData;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

END main;

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
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.cdb_customer_id from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
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
insert into cdb_machines ( cdb_customer_id, machine_name )
 select custid, t.host
  from ( select distinct host from tempin ) t
 where t.host not in ( select machine_name from cdb_machines m where m.cdb_customer_id = custid );

set mrc = row_count();

-- Report machine creation, if any were found
if mrc > 0 then
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  set msg = concat( mrc, ' new machines created, ' );
 end if;

-- Populate tempin with machine IDs
update tempin t join cdb_machines m
 on m.machine_name = t.host and m.cdb_customer_id = custid
 set t.m_id = m.id;

-- ---------------------------------------
-- Populate tempin with object IDs
-- ---------------------------------------
update tempin t join cdb_objects o
 on o.object_name = IF(service= _utf8 '', _utf8 'NagiosHostEvent', _utf8 'NagiosServiceEvent')
 set t.o_id = o.id;

-- ---------------------------------------
 -- Create entries for all new Instances
-- ---------------------------------------
insert into cdb_instances ( cdb_machine_id, cdb_object_id, instance_name, first_status_time, latest_status_time )
 select t.m_id, t.o_id, t.service, t.first_status_time, t.latest_status_time
 from tempin t where t.service not in (
  select instance_name from cdb_instances where cdb_machine_id = t.m_id and cdb_object_id = t.o_id
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
update tempin t join cdb_instances i
  on t.m_id = i.cdb_machine_id and t.o_id = i.cdb_object_id and t.service = i.instance_name
 set t.i_id = i.id;

-- Update tempev with Instance IDs
update tempev e join tempin i on e.svc_id = i.svc_id
 set e.i_id = i.i_id;

-- Update instance table with latest times
update cdb_instances i join tempin t on t.i_id = i.id
 set i.latest_status_time = t.latest_status_time;

if msg <> '' then
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
 end if;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `nag_import_events` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
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
declare eventtab varchar(50) default 'template_nagios_events';
declare msg varchar(250) default '';

-- log entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- ---------------------------
-- Validate datasource
-- ---------------------------

-- Check that a unique datasource exists
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
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
set @sql = concat( @sql, '   hard_soft, next_state, entry_type, message  from tempev where duration > 0' );

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
/*!50003 DROP PROCEDURE IF EXISTS `prf_update_monthly_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `prf_update_monthly_data`(
        p_year int,
        p_month int
        )
BEGIN

/*
Update monthly table from daily data
*/
-- Declare variables and cursors
declare pn varchar(50) default 'prf_update_monthly_data';
declare rc_upd integer default 0;
declare rc_ins integer default 0;
declare sd datetime;
declare ed datetime;

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);

-- Log entry
call cdb_logit( pn, concat( 'Enter - data update - monthly ( ', p_year, ', ', p_month, ' )' ) );

-- Update existing data for given month
update prf_monthly_data md join (
-- explain select * from prf_monthly_data md join (
   select cdb_dataset_id, cdb_shift_id, min(data_min) as d_min,
           max(data_max) as d_max, sum(data_sum) as d_sum, sum(data_count) as d_count
    from dt30_daily_data
    where sample_time >= sd and sample_time < ed
    group by cdb_dataset_id, cdb_shift_id
   ) dts on md.cdb_dataset_id = dts.cdb_dataset_id and md.cdb_shift_id = dts.cdb_shift_id
  set data_min = d_min, data_max = d_max,
      data_sum = d_sum, data_count = d_count
  where sample_year = p_year and sample_month = p_month
   -- Only update entries that have additional datasets
   and d_count > data_count;

set rc_upd = row_count();

-- Insert new data for given month
insert into prf_monthly_data ( sample_year, sample_month, cdb_dataset_id, cdb_shift_id, data_min, data_max, data_sum, data_count )
 select sample_year, sample_month, cdb_dataset_id, cdb_shift_id,
    min(data_min), max(data_max), sum(data_sum), sum(data_count)
  from dt30_daily_data dt
  where sample_time >= sd and sample_time < ed and cdb_dataset_id not in (
    select cdb_dataset_id from prf_monthly_data as md
     where sample_year = p_year and sample_month = p_month and md.cdb_shift_id = dt.cdb_shift_id
    )
  group by sample_year, sample_month, cdb_dataset_id, cdb_shift_id;

set rc_ins = row_count();

-- update latest dates in cdb_datasets
if rc_ins > 0 then
  update cdb_datasets ds join (
    select cdb_dataset_id, max(str_to_date(concat(sample_year,'/',sample_month,'/01'),'%Y/%m/%d')) as latest
     from ( select distinct sample_year, sample_month, cdb_dataset_id from prf_monthly_data ) md
     group by cdb_dataset_id
    ) as t on ds.id = t.cdb_dataset_id
  set ds.dt50_latest=t.latest;
 end if;

-- report results
if rc_upd > 0 then
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted, ', rc_upd, ' rows updated' ) );
 else
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted' ) );
 end if;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `rpt_avail_monthly` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `rpt_avail_monthly`(
        p_prefix   varchar(10),
        p_year     int,
        p_month    int,
        p_seltype  varchar(20),
        p_selval   float,
        p_srctype  varchar(20),
        p_grade    varchar(20),
        p_slots    varchar(10)
        )
BEGIN
--        p_machine  varchar(250),
--        p_instance varchar(250),
-- call rpt_avail_monthly('VLTX0N',2010,10,'topn',5,'','','');

-- ------------------------
-- Initialise variables
-- ------------------------

declare sd datetime;
declare ed datetime;
declare slot_dur float;
declare topmsg varchar(100);
declare oid int;
declare grade_sql varchar(50);

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);
set slot_dur = timestampdiff( second, sd, ed );

-- ------------------------
-- Validate params
-- ------------------------

-- p_seltype = [ over*, topn ]
-- p_grade =   [ hard*, soft ]
-- p_srctype = [ host*, service ]
-- p_slots =   [ month*, day ]

-- Parameter translation
if lcase(left(p_grade,1)) = 'h' then
  set grade_sql = 'HARD';
 else
  set grade_sql = '%';
 end if;

-- Select Host or Service oid
if lcase(left(p_srctype,1)) = 's' then
  -- Select services oid
  set oid = 3;
 else
  -- Select hosts oid
  set oid = 2;
 end if;

-- Create group message
if lcase(left(p_seltype,1)) = 't' then
  -- Avail in TopN (worst)
  if oid = 3 then
    -- Service message
    set topmsg = concat('Top ', p_selval, ' least available services');
   else
    -- Host message
    set topmsg = concat('Top ', p_selval, ' least available hosts');
   end if;
 else
  -- Avail Under X%
  if oid = 3 then
    -- Service message
    set topmsg = concat('Services < ', p_selval, '% avail');
   else
    -- Host message
    set topmsg = concat('Hosts < ', p_selval, '% avail');
   end if;
 end if;

-- ------------------------
--  Select matching instances
-- ------------------------

drop temporary table if exists temp_event_topn;
create temporary table temp_event_topn (
        toptype varchar(50),
        topval int,
        i_id integer,
        event_count int,
        event_duration int,
        avail_percent decimal(7,4)
        );

if lcase(left(p_seltype,1)) = 't' then
    -- Select instances in Top N least available
    -- (use @rn to create an incrementing index, and allow cutoff at Top N)
    insert into temp_event_topn ( toptype, topval, i_id, event_count, event_duration, avail_percent )

     select topmsg, rn, i_id, event_count, event_duration, avail_percent from (
      select ig.*, @rn := case when @prev_domain = topmsg then @rn + 1 else 1 end as rn, @prev_domain := topmsg as pm from (

         select topmsg, cdb_instance_id as i_id, sum(event_count) as event_count,
           sum(event_duration) as event_duration, 100 - ( 100 * sum(event_duration) / slot_dur ) as avail_percent
          from evt_stats_monthly e join event_instances i on e.cdb_instance_id = i.i_id
           where cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
            and service_type = 'AVAIL' and o_id = oid and event_grade like grade_sql
           group by i_id order by sum(event_duration) desc

      ) ig, (select @prev_domain := NULL, @rn := 0 ) v
     ) og where rn < p_selval + 1;
 else
    -- Select instances under X% available
    -- (use @rn to create an incrementing index)
    insert into temp_event_topn ( toptype, topval, i_id, event_count, event_duration, avail_percent )

      select topmsg, @rn :=  @rn + 1 as rn, i_id, event_count, event_duration, avail_percent from (

      select topmsg, cdb_instance_id as i_id, sum(event_count) as event_count,
       sum(event_duration) as event_duration, 100 - ( 100 * sum(event_duration) / slot_dur ) as avail_percent
      from evt_stats_monthly e join event_instances i on e.cdb_instance_id = i.i_id
       where cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
        and service_type = 'AVAIL' and o_id = oid and event_grade like grade_sql
       group by i_id having avail_percent < p_selval order by sum(event_duration) desc

      ) ig, (select @rn := 0 ) v;

 end if;

-- select * from temp_event_topn;


-- Add index to speed up final join (below)
-- alter table temp_event_topn add index IDX_i_id(i_id);

-- ------------------------
--  Create event slots
-- ------------------------

-- Populate input table
drop temporary table if exists temp_instance_ids;
create temporary table temp_instance_ids
 select distinct i_id from temp_event_topn;

-- Create output table
drop temporary table if exists temp_event_slots;
create temporary table temp_event_slots (
        i_id int,
        slot_start date,
        slot_end date,
        event_sort int,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_duration int,
        event_percent decimal(7,4)
        );

-- Call routine to populate output table
call _event_slots( sd, ed, p_slots, p_grade);

-- Discard temp table
drop temporary table if exists temp_instance_ids;

-- select * from temp_event_slots;

-- ------------------------
--  Report data
-- ------------------------

-- Produce output
-- Host, Service, SortPos, SortVal, SlotStart, EventState, EventGrade, EventCount, EventDuration, PercentDuration

-- Add index to speed up final join (below)
alter table temp_event_slots add index IDX_i_id(i_id);

if lcase(left(p_slots,1)) = 's' then
  -- Selected instances in summary
  select toptype, topval, t.event_count as total_count, t.event_duration as total_duration, avail_percent, cdb_machine, cdb_instance
   from temp_event_topn t
    join event_instances i on i.i_id = t.i_id
   order by toptype, topval;
 else
  -- Selected instances with slot breakdown
  select toptype, topval, t.event_count as total_count, t.event_duration as total_duration, avail_percent, cdb_machine, cdb_instance,
          slot_start, s.event_state, s.event_grade, s.event_duration, s.event_percent
   from temp_event_slots s
    join temp_event_topn t on s.i_id = t.i_id
    join event_instances i on i.i_id = t.i_id
   order by toptype, topval, t.i_id, slot_start, event_sort;
 end if;

-- ------------------------
--  Tidy & exit
-- ------------------------

drop temporary table if exists temp_event_slots;
drop temporary table if exists temp_event_topn;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `rpt_perf_monthly` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `rpt_perf_monthly`(
        p_prefix   varchar(10),
        p_year     int,
        p_month    int,
        p_seltype  varchar(20),
        p_selval   float,
        p_format   varchar(10)
        )
BEGIN
--        p_machine  varchar(250),
--        p_instance varchar(250),
-- call rpt_perf_monthly('VLTX0N',2010,10,'topn',5,'s');

-- ------------------------
-- Initialise variables
-- ------------------------

declare sd datetime;
declare ed datetime;
declare slot_dur float;
declare topmsg varchar(100);
declare oid int;
declare grade_sql varchar(50);

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);
set slot_dur = timestampdiff( second, sd, ed );

-- ------------------------
-- Validate params
-- ------------------------

-- p_seltype = [ over*, topn ]
-- p_format =   [ month*, day, hour ]

-- Create group message
if lcase(left(p_seltype,1)) = 't' then
  -- TopN avg
  set topmsg = concat('Top ', p_selval, ' interfaces');
 else
  -- Util over X%
  set topmsg = concat('Interface utilisation over ', p_selval, '%');
 end if;

-- ------------------------
--  Select matching instances
-- ------------------------

drop temporary table if exists temp_interfaces;
create temporary table temp_interfaces (
        topmsg varchar(100),
        topnum int,
        i_id int,
        cdb_machine varchar(100),
        cdb_instance varchar(100),
        avg_In float,
        avg_Out float,
        avg_Both float
        );

if lcase(left(p_seltype,1)) = 't' then
  -- TopN avg

  insert into temp_interfaces ( topmsg, topnum, i_id, cdb_machine, cdb_instance, avg_In, avg_Out, avg_Both )
  select topmsg, rn as topnum, i_id, cdb_machine, cdb_instance, avg_In, avg_Out, avg_Both from (
    select @rn := @rn + 1 as rn, ig.* from (
      select i_id, cdb_machine, cdb_instance,
      sum( case counter_subtype when 'In' then data_sum else 0 end) / sum(case counter_subtype when 'In' then data_count else 0 end) as avg_In,
      sum( case counter_subtype when 'Out' then data_sum else 0 end) / sum(case counter_subtype when 'Out' then data_count else 0 end) as avg_Out,
      avg(data_sum/data_count) as avg_Both
        from prf_monthly_data dt join interface_util_details iud on iud.cdb_dataset_id = dt.cdb_dataset_id
        where cdb_shift_id = 1 -- and cdb_machine like '%P1'
         and cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
       group by cdb_machine, cdb_instance order by avg_Both desc
      ) ig, (select @rn := 0 ) v
   ) og where rn <= p_selval;

 else
  -- Util over X%

  insert into temp_interfaces ( topmsg, topnum, i_id, cdb_machine, cdb_instance, avg_In, avg_Out, avg_Both )
  select topmsg, @rn := @rn + 1 as topnum, i_id, cdb_machine, cdb_instance, avg_In, avg_Out, avg_Both from (
   select i_id, cdb_machine, cdb_instance,
    sum( case counter_subtype when 'In' then data_sum else 0 end) / sum(case counter_subtype when 'In' then data_count else 0 end) as avg_In,
    sum( case counter_subtype when 'Out' then data_sum else 0 end) / sum(case counter_subtype when 'Out' then data_count else 0 end) as avg_Out,
    avg(data_sum/data_count) as avg_Both
      from prf_monthly_data dt join interface_util_details iud on iud.cdb_dataset_id = dt.cdb_dataset_id
      where cdb_shift_id = 1 -- and cdb_machine like '%P1'
       and cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
     group by cdb_machine, cdb_instance having avg_Both > p_selval order by avg_Both desc
    ) ig, (select @rn := 0 ) v;

 end if;

-- select * from temp_interfaces;

-- ------------------------
--  Select matching datasets
-- ------------------------

-- Get if%Util datasets for selected interfaces
drop temporary table if exists temp_datasets;
 create temporary table temp_datasets
  select ds.id as ds_id, i_id, topmsg, topnum, cdb_machine, cdb_instance, counter_name as cdb_counter
   from cdb_datasets ds
    join cdb_counters ct on ct.id = ds.cdb_counter_id
    join temp_interfaces ti on ti.i_id = ds.cdb_instance_id
   where counter_type = 'if%Util';

alter table temp_datasets add primary key (ds_id);

-- select * from temp_datasets;

-- ------------------------
--  Return selected format
-- ------------------------

if lcase(left(p_format,1)) = 'h' then
    -- Return Hourly data
    select topnum, cdb_machine, cdb_instance, cdb_counter, sample_time, (data_sum / data_count) as data_val
      from hourly_data_merge dt join temp_datasets ds on ds.ds_id = dt.cdb_dataset_id
     where dt.sample_time >= sd and dt.sample_time < ed
      order by topnum, sample_time, cdb_counter;
  elseif lcase(left(p_format,1)) = 'd' then
    -- Return Daily data
    select topnum, cdb_machine, cdb_instance, cdb_counter, sample_time, (data_sum / data_count) as data_val
      from dt30_daily_data dt join temp_datasets ds on ds.ds_id = dt.cdb_dataset_id
     where dt.sample_time >= sd and dt.sample_time < ed and cdb_shift_id = 1
      order by topnum, sample_time, cdb_counter;
  else
    -- Return Summary (Monthly) data
    select * from temp_interfaces order by topnum;
  end if;

-- ------------------------
--  Tidy & exit
-- ------------------------

drop temporary table if exists temp_datasets;
drop temporary table if exists temp_interfaces;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `web_get_chart_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
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
declare pn varchar(50) default 'debug web_get_chart_data';
declare msg varchar(250) default '';

declare ts0 datetime;
declare ts1 datetime;
declare ts2 datetime;

declare sd datetime;
declare ed datetime;
declare fmt varchar(30);

set ts0 = sysdate();
call cdb_logit( pn, concat('Enter ( ',p_prefix,', ',p_seltype,', ',p_selection,', ',p_startdate,', ',p_enddate,', ',p_period,' )' ) );
set ts1 = ts0;

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
   select dd.cdb_dataset_id, dd.cdb_prefix, dd.cdb_counter as selection, dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_machine = p_selection;
 else
  -- Counter selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.cdb_dataset_id, dd.cdb_prefix, dd.cdb_machine as selection, dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_counter = p_selection;
 end if;

-- select * from TempDatasets;
-- drop table TempDatasets;

set ts2 = sysdate();
set msg = concat( msg, 'datasets:', timestampdiff(second,ts1,ts2), 's ' );
set ts1 = ts2;

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
  set fmt = '%H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select date_add(''1900-01-01'', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, ''' ' );
  set @sql = concat( @sql, ' group by sample_hour, cdb_dataset_id;' );
  prepare tmpd from @sql;
  execute tmpd;
 elseif p_period = 20 then
  set fmt = '%Y-%m-%d %H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, '''; ' );
  prepare tmpd from @sql;
  execute tmpd;
 else
  set fmt = '%Y-%m-%d';
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from dt30_daily_data dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= sd and sample_time < ed and cdb_shift_id = 1;
 end if;

ALTER TABLE TempData ADD INDEX Idx_dsid(dataset_id);

set ts2 = sysdate();
set msg = concat( msg, 'data:', timestampdiff(second,ts1,ts2), 's ' );
set ts1 = ts2;

-- select * from TempData limit 10;

-- *************** Data Processing portion ***************

create temporary table TempSeries (
  sample_time varchar(30) not null,
  data_type varchar(20) not null,
  data_val float not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select date_format(sample_time,fmt), 'Min', data_min, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select date_format(sample_time,fmt), 'Max', data_max, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select date_format(sample_time,fmt), 'Avg', data_sum / data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select date_format(sample_time,fmt), 'Cnt', data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

drop table TempDatasets;
drop table TempData;

set ts2 = sysdate();
set msg = concat( msg, 'results:', timestampdiff(second,ts1,ts2), 's ' );
set ts1 = ts2;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

set ts2 = sysdate();
set msg = concat( 'Exit. Total:', timestampdiff(second,ts0,ts2), 's [ ', msg, ' ]' );
call cdb_logit( pn, msg );
set ts1 = ts2;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `_event_slots` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `_event_slots`(
        p_start_date varchar(20),
        p_end_date   varchar(20),
        p_slot_size  varchar(20),
        p_grade      varchar(20)
        )
BEGIN

/*
----------------------------------------------------
This routine expects the calling routine to have
created temp tables with the following names and
layouts. This routine reads the input table and
populates the output table.
----------------------------------------------------
Input Table:
  create temporary table temp_instance_ids (
        i_id integer
        );
----------------------------------------------------
Output Table:
  create temporary table temp_event_slots (
        i_id int,
        slot_start date,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_duration int,
        event_percent decimal
        );
----------------------------------------------------
*/

declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare slot_len int;
declare v_grade varchar(20);
declare daily_slots boolean;

-- ------------------------
--  Param validation
-- ------------------------

-- Validate input dates
if p_end_date = '' then
  set ed = cast(now() as date);
 else
  set ed = cast(p_end_date as date);
 end if;

if p_start_date = '' then
  set sd = date_sub( ed, interval 30 day );
 else
  set sd = cast(p_start_date as date);
 end if;

-- Set size of slot to use
if lcase(left(p_slot_size,1)) = 'd' then
    -- Use slots of one day each
    set slot_len = 86400;
    set daily_slots = true;
 else
    -- Use one single slot
    set slot_len = timestampdiff( second, sd, ed );
    set daily_slots = false;
 end if;

-- Validate grade of event
if lcase(left(p_grade,1)) = 'h' then
    set v_grade = 'HARD';
  else
    set v_grade = '%';
  end if;

-- ------------------------
--  Create base slots
-- ------------------------

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
        slot_start date,
        slot_end date,
        slot_duration int
        );

-- Generate time slots
if daily_slots then
    -- Populate table with daily dates
    set d1 = sd;
    while d1 < ed do
      set d2 = date_add( d1, interval 1 day );
      insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, slot_len );
      set d1 = d2;
     end while;
 else
    -- Populate table with a single timeslot
    insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( sd, ed, slot_len );
 end if;

-- ------------------------
--  Create instance slots
-- ------------------------

-- Generate slots for instances (with dead times)
drop temporary table if exists temp_instance_slots;
create temporary table temp_instance_slots
 select i_id, slot_start, slot_end, slot_duration, state_id, event_state, event_grade,
  case when o_id = 2 then 'UP' else 'OK' end as up_state,
  case when event_state = 'NODATA' then
   case
    when first_status_time <= slot_start then 0
    when first_status_time < slot_end then timestampdiff( second, slot_start, first_status_time )
    else slot_duration
   end
   +
  case
    when latest_status_time >= slot_end then 0
    when latest_status_time > slot_start then timestampdiff( second, latest_status_time, slot_end )
    else slot_duration
   end
    else 0
   end as event_duration
 from temp_slots s
  cross join (
    select i.i_id, first_status_time, latest_status_time, e.o_id, e.id as state_id, event_state, event_grade
    from event_instances i
     join temp_instance_ids t on i.i_id = t.i_id
     join cdb_event_states e on e.o_id = i.o_id
    ) i2;

-- Discard temp table
drop temporary table if exists temp_slots;

-- select * from temp_instance_slots;

-- ------------------------
--  Create outage slots
-- ------------------------

-- Add outage from daily event stats
drop temporary table if exists temp_outage_slots;
create temporary table temp_outage_slots (
        slot_start date,
        i_id int,
        item_duration int,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL
        );

if daily_slots then
    update temp_instance_slots i
      join evt_stats_daily e on e.cdb_instance_id = i.i_id and e.sample_date = i.slot_start
        and e.event_state = i.event_state and e.event_grade = i.event_grade
     set i.event_duration = e.event_duration
      where i.event_state not in ( 'UP', 'OK', 'NODATA' ) and i.event_grade like v_grade;
  else
    update temp_instance_slots i
      join (
        select sd as slot_start, cdb_instance_id as i_id, sum(event_duration) as event_duration, event_state, event_grade
         from evt_stats_daily s where sample_date >= sd and sample_date < ed
         group by i_id, event_state, event_grade
        ) e on e.i_id = i.i_id and e.slot_start = i.slot_start
        and e.event_state = i.event_state and e.event_grade = i.event_grade
     set i.event_duration = e.event_duration
      where i.event_state not in ( 'UP', 'OK', 'NODATA' ) and i.event_grade like v_grade;
  end if;

-- ------------------------
--  Create uptime slots
-- ------------------------

-- Calculate uptime of slots with outages
drop temporary table if exists temp_uptime_slots;
create temporary table temp_uptime_slots
 select slot_start, i_id, slot_len - sum(event_duration) as event_duration, up_state as event_state, 'HARD' as event_grade
  from temp_instance_slots group by slot_start, i_id;

-- Update slot table with uptimes
update temp_instance_slots i
      join temp_uptime_slots u on u.i_id = i.i_id and u.slot_start = i.slot_start
        and u.event_state = i.event_state and u.event_grade = i.event_grade
     set i.event_duration = u.event_duration;

-- Return slot data with percentages
insert into temp_event_slots ( i_id, slot_start, slot_end, event_sort, event_state, event_grade, event_duration, event_percent )
 select i_id, slot_start, slot_end, state_id, event_state, event_grade, event_duration,
   ( 100.00 * event_duration / slot_duration ) as event_percent
  from temp_instance_slots;

-- ------------------------
--  Tidy & exit
-- ------------------------

drop temporary table if exists temp_instance_slots;
drop temporary table if exists temp_uptime_slots;

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
/*!50001 VIEW `dataset_details` AS select `m5`.`id` AS `cdb_dataset_id`,`m0`.`prefix` AS `cdb_prefix`,`m1`.`machine_name` AS `cdb_machine`,`m2`.`object_name` AS `cdb_object`,`m3`.`instance_name` AS `cdb_instance`,`m3`.`parent_name` AS `parent_name`,`m3`.`description` AS `inst_desc`,`m4`.`counter_name` AS `cdb_counter`,`m4`.`counter_type` AS `counter_type`,`m4`.`counter_subtype` AS `counter_subtype` from (((((`cdb_datasets` `m5` join `cdb_counters` `m4` on((`m4`.`id` = `m5`.`cdb_counter_id`))) join `cdb_instances` `m3` on((`m3`.`id` = `m5`.`cdb_instance_id`))) join `cdb_objects` `m2` on((`m2`.`id` = `m3`.`cdb_object_id`))) join `cdb_machines` `m1` on((`m1`.`id` = `m3`.`cdb_machine_id`))) join `cdb_customers` `m0` on((`m0`.`id` = `m1`.`cdb_customer_id`))) */;

--
-- Final view structure for view `event_instances`
--

/*!50001 DROP TABLE `event_instances`*/;
/*!50001 DROP VIEW IF EXISTS `event_instances`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `event_instances` AS select `c`.`id` AS `c_id`,`m`.`id` AS `m_id`,`o`.`id` AS `o_id`,`i`.`id` AS `i_id`,`c`.`prefix` AS `cdb_prefix`,`c`.`customer_name` AS `cdb_customer`,`m`.`machine_name` AS `cdb_machine`,`o`.`object_name` AS `cdb_object`,`i`.`instance_name` AS `cdb_instance`,`i`.`first_status_time` AS `first_status_time`,`i`.`latest_status_time` AS `latest_status_time`,`i`.`service_type` AS `service_type` from (((`cdb_customers` `c` join `cdb_machines` `m` on((`c`.`id` = `m`.`cdb_customer_id`))) join `cdb_instances` `i` on((`i`.`cdb_machine_id` = `m`.`id`))) join `cdb_objects` `o` on((`o`.`id` = `i`.`cdb_object_id`))) where (`o`.`type` = _utf8'event') */;

--
-- Final view structure for view `interface_details`
--

/*!50001 DROP TABLE `interface_details`*/;
/*!50001 DROP VIEW IF EXISTS `interface_details`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `interface_details` AS select `m5`.`id` AS `cdb_dataset_id`,`m0`.`prefix` AS `cdb_prefix`,`m1`.`machine_name` AS `cdb_machine`,`m2`.`object_name` AS `cdb_object`,`m3`.`id` AS `i_id`,`m3`.`instance_name` AS `cdb_instance`,`m3`.`parent_name` AS `parent_name`,`m3`.`description` AS `inst_desc`,`m4`.`counter_name` AS `cdb_counter`,`m4`.`counter_type` AS `counter_type`,`m4`.`counter_subtype` AS `counter_subtype` from (((((`cdb_datasets` `m5` join `cdb_counters` `m4` on((`m4`.`id` = `m5`.`cdb_counter_id`))) join `cdb_instances` `m3` on((`m3`.`id` = `m5`.`cdb_instance_id`))) join `cdb_objects` `m2` on((`m2`.`id` = `m3`.`cdb_object_id`))) join `cdb_machines` `m1` on((`m1`.`id` = `m3`.`cdb_machine_id`))) join `cdb_customers` `m0` on((`m0`.`id` = `m1`.`cdb_customer_id`))) where (`m2`.`object_name` = _utf8'Interface') */;

--
-- Final view structure for view `interface_util_details`
--

/*!50001 DROP TABLE `interface_util_details`*/;
/*!50001 DROP VIEW IF EXISTS `interface_util_details`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `interface_util_details` AS select `m5`.`id` AS `cdb_dataset_id`,`m0`.`prefix` AS `cdb_prefix`,`m1`.`machine_name` AS `cdb_machine`,`m2`.`object_name` AS `cdb_object`,`m3`.`id` AS `i_id`,`m3`.`instance_name` AS `cdb_instance`,`m3`.`parent_name` AS `parent_name`,`m3`.`description` AS `inst_desc`,`m4`.`counter_name` AS `cdb_counter`,`m4`.`counter_type` AS `counter_type`,`m4`.`counter_subtype` AS `counter_subtype` from (((((`cdb_datasets` `m5` join `cdb_counters` `m4` on((`m4`.`id` = `m5`.`cdb_counter_id`))) join `cdb_instances` `m3` on((`m3`.`id` = `m5`.`cdb_instance_id`))) join `cdb_objects` `m2` on((`m2`.`id` = `m3`.`cdb_object_id`))) join `cdb_machines` `m1` on((`m1`.`id` = `m3`.`cdb_machine_id`))) join `cdb_customers` `m0` on((`m0`.`id` = `m1`.`cdb_customer_id`))) where ((`m2`.`object_name` = _utf8'Interface') and (`m4`.`counter_type` = _utf8'if%Util')) */;
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
-- Host: localhost    Database: cdb_prod
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
INSERT INTO `cdb_customers` VALUES (57,'AAML0D','Arts Alliance Media Ltd',NULL,NULL),(58,'ASBR0D','Askham Bryan College',NULL,NULL),(59,'APET0P','Apetito Limited',NULL,NULL),(60,'BIFL0P','Bishop Fleming',NULL,NULL),(61,'BLNW0D','Business Link Northwest',NULL,NULL),(62,'BRSC0N','Bristol City Council',NULL,NULL),(63,'CLNH0D','Clarendon House',NULL,NULL),(64,'CLRH0D','Claire House',NULL,NULL),(65,'CHWE0D','Chelsea & Westminster NHS Trust',NULL,NULL),(66,'DIDA0D','DiData',NULL,NULL),(67,'EDTX0D','eDT',NULL,NULL),(68,'EMSI0D','ems-Internet',NULL,NULL),(69,'FALE0P','Fantasy League',NULL,NULL),(70,'HRDS0P','Harrods Limited',NULL,NULL),(71,'IKON0D','IKON',NULL,NULL),(72,'IMJA0D','IMERJA Limited',NULL,NULL),(73,'INVM0D','Invmo Limited',NULL,NULL),(74,'ITRM0D','IT Resource Management',NULL,NULL),(75,'KNOC0N','Knowsley Metropolitan Borough Council',NULL,NULL),(76,'KNHT0D','Knowsley Housing Trust',NULL,NULL),(77,'LBRC0N','London Borough of Redbridge',NULL,NULL),(78,'LORO0D','London Overground Rail Operations Ltd',NULL,NULL),(79,'GMFR0D','Manchester Fire and Rescue',NULL,NULL),(80,'MIPY0D','MiPay',NULL,NULL),(81,'MRCX0D','Medical Research Council',NULL,NULL),(82,'NELC0D','North East Lincolnshire Council',NULL,NULL),(83,'NOBI0D','Nobisco',NULL,NULL),(84,'NWLG0D','North West Learning Grid',NULL,NULL),(85,'OTWO0D','O2',NULL,NULL),(86,'PTOP0D','Point to Point',NULL,NULL),(87,'REDX0D','Retail Decisions',NULL,NULL),(88,'RNLI0N','RNLI LifeBoat',NULL,NULL),(89,'RWAL0D','Rockwood Additives Limited',NULL,NULL),(90,'SLFC0D','Salford MBC',NULL,NULL),(91,'SDSX0P','Specialist Data Solutions',NULL,NULL),(92,'SFTC0D','Sefton MBC',NULL,NULL),(93,'STHC0N','St.Helens MBC',NULL,NULL),(94,'SNTX0D','Synetrix',NULL,NULL),(95,'SOUN0D','Southampton University',NULL,NULL),(96,'SPEN0N','Sport England',NULL,NULL),(97,'STAH0D','St Andrews',NULL,NULL),(98,'SUPD0D','Supporter Direct',NULL,NULL),(99,'SHIS0D','Sussex HIS',NULL,NULL),(100,'TLPL0D','Talentplan / Clicks and Links',NULL,NULL),(101,'TRHT0D','Trafford Housing Trust',NULL,NULL),(102,'TOTE0D','Totesport',NULL,NULL),(103,'UNPA0D','Unity Partnership',NULL,NULL),(104,'VIME0D','Virgin Media',NULL,NULL),(105,'VLTX0N','Vaultex UK',NULL,NULL),(106,'WKFC0D','Wakefield Metopolitan District Council',NULL,NULL),(107,'WRTC0N','Warrington Borough Council',NULL,NULL),(108,'LAHC0N','Lancashire Health Community',NULL,NULL),(109,'SELF0D','Selfridges Ltd',NULL,NULL),(110,'STJP0P','St James Place',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdb_datasources`
--

LOCK TABLES `cdb_datasources` WRITE;
/*!40000 ALTER TABLE `cdb_datasources` DISABLE KEYS */;
INSERT INTO `cdb_datasources` VALUES (1,108,'lancsman','rtg','hourly_data_lahc0n',NULL,NULL),(2,108,'lancsman','rtg2','hourly_data_lahc0n',NULL,NULL),(3,93,'sthman3','rtg','hourly_data_sthc0n',NULL,NULL),(4,105,'vaultexman2','rtg','hourly_data_vltx0n',NULL,NULL),(5,65,'chelseaman2','rtg','hourly_data_chwe0d',NULL,NULL),(6,93,'sthman3','nagevt','nagios_events_sthc0n',NULL,NULL),(7,105,'vaultexman2','nagevt','nagios_events_vltx0n',NULL,NULL),(8,97,'staman2','nagevt','nagios_events_stah0d',NULL,NULL),(9,108,'lancsman2','nagevt','nagios_events_lahc0n',NULL,NULL),(10,93,'sthman','rtg','hourly_data_sthc0n',NULL,NULL),(11,65,'chelseaman2','nagevt','nagios_events_chwe0d',NULL,NULL),(12,109,'selfman-se3','nagevt','nagios_events_self0d',NULL,NULL),(13,105,'vaultexman-pe1','rtg','hourly_data_vltx0n',NULL,NULL),(14,105,'vaultexman-se1','nagevt','nagios_events_vltx0n',NULL,NULL),(15,105,'vaultexman-se2','nagevt','nagios_events_vltx0n',NULL,NULL),(16,105,'vaultexman-pe2','rtg','hourly_data_vltx0n',NULL,NULL);
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