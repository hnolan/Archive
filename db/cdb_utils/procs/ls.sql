DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_utils`.`ls` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ls` ()
BEGIN
  select * from cdc_rtg.cdc_log order by id limit 100;
END $$

DELIMITER ;
