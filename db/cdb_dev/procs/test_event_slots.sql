DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`test_event_slots` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_event_slots` (
        p_sd    date,
        p_ed    date,
        p_type  varchar(20),
        p_grade varchar(20)
        )
BEGIN

drop temporary table if exists temp_instance_ids;
create temporary table temp_instance_ids (
        i_id integer
        );

drop temporary table if exists temp_event_slots;
create temporary table temp_event_slots (
        i_id int,
        slot_start date,
        slot_end date,
        event_sort int,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA','UP/OK') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_duration int,
        event_percent decimal(7,4)
        );

insert into temp_instance_ids (i_id) values (4038),(4039);

call _event_slots(p_sd,p_ed,p_type,p_grade);

select * from temp_event_slots order by i_id, slot_start, event_sort;

drop temporary table if exists temp_event_slots;
drop temporary table if exists temp_instance_ids;

END $$

DELIMITER ;
