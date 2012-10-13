-- MySQL dump 10.11
--
-- Host: localhost    Database: cdb_utils
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
-- Dumping routines for database 'cdb_utils'
--
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `dump_code` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `dump_code`(
        dumpdir varchar(50)
        )
BEGIN

declare pn varchar(50) default 'dump_code';
declare rc int default 0;

declare done int default 0;

declare dumpdat varchar(20);
declare dumpdb varchar(50);
declare dumpfil varchar(250);
declare dumpfil2 varchar(250);
declare procname varchar(50);
declare viewname varchar(50);

declare proccur cursor for select db, name from mysql.proc;
declare continue handler for not found set done = 1;
declare continue handler for 1086 set done = 1;

set dumpdat = date_format(now(),'%Y%m%d.%H%i');

open proccur;

fetch next from proccur into dumpdb, procname;

repeat

  set dumpfil = concat( dumpdir, '/', dumpdb, '.', procname, '.code.sql' );
  set @sql = 'select body from mysql.proc ';
  set @sql = concat( @sql, ' where db = ''', dumpdb, ''' and name = ''', procname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil, ''' ' );
  prepare ct from @sql;
  execute ct;

  set dumpfil2 = concat( dumpdir, '/', dumpdb, '.', procname, '.param.sql' );
  set @sql = 'select param_list from mysql.proc ';
  set @sql = concat( @sql, ' where db = ''', dumpdb, ''' and name = ''', procname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil2, ''' ' );
  prepare ct from @sql;
  execute ct;

  fetch next from proccur into dumpdb, procname;

 until done end repeat;

 close proccur;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `ls` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ls`()
BEGIN
  select * from cdc_rtg.cdc_log order by id limit 100;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `lsr` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `lsr`()
BEGIN
  select * from cdc_rtg.cdc_log order by id desc limit 100;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `test3` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `test3`()
BEGIN
-- Made in Windows
select * from tab1;

-- A few more comments
-- on some more lines



END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `weeknos` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `weeknos`(
        d datetime, m int
        )
BEGIN

declare i integer default 0;
declare dt datetime;

create temporary table t1 (
dateval datetime,
dayno   int(10),
weekno  int(10)
);

truncate table t1;

set dt = d;

while i < 14 do
  insert into t1 values ( dt, dayofweek(dt), week(dt,m) );
  set dt = date_add( dt, interval 1 day );
  set i = i + 1;
 end while;

select * from t1;

drop temporary table t1;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `xx` */;;
/*!50003 SET SESSION SQL_MODE="STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER"*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `xx`()
BEGIN

truncate table cdc_rtg.cdc_export_data;
truncate table cdc_rtg.cdc_hourly_data;
truncate table cdc_rtg.cdc_datasets;
truncate table cdc_rtg.cdc_interfaces;
truncate table cdc_rtg.rtg_data_stats;
truncate table cdc_rtg.cdc_log;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
DELIMITER ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
