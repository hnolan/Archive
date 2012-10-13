DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`web_get_machine_counter` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `web_get_machine_counter` (
        p_prefix varchar(50),
        mc varchar(50)
        )
BEGIN

if mc = 'Machine' then
  select distinct name from m01_machines m
   inner join m00_customers c on c.id = m.cdb_customer_id
   where prefix = p_prefix;
 else
  if mc = 'Counter' then
    select distinct counter from dataset_details
     where prefix = p_prefix;
   else
    select distinct machine, counter from dataset_details
     where prefix = p_prefix;
   end if;
 end if;

END $$

DELIMITER ;
