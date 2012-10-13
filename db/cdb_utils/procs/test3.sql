DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_utils`.`test3` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test3` ()
BEGIN
-- Made in Windows
select * from tab1;

-- A few more comments
-- on some more lines



END $$

DELIMITER ;
