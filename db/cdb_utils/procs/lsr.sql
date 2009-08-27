DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_utils`.`lsr` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lsr` ()
BEGIN
  select * from cdc_rtg.cdc_log order by id desc limit 100;
END $$

DELIMITER ;
