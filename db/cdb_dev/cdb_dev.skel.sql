-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_dev
-- ------------------------------------------------------
-- Server version	5.0.77-community-nt

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
-- Table structure for table `cdb_log`
--

DROP TABLE IF EXISTS `cdb_log`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdb_log` (
  `id` int(11) NOT NULL auto_increment,
  `dt` datetime NOT NULL,
  `pn` varchar(80) default NULL,
  `txt` varchar(1024) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `dataset_details`
--

DROP TABLE IF EXISTS `dataset_details`;
/*!50001 DROP VIEW IF EXISTS `dataset_details`*/;
/*!50001 CREATE TABLE `dataset_details` (
  `dataset_id` int(10) unsigned,
  `prefix` varchar(20),
  `machine` varchar(50),
  `object` varchar(50),
  `instance` varchar(250),
  `counter` varchar(50)
) ENGINE=MyISAM */;

--
-- Table structure for table `dt20_hourly_data`
--

DROP TABLE IF EXISTS `dt20_hourly_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `dt30_daily_data`
--

DROP TABLE IF EXISTS `dt30_daily_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `hourly_data_lahc`
--

DROP TABLE IF EXISTS `hourly_data_lahc`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `hourly_data_sthc`
--

DROP TABLE IF EXISTS `hourly_data_sthc`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m00_customers`
--

DROP TABLE IF EXISTS `m00_customers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m00_customers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefix` varchar(20) default NULL,
  `fullname` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_prefix_unique` USING BTREE (`prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m01_machines`
--

DROP TABLE IF EXISTS `m01_machines`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m01_machines` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `machine_type` varchar(50) NOT NULL default 'unknown',
  `subtype` varchar(50) NOT NULL default 'unknown',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_machine_name_unique` USING BTREE (`cdb_customer_id`,`name`),
  CONSTRAINT `FK_machine_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `m00_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m02_objects`
--

DROP TABLE IF EXISTS `m02_objects`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m02_objects` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `type` varchar(50) default NULL,
  `subsystem` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_object_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m03_instances`
--

DROP TABLE IF EXISTS `m03_instances`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m03_instances` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_machine_id` int(10) unsigned NOT NULL,
  `cdb_object_id` int(10) unsigned NOT NULL,
  `name` varchar(250) default NULL,
  `parent_name` varchar(50) default NULL,
  `instance_index` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_instance_name_unique` USING BTREE (`cdb_machine_id`,`cdb_object_id`,`name`),
  KEY `FK_instance_object` USING BTREE (`cdb_object_id`),
  CONSTRAINT `FK_instance_machine` FOREIGN KEY (`cdb_machine_id`) REFERENCES `m01_machines` (`id`),
  CONSTRAINT `FK_instance_object` FOREIGN KEY (`cdb_object_id`) REFERENCES `m02_objects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=320 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m04_counters`
--

DROP TABLE IF EXISTS `m04_counters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m04_counters` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_object_id` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `is_percent` bit(1) NOT NULL default b'0',
  `in_extract` bit(1) NOT NULL default b'0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_counter_name_unique` USING BTREE (`cdb_object_id`,`name`),
  CONSTRAINT `FK_counter_object` FOREIGN KEY (`cdb_object_id`) REFERENCES `m02_objects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m05_datasets`
--

DROP TABLE IF EXISTS `m05_datasets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m05_datasets` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_instance_id` int(10) unsigned NOT NULL,
  `cdb_counter_id` int(10) unsigned NOT NULL,
  `created_on` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt10_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt20_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt30_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt40_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `dt50_latest` datetime NOT NULL default '2000-01-01 00:00:00',
  `cdb_prefix` varchar(20) default NULL,
  `cdb_path` varchar(256) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_dataset_unique` USING BTREE (`cdb_instance_id`,`cdb_counter_id`),
  UNIQUE KEY `IDX_dataset_path_unique` (`cdb_prefix`,`cdb_path`),
  KEY `FK_dataset_counter` USING BTREE (`cdb_counter_id`),
  CONSTRAINT `FK_dataset_counter` FOREIGN KEY (`cdb_counter_id`) REFERENCES `m04_counters` (`id`),
  CONSTRAINT `FK_dataset_instance` FOREIGN KEY (`cdb_instance_id`) REFERENCES `m03_instances` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1879 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m06_datasources`
--

DROP TABLE IF EXISTS `m06_datasources`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m06_datasources` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `source_server` varchar(45) NOT NULL,
  `source_app` varchar(45) NOT NULL,
  `hourly_table` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_datasource_customer` USING BTREE (`cdb_customer_id`),
  CONSTRAINT `FK_datasource_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `m00_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `m07_dataset_map`
--

DROP TABLE IF EXISTS `m07_dataset_map`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m07_dataset_map` (
  `cdb_datasource_id` int(10) unsigned NOT NULL,
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `cdb_dataset_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`cdb_datasource_id`,`cdc_dataset_id`),
  KEY `FK_map_dataset` USING BTREE (`cdb_dataset_id`),
  CONSTRAINT `FK_map_dataset` FOREIGN KEY (`cdb_dataset_id`) REFERENCES `m05_datasets` (`id`),
  CONSTRAINT `FK_map_datasource` FOREIGN KEY (`cdb_datasource_id`) REFERENCES `m06_datasources` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `template_ds`
--

DROP TABLE IF EXISTS `template_ds`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `template_ds` (
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `cdc_machine` varchar(45) NOT NULL,
  `cdc_object` varchar(45) NOT NULL,
  `cdc_instance` varchar(45) NOT NULL,
  `cdc_counter` varchar(45) NOT NULL,
  `speed` bigint(20) unsigned NOT NULL,
  `description` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `template_dt`
--

DROP TABLE IF EXISTS `template_dt`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `template_dt` (
  `sample_date` date NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `cdc_dataset_id` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'cdb_dev'
--
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_check_datasets` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
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

-- Check that a unique datasource exists
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

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
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
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

-- Finally drop the temporary table
drop temporary table tt10;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdb_import_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
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
  select ds.id, ds.hourly_table from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, hourtab;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new mapped data
set @sql = concat( 'insert into ', hourtab, ' ' );
set @sql = concat( @sql, ' select date_add(dt.sample_date, interval dt.sample_hour hour ), dm.cdb_dataset_id, ' );
set @sql = concat( @sql, '   dt.sample_date, dt.sample_hour, data_min, data_max, data_sum, data_count ' );
set @sql = concat( @sql, '  from tempdt dt join m07_dataset_map dm ' );
set @sql = concat( @sql, '   on dt.cdc_dataset_id = dm.cdc_dataset_id where dm.cdb_datasource_id = ', dsrcid, ' ' );
set @sql = concat( @sql, ' and not exists ( select * from ', hourtab, ' ht ' );
set @sql = concat( @sql, '  where ht.sample_time = date_add(dt.sample_date, interval dt.sample_hour hour ) and ht.cdb_dataset_id = dm.cdb_dataset_id )' );

prepare imp from @sql;
execute imp;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  call cdb_logit( pn, concat( 'Exit. No new data found' ) );
  leave main;
 end if;

-- update latest times in m05_datasets
set @sql = concat( 'update m05_datasets ds join ( ' );
set @sql = concat( @sql, '  select cdb_dataset_id, max(sample_time) as ''latest'' from ', hourtab, ' group by cdb_dataset_id ' );
set @sql = concat( @sql, '   ) as t on ds.id = t.cdb_dataset_id set ds.dt20_latest=t.latest; ' );

prepare upd from @sql;
execute upd;

-- Log valid entry
call cdb_logit( pn, concat( 'Exit. Inserted ', rc, ' data rows into ', hourtab ) );

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
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
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
/*!50003 DROP PROCEDURE IF EXISTS `lsr` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `lsr`()
BEGIN
  select * from cdb_log order by id desc limit 100;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `web_get_chart_data` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
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
declare continue handler for 1051 set done = 1;

drop table if exists TempDatasets;
drop table if exists TempData;
drop table if exists TempSeries;

-- *************** Param validation ***************

set @st = p_startdate;
set @et = p_enddate;
-- set @st = '2009-04-06';
-- set @et = '2009-04-07';

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

  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select date_add('1900-01-01', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)
   from hourly_data_sthc dt
    inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= @st and sample_time < @et
   group by sample_hour, cdb_dataset_id;
 else
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from hourly_data_sthc dt
    inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= @st and sample_time < @et;
 end if;

-- select * from TempData;

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

select count(*) from TempSeries into @rc;

-- Exit here if no data was found
if @rc <= 0 then
  drop table TempSeries;
  leave main;
 end if;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

END main;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `web_get_machine_counter` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `web_get_machine_counter`(p_prefix varchar(50), mc varchar(50))
BEGIN

if mc = 'Machine' then
  select distinct name from m01_machines m
   inner join m00_customers c on c.id = m.cdb_customer_id
   where prefix = p_prefix;
 else
  if mc = 'Counter' then
    select distinct counter from dataset_details
     where prefix = p_prefix;
   else
    select distinct machine, counter from dataset_details
     where prefix = p_prefix;
   end if;
 end if;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `web_get_prefix_type` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `web_get_prefix_type`(p1 varchar(50))
BEGIN

if p1 = 'Prefix' then
  -- Join on machine to only select customers with machines defined
  select distinct c.prefix, c.fullname from m00_customers c
   inner join m01_machines m on c.id = m.cdb_customer_id
   order by c.fullname;
 else
  select distinct c.prefix, m.machine_type from m00_customers c
   inner join m01_machines m on c.id = m.cdb_customer_id
   order by c.prefix;
 end if;


END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `xx` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `xx`()
BEGIN

truncate table dt30_daily_data;
truncate table dt20_hourly_data;

truncate table m07_dataset_map;
truncate table m06_datasources;
truncate table m05_datasets;
truncate table m04_counters;
truncate table m03_instances;
truncate table m02_objects;
truncate table m01_machines;

truncate table cdb_log;

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
/*!50001 VIEW `dataset_details` AS select `m5`.`id` AS `dataset_id`,`m0`.`prefix` AS `prefix`,`m1`.`name` AS `machine`,`m2`.`name` AS `object`,`m3`.`name` AS `instance`,`m4`.`name` AS `counter` from (((((`m05_datasets` `m5` join `m04_counters` `m4` on((`m4`.`id` = `m5`.`cdb_counter_id`))) join `m03_instances` `m3` on((`m3`.`id` = `m5`.`cdb_instance_id`))) join `m02_objects` `m2` on((`m2`.`id` = `m3`.`cdb_object_id`))) join `m01_machines` `m1` on((`m1`.`id` = `m3`.`cdb_machine_id`))) join `m00_customers` `m0` on((`m0`.`id` = `m1`.`cdb_customer_id`))) */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-08-22 10:57:51
-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_dev
-- ------------------------------------------------------
-- Server version	5.0.77-community-nt

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
-- Table structure for table `m00_customers`
--

DROP TABLE IF EXISTS `m00_customers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m00_customers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `prefix` varchar(20) default NULL,
  `fullname` varchar(50) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `IDX_prefix_unique` USING BTREE (`prefix`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `m00_customers`
--

LOCK TABLES `m00_customers` WRITE;
/*!40000 ALTER TABLE `m00_customers` DISABLE KEYS */;
INSERT INTO `m00_customers` VALUES (57,'AAML','Arts Alliance Media Ltd'),(58,'ABCO','Askham Bryan College'),(59,'APTO','Apetito Limited'),(60,'BIFL','Bishop Fleming'),(61,'BLNW','Business Link Northwest'),(62,'BRCC','Bristol City Council'),(63,'CLNH','Clarendon House'),(64,'CLRH','Claire House'),(65,'CWNT','Chelsea & Westminster NHS Trust'),(66,'DIDA','DiData'),(67,'EDET','eDT'),(68,'EMSI','ems-Internet'),(69,'FANL','Fantasy League'),(70,'HRDS','Harrods Limited'),(71,'IKON','IKON'),(72,'IMJA','IMERJA Limited'),(73,'INVM','Invmo Limited'),(74,'ITRM','IT Resource Management'),(75,'KWBC','Knowsley Metropolitan Borough Council'),(76,'KWHT','Knowsley Housing Trust'),(77,'LBRE','London Borough of Redbridge'),(78,'LORO','London Overground Rail Operations Ltd'),(79,'MAFR','Manchester Fire and Rescue'),(80,'MPAY','MiPay'),(81,'MRCO','Medical Research Council'),(82,'NELC','North East Lincolnshire Council'),(83,'NOBI','Nobisco'),(84,'NWLG','North West Learning Grid'),(85,'OTWO','O2'),(86,'PTOP','Point to Point'),(87,'REDE','Retail Decisions'),(88,'RNLI','RNLI LifeBoat'),(89,'RWAL','Rockwood Additives Limited'),(90,'SABC','Salford MBC'),(91,'SDSO','Specialist Data Solutions'),(92,'SEBC','Sefton MBC'),(93,'STHC','St.Helens MBC'),(94,'SNTX','Synetrix'),(95,'SOUN','Southampton University'),(96,'SPEN','Sport England'),(97,'STAN','St Andrews'),(98,'SUDI','Supporter Direct'),(99,'SUHI','Sussex HIS'),(100,'TAPL','Talentplan / Clicks and Links'),(101,'TRHT','Trafford Housing Trust'),(102,'TOTE','Totesport'),(103,'UNPA','Unity Partnership'),(104,'VIME','Virgin Media'),(105,'VLTX','Vaultex UK'),(106,'WKBC','Wakefield Metopolitan District Council'),(107,'WRBC','Warrington Borough Council'),(108,'LAHC','Lancashire Health Community');
/*!40000 ALTER TABLE `m00_customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `m06_datasources`
--

DROP TABLE IF EXISTS `m06_datasources`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `m06_datasources` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdb_customer_id` int(10) unsigned NOT NULL,
  `source_server` varchar(45) NOT NULL,
  `source_app` varchar(45) NOT NULL,
  `hourly_table` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_datasource_customer` USING BTREE (`cdb_customer_id`),
  CONSTRAINT `FK_datasource_customer` FOREIGN KEY (`cdb_customer_id`) REFERENCES `m00_customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `m06_datasources`
--

LOCK TABLES `m06_datasources` WRITE;
/*!40000 ALTER TABLE `m06_datasources` DISABLE KEYS */;
INSERT INTO `m06_datasources` VALUES (1,108,'lancsman','rtg','hourly_data_lahc'),(2,108,'lancsman','rtg2','hourly_data_lahc'),(3,93,'sthman3','rtg','hourly_data_sthc');
/*!40000 ALTER TABLE `m06_datasources` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-08-22 10:57:52
