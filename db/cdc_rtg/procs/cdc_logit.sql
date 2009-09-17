DELIMITER $$

DROP PROCEDURE IF EXISTS `cdc_rtg`.`cdc_logit` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdc_logit` (
        pn varchar(80),
        txt varchar(1024)
        )
BEGIN
  insert into cdc_log (dt,pn,txt) values (now(),pn,txt);
END $$

DELIMITER ;
