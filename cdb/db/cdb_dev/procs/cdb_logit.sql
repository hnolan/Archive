DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`cdb_logit` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_logit` (pn varchar(80), txt varchar(1024))
BEGIN
insert into cdb_log (dt,pn,txt) values (now(),pn,txt);
END $$

DELIMITER ;
