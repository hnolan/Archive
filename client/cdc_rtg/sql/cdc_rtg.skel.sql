-- MySQL dump 10.11
--
-- Host: localhost    Database: cdc_rtg
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
-- Table structure for table `cdc_counters`
--

DROP TABLE IF EXISTS `cdc_counters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_counters` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `mib_item` varchar(45) NOT NULL,
  `cdc_counter` varchar(45) NOT NULL,
  `factor` int(10) unsigned NOT NULL default '1',
  `cdc_object` varchar(45) NOT NULL default 'Interface',
  `map_type` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cdc_dataset_details`
--

DROP TABLE IF EXISTS `cdc_dataset_details`;
/*!50001 DROP VIEW IF EXISTS `cdc_dataset_details`*/;
/*!50001 CREATE TABLE `cdc_dataset_details` (
  `dsid` int(10) unsigned,
  `rtg_data_table` varchar(45),
  `import_from` datetime,
  `import_before` datetime,
  `export_from` datetime,
  `exported` tinyint(1),
  `rtg_iid` int(10) unsigned,
  `cdc_machine` varchar(45),
  `cdc_object` varchar(45),
  `cdc_instance` varchar(45),
  `cdc_counter` varchar(45),
  `speed` bigint(20) unsigned,
  `description` varchar(250),
  `mib_item` varchar(45),
  `factor` int(10) unsigned,
  `map_type` varchar(45)
) ENGINE=MyISAM */;

--
-- Table structure for table `cdc_datasets`
--

DROP TABLE IF EXISTS `cdc_datasets`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_datasets` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `cdc_iid` int(10) unsigned NOT NULL,
  `cdc_cid` int(10) unsigned NOT NULL,
  `rtg_data_table` varchar(45) NOT NULL,
  `import_from` datetime NOT NULL,
  `import_before` datetime NOT NULL,
  `export_from` datetime NOT NULL,
  `exported` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `IDX_cdc_iid` (`cdc_iid`),
  KEY `IDX_cdc_cid` (`cdc_cid`)
) ENGINE=InnoDB AUTO_INCREMENT=2645 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cdc_export_data`
--

DROP TABLE IF EXISTS `cdc_export_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_export_data` (
  `sample_date` date NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `dsid` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_date`,`sample_hour`,`dsid`),
  KEY `IDX_dsid` USING BTREE (`dsid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cdc_hourly_data`
--

DROP TABLE IF EXISTS `cdc_hourly_data`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_hourly_data` (
  `sample_time` datetime NOT NULL,
  `dsid` int(10) unsigned NOT NULL,
  `hdate` datetime NOT NULL,
  `hhour` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  USING BTREE (`sample_time`,`dsid`),
  KEY `IDX_dsid` USING BTREE (`dsid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cdc_hourly_stats`
--

DROP TABLE IF EXISTS `cdc_hourly_stats`;
/*!50001 DROP VIEW IF EXISTS `cdc_hourly_stats`*/;
/*!50001 CREATE TABLE `cdc_hourly_stats` (
  `dsid` int(10) unsigned,
  `first_hourly_sample` datetime,
  `last_hourly_sample` datetime,
  `next_hourly_sample` datetime,
  `hourly_sample_count` bigint(21)
) ENGINE=MyISAM */;

--
-- Table structure for table `cdc_interfaces`
--

DROP TABLE IF EXISTS `cdc_interfaces`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_interfaces` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `rtg_rid` int(10) unsigned NOT NULL,
  `rtg_iid` int(10) unsigned NOT NULL,
  `router_name` varchar(45) NOT NULL,
  `interface_name` varchar(45) NOT NULL,
  `speed` bigint(20) unsigned NOT NULL,
  `description` varchar(250) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `IDX_full_name` USING BTREE (`router_name`,`interface_name`),
  KEY `IDX_rtg_iid` (`rtg_iid`)
) ENGINE=InnoDB AUTO_INCREMENT=4433 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cdc_log`
--

DROP TABLE IF EXISTS `cdc_log`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_log` (
  `id` int(11) NOT NULL auto_increment,
  `dt` datetime NOT NULL,
  `pn` varchar(80) default NULL,
  `txt` varchar(1024) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=110 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rtg_data_stats`
--

DROP TABLE IF EXISTS `rtg_data_stats`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `rtg_data_stats` (
  `rtg_rid` int(10) unsigned default NULL,
  `rtg_iid` int(10) unsigned NOT NULL,
  `rtg_mib_item` varchar(45) default NULL,
  `rtg_data_table` varchar(45) NOT NULL,
  `rtg_first_sample` datetime NOT NULL,
  `rtg_last_sample` datetime NOT NULL,
  `rtg_sample_count` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`rtg_data_table`,`rtg_iid`),
  KEY `IDX_mib_item` (`rtg_mib_item`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tempds`
--

DROP TABLE IF EXISTS `tempds`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tempds` (
  `dsid` int(10) unsigned NOT NULL default '0',
  `cdc_machine` varchar(45) NOT NULL,
  `cdc_object` varchar(45) NOT NULL default '',
  `cdc_instance` varchar(45) NOT NULL,
  `cdc_counter` varchar(45) NOT NULL,
  `speed` bigint(20) unsigned NOT NULL,
  `description` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tempdt`
--

DROP TABLE IF EXISTS `tempdt`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tempdt` (
  `sample_date` date NOT NULL,
  `sample_hour` int(10) unsigned NOT NULL,
  `dsid` int(10) unsigned NOT NULL,
  `data_min` float NOT NULL,
  `data_max` float NOT NULL,
  `data_sum` float NOT NULL,
  `data_count` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'cdc_rtg'
--
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `cdc_export` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdc_export`(
        bdt varchar(50),
        prefix varchar(10),
        hostnam varchar(50),
        outdir varchar(250)
        )
BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdc_export';
declare rc integer default 0;
declare rc2 integer default 0;

declare bt datetime;

-- declare prefix varchar(10) default 'LHC';
-- declare hostnam varchar(50) default 'lancsman';
-- declare outdir varchar(250) default 'd:/projects/cdb/export';

declare datafil varchar(250);
declare metafil varchar(250);

call cdc_logit( pn, concat( 'Enter (',bdt,')' ) );

set datafil = concat(outdir,'/', prefix, '.', hostnam, '.',date_format(now(),'%Y%m%d.%H%i'),'.data');
set metafil = concat(outdir,'/', prefix, '.', hostnam, '.',date_format(now(),'%Y%m%d.%H%i'),'.meta');

-- Set the upper date limit to now, or the value passed in, if present
if bdt = '' then
   set bt = now();
 else
   set bt = cast( bdt as datetime );
 end if;

-- ------------------------
--  Select data for export
-- ------------------------

-- Get all unexported rows (up to requested limit)
truncate table cdc_export_data;

insert into cdc_export_data
 select dt.hdate, dt.hhour, dt.dsid, dt.data_min, dt.data_max, dt.data_sum, dt.data_count
  from cdc_hourly_data dt join cdc_datasets ds on dt.dsid = ds.id
  where dt.sample_time >= ds.export_from and dt.sample_time < bt;

set rc = row_count();

-- ----------------------
--  Export datasets
-- ----------------------

if rc > 0 then
  set @sql = 'select dsid, cdc_machine, cdc_object, cdc_instance, cdc_counter, speed, description ';
  set @sql = concat( @sql, ' from cdc_dataset_details dd where dd.dsid in ( select dsid from cdc_export_data ) ' );
  set @sql = concat( @sql, '  into outfile ''', metafil, ''' ' );
  prepare ed from @sql;
  execute ed;
  select count(distinct dsid) from cdc_export_data into rc2;
  call cdc_logit( pn, CONCAT( 'Exported ', rc2, ' datasets to ', metafil ) );
 end if;

-- ----------------------
--  Export data
-- ----------------------

if rc > 0 then

  set @sql = concat( 'select * from cdc_export_data into outfile ''', datafil, ''' ' );
  prepare ed from @sql;
  execute ed;

  -- Update the export timestamps in cdb_datasets
  update cdc_datasets ds join (
    select dsid, max(date_add( sample_date, interval (sample_hour) hour)) as hwm
     from cdc_export_data group by dsid
     ) hw on ds.id = hw.dsid
      set ds.export_from = hw.hwm + interval 1 hour;

  call cdc_logit( pn, CONCAT( 'Exit. Exported ', rc, ' hourly rows to ', datafil ) );
 else
  call cdc_logit( pn, CONCAT( 'Exit. No new data to export' ) );
 end if;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdc_import` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdc_import`(
        bdt varchar(50)
        )
BEGIN

/*

This procedure produces hourly summaries from data in rtg data tables.

It assumes that the polling interval is the default of 5 mins (300 secs).

The main query uses mappings in the cdb_counters table to convert the
raw data to use more sustainable units (e.g. KBytes rather than bytes,
or KPkts rather than packets).

*/

-- Declare variables and cursors
declare pn varchar(50) default 'cdc_import';
declare rc integer default 0;
declare tc integer default 0;
declare rctot integer default 0;
declare rcout integer default 0;

declare done int default 0;
declare tabnam varchar(50);

-- Assume default duration is 5 mins (300 secs)
declare dur integer default 300;

-- Get list of data_tables from cdb_datasets
declare tabcur cursor for SELECT distinct rtg_data_table FROM cdc_datasets;
declare continue handler for not found set done = 1;

call cdc_logit( pn, concat( 'Enter (',bdt,')' ) );

/*
----------------------------------------------
 Prepare for import
 Create tempdata table and set the import_from
 field for each dataset to be one hour later than
 the latest sample in the hourly data table.
----------------------------------------------
*/

-- Update hourly stats
update cdc_datasets ds
 join cdc_hourly_stats h on ds.id = h.dsid
 set ds.import_from = h.next_hourly_sample;

-- Create temp table to accept new raw data
create temporary table tempdata (
 dsid int unsigned not null,
 dtime datetime not null,
 dval float not null
 );

/*
----------------------------------------------
 Collect raw data from multiple rtg tables
 into a single tempdata table
----------------------------------------------
*/
open tabcur;

-- Get first row from cursor
fetch next from tabcur into tabnam;

-- Update the data from each table
repeat
  set tc = tc + 1;

  set @sql = 'insert into tempdata ( dsid, dtime, dval ) ';
  set @sql = CONCAT( @sql, ' select ds.id as dsid, d.dtime, d.counter from rtg.', tabnam, ' d ' );
  set @sql = CONCAT( @sql, ' join cdc_interfaces ci on d.id = ci.rtg_iid join cdc_datasets ds on ci.id = ds.cdc_iid ' );
  set @sql = CONCAT( @sql, ' where ds.rtg_data_table = ''', tabnam, ''' and dtime >= ds.import_from' );

  -- Add endpoint condition, if supplied
  if bdt = '' then
    -- Empty param, so no condition
    set @sql = CONCAT( @sql, ';' );
   elseif length(bdt) < 3 then
    -- Short param, assume its a number of days
    set @sql = CONCAT( @sql, ' and dtime <= date_add( ds.import_from, interval ', bdt, ' day );' );
   else
    -- Longer param, assume its an explicit date
    set @sql = CONCAT( @sql, ' and dtime <= ''', bdt, ''';' );
   end if;

  prepare uht from @sql;
  execute uht;

  fetch next from tabcur into tabnam;

 until done end repeat;

close tabcur;

select count(*) from tempdata into rc;

call cdc_logit( pn, concat( 'Selected ', rc ,' raw data rows from ', tc ,' tables' ) );

/*
----------------------------------------------
 Process the temp table of raw data
----------------------------------------------
*/

-- Add an index to speed up processing
alter table tempdata add index idx1 (dsid);

/*
To prevent the query from summarising the final (potentially incomplete) hour, we
find the latest timestamp for each raw dataset, round it down to a whole hour and
only process data less than (prior to) this high water mark.
*/

-- Update cdb_datasets with raw data high water marks
update cdc_datasets ds join (
 select dsid, date_add( date(max(dtime)), interval hour(max(dtime)) hour ) as hwm
  from tempdata group by dsid
  ) td on ds.id = td.dsid
 set ds.import_before = td.hwm;

-- Insert data into the hourly table
insert into cdc_hourly_data ( sample_time, dsid, hdate, hhour, data_min, data_max, data_sum, data_count )
 select date_add( date(dtime), interval hour(dtime) hour ) as sample_time, d.dsid, date(dtime) as hdate, hour(dtime) as hhour,
  case dd.map_type when 'rate' then min(dval)/(factor * dur) when 'util' then ((min(dval)*factor/dur)/speed)*100 end,
  case dd.map_type when 'rate' then max(dval)/(factor * dur) when 'util' then ((max(dval)*factor/dur)/speed)*100 end,
  case dd.map_type when 'rate' then sum(dval)/(factor * dur) when 'util' then ((sum(dval)*factor/dur)/speed)*100 end,
  count(dval)
 from tempdata d
  inner join cdc_dataset_details dd on dd.dsid = d.dsid
 where d.dtime < dd.import_before
 group by sample_time, d.dsid;

set rc = row_count();

drop temporary table tempdata;

-- Log exit
call cdc_logit( pn, CONCAT( 'Exit. Imported ', rc, ' hourly rows' ) );

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdc_logit` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdc_logit`(
        pn varchar(80),
        txt varchar(1024)
        )
BEGIN
  insert into cdc_log (dt,pn,txt) values (now(),pn,txt);
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdc_refresh` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdc_refresh`()
BEGIN

declare pn varchar(50) default 'cdc_refresh';
declare rc int default 0;
declare rc2 int default 0;

call cdc_logit( pn, concat( 'Enter' ) );

/*
--------------------------------------
 Refresh the cdb_interfaces
--------------------------------------
*/

-- Insert any new router interfaces into cdb_interfaces
insert into cdc_interfaces ( rtg_rid, rtg_iid, router_name, interface_name, speed, description )
select r.rid, i.id, r.name, i.name, i.speed, i.description
 from rtg.router r join rtg.interface i on r.rid = i.rid
 where not exists (
  select 1 from cdc_interfaces c where c.router_name = r.name and c.interface_name = i.name
 );

set rc = row_count();
if rc > 0 then
  call cdc_logit( pn, concat( 'Created ',rc,' new router interfaces' ) );
 end if;

-- Re-map entries with different ids
update cdc_interfaces c
  join rtg.router r on c.router_name = r.name
  join rtg.interface i on r.rid = i.rid and c.interface_name = i.name
 set c.rtg_iid = i.id
  where c.rtg_iid <> i.id;

set rc2 = row_count();
if rc2 > 0 then
  call cdc_logit( pn, concat( 'Re-mapped ',rc,' router interface ids' ) );
 end if;

if rc > 0 or rc2 > 0 then
  call rtg_refresh();
 end if;

/*
--------------------------------------
 Refresh the cdb_datasets
--------------------------------------
*/

-- Insert an entry into cdb_datasets for any new datasets found
insert into cdc_datasets ( cdc_iid, cdc_cid, rtg_data_table, import_from, import_before, export_from )
select ci.id as cdc_iid, cc.id as cdc_cid, rs.rtg_data_table,
  rtg_first_sample as import_from,
  date_add( date(rtg_last_sample), interval hour(rtg_last_sample) hour ) as import_before,
  date_add( date(rtg_first_sample), interval hour(rtg_first_sample) hour ) as export_from
 from rtg_data_stats rs
 join cdc_interfaces ci on rs.rtg_iid = ci.rtg_iid
 join cdc_counters cc on rs.rtg_mib_item = cc.mib_item
 where not exists (
  select 1 from cdc_datasets ds where ds.cdc_iid = ci.id and ds.cdc_cid = cc.id
 );

-- Log dataset creation
set rc = row_count();
if rc > 0 then
  call cdc_logit( pn, concat( 'Created ',rc,' new datasets' ) );
 end if;

-- Log exit
call cdc_logit( pn, 'Exit' );

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `cdc_trim` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `cdc_trim`(
        days_old int
        )
BEGIN

declare pn varchar(50) default 'cdc_trim';
declare tc int default 0;
declare rc int default 0;
declare trim_before datetime;

-- Declare variables and cursors
declare done int default 0;
declare tabnam varchar(50);

-- Get list of data_tables from rtg_data_stats to ensure that
-- we only process tables which have data in them

declare tabcur cursor for SELECT distinct rtg_data_table FROM rtg_data_stats;
declare continue handler for not found set done = 1;

-- Check for valid datetime
set trim_before = date_add( curdate(), interval - days_old day );

call cdc_logit( pn, concat('Enter (Days old: ', days_old, ', Trim before: ', trim_before, ')') );

open tabcur;

-- Get first row from cursor
fetch next from tabcur into tabnam;

-- Trim rows from each table
repeat

  set tc = tc + 1;

  set @sql = CONCAT( 'delete from rtg.', tabnam, ' where dtime < ''', trim_before, '''' );
  prepare dt from @sql;
  execute dt;

  set rc = rc + row_count();

  fetch next from tabcur into tabnam;

 until done end repeat;

close tabcur;

call cdc_logit( pn, concat('Deleted a total of ', rc, ' rows from ', tc, ' rtg tables') );

delete from cdc_hourly_data where sample_time < trim_before;
set rc = row_count();

call cdc_logit( pn, concat('Exit. Deleted ', rc, ' rows from cdc_hourly_data') );


END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `rtg_refresh` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `rtg_refresh`()
BEGIN

declare pn varchar(50) default 'rtg_refresh';
declare rc int default 0;

-- Declare variables and cursors
declare done int default 0;
declare tc int default 0;
declare rtg_rid int;
declare cdc_mib varchar(50);
declare badtab int default 0;
declare tabnam varchar(50);

-- The cursor is a cross join of all routers with all counters
declare tabcur cursor for select distinct rid, mib_item from rtg.router join cdc_counters;
declare continue handler for not found set done = 1;
-- Handle non-existant table
declare continue handler for 1146 set badtab = 1;

call cdc_logit( pn, concat( 'Enter' ) );

/*
--------------------------------------
 Refresh the rtg_data_stats
--------------------------------------
*/

-- Clear the stats table
truncate table rtg_data_stats;

-- Collect stats from each rawdata table
open tabcur;

fetch next from tabcur into rtg_rid, cdc_mib;

repeat

  set tc = tc + 1;

  -- Enter stats from one data table into rtg_data_stats table
  set tabnam = concat( cdc_mib, '_', rtg_rid );
  set @sql = 'insert into rtg_data_stats ( rtg_rid, rtg_iid, rtg_mib_item, rtg_data_table, ';
  set @sql = CONCAT( @sql, ' rtg_first_sample, rtg_last_sample, rtg_sample_count ) ' );
  set @sql = CONCAT( @sql, 'select ', rtg_rid, ', id, ''', cdc_mib, ''', ''', tabnam, ''',  min(dtime), max(dtime), count(dtime) ' );
  set @sql = CONCAT( @sql, ' from rtg.', tabnam, ' group by id;' );

  prepare ct from @sql;

  if badtab = 0 then
    execute ct;
    set rc = row_count();
   else
    call cdc_logit(pn,CONCAT( 'Table "', tabnam, '" does not exist' ));
    set badtab = 0;
   end if;

  fetch next from tabcur into rtg_rid, cdc_mib;

 until done end repeat;

close tabcur;

call cdc_logit( pn, concat( 'Exit. Refreshed stats from ', tc, ' rtg tables' ) );

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
DELIMITER ;

--
-- Final view structure for view `cdc_dataset_details`
--

/*!50001 DROP TABLE `cdc_dataset_details`*/;
/*!50001 DROP VIEW IF EXISTS `cdc_dataset_details`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cdc_dataset_details` AS select `ds`.`id` AS `dsid`,`ds`.`rtg_data_table` AS `rtg_data_table`,`ds`.`import_from` AS `import_from`,`ds`.`import_before` AS `import_before`,`ds`.`export_from` AS `export_from`,`ds`.`exported` AS `exported`,`ci`.`rtg_iid` AS `rtg_iid`,`ci`.`router_name` AS `cdc_machine`,`cc`.`cdc_object` AS `cdc_object`,`ci`.`interface_name` AS `cdc_instance`,`cc`.`cdc_counter` AS `cdc_counter`,`ci`.`speed` AS `speed`,`ci`.`description` AS `description`,`cc`.`mib_item` AS `mib_item`,`cc`.`factor` AS `factor`,`cc`.`map_type` AS `map_type` from ((`cdc_datasets` `ds` join `cdc_interfaces` `ci` on((`ds`.`cdc_iid` = `ci`.`id`))) join `cdc_counters` `cc` on((`ds`.`cdc_cid` = `cc`.`id`))) */;

--
-- Final view structure for view `cdc_hourly_stats`
--

/*!50001 DROP TABLE `cdc_hourly_stats`*/;
/*!50001 DROP VIEW IF EXISTS `cdc_hourly_stats`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cdc_hourly_stats` AS select `cdc_hourly_data`.`dsid` AS `dsid`,min(`cdc_hourly_data`.`sample_time`) AS `first_hourly_sample`,max(`cdc_hourly_data`.`sample_time`) AS `last_hourly_sample`,(max(`cdc_hourly_data`.`sample_time`) + interval 1 hour) AS `next_hourly_sample`,count(0) AS `hourly_sample_count` from `cdc_hourly_data` group by `cdc_hourly_data`.`dsid` */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-08-01 18:22:07
-- MySQL dump 10.11
--
-- Host: localhost    Database: cdc_rtg
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
-- Table structure for table `cdc_counters`
--

DROP TABLE IF EXISTS `cdc_counters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cdc_counters` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `mib_item` varchar(45) NOT NULL,
  `cdc_counter` varchar(45) NOT NULL,
  `factor` int(10) unsigned NOT NULL default '1',
  `cdc_object` varchar(45) NOT NULL default 'Interface',
  `map_type` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `cdc_counters`
--

LOCK TABLES `cdc_counters` WRITE;
/*!40000 ALTER TABLE `cdc_counters` DISABLE KEYS */;
INSERT INTO `cdc_counters` VALUES (1,'ifInOctets','ifInKBytes/s',1024,'Interface','rate'),(2,'ifOutOctets','ifOutKBytes/s',1024,'Interface','rate'),(3,'ifInUcastPkts','ifInKPkts/s',1024,'Interface','rate'),(4,'ifOutUcastPkts','ifOutKPkts/s',1024,'Interface','rate'),(5,'ifInOctets','ifIn%Util',8,'Interface','util'),(6,'ifOutOctets','ifOut%Util',8,'Interface','util');
/*!40000 ALTER TABLE `cdc_counters` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-08-01 18:22:07
