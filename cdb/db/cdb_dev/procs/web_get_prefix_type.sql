DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`web_get_prefix_type` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `web_get_prefix_type` (p1 varchar(50))
BEGIN

if p1 = 'Prefix' then
  -- Join on machine to only select customers with machines defined
  select distinct c.prefix, c.fullname from m00_customers c
   inner join m01_machines m on c.id = m.cdb_customer_id
   order by c.fullname;
 else
  select distinct c.prefix, m.machine_type from m00_customers c
   inner join m01_machines m on c.id = m.cdb_customer_id
   order by c.prefix;
 end if;


END $$

DELIMITER ;
