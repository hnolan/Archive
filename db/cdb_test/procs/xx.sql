DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`xx` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `xx` ()
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
END $$

DELIMITER ;
