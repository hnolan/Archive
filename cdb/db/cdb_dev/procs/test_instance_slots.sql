DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`test_instance_slots` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_instance_slots` ()
BEGIN

drop temporary table if exists temp_instance_ids;
create temporary table temp_instance_ids (
        i_id integer
        );

drop temporary table if exists temp_instance_slots;
create temporary table temp_instance_slots (
        i_id int,
        slot_start date,
        slot_end date,
        slot_duration int,
        slot_nodata int
        );

insert into temp_instance_ids (i_id) values (4038),(4039);

call _instance_slots('2009-07-27','2009-09-27','day');

select * from temp_instance_slots;

drop temporary table if exists temp_instance_slots;
drop temporary table if exists temp_instance_ids;

END $$

DELIMITER ;
