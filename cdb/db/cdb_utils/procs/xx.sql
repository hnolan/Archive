DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_utils`.`xx` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `xx` ()
BEGIN

truncate table cdc_rtg.cdc_export_data;
truncate table cdc_rtg.cdc_hourly_data;
truncate table cdc_rtg.cdc_datasets;
truncate table cdc_rtg.cdc_interfaces;
truncate table cdc_rtg.rtg_data_stats;
truncate table cdc_rtg.cdc_log;

END $$

DELIMITER ;
