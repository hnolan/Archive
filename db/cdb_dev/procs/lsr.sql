DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`lsr` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lsr` ()
BEGIN
  select * from cdb_log order by id desc limit 100;
END $$

DELIMITER ;
