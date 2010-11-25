DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`_instance_slots` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `_instance_slots` (
        p_start_date varchar(30),
        p_end_date varchar(30),
        p_slot_size varchar(20)
        )
BEGIN

/*
----------------------------------------------------
This routine expects the calling routine to have
created temp tables with the following names and
layouts. This routine populates the tables.
----------------------------------------------------
create temporary table temp_instance_ids (
        i_id integer
        );
----------------------------------------------------
create temporary table temp_instance_slots (
        i_id int,
        slot_start date,
        slot_end date,
        slot_duration int,
        slot_nodata int
        );
----------------------------------------------------
*/

-- Declare variables
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);
declare event_table varchar(50);
declare slot_size varchar(20);
declare hard_or_soft varchar(20);

-- Validate input dates
if p_end_date = '' then
  set ed = cast(now() as date);
 else
  set ed = cast(p_end_date as date);
 end if;

if p_start_date = '' then
  set sd = date_sub( ed, interval 30 day );
 else
  set sd = cast(p_start_date as date);
 end if;

set slot_size = lcase(p_slot_size);

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
 slot_start date,
 slot_end date,
 slot_duration int
 );

-- Generate time slots
if slot_size = 'day' or slot_size = 'daily' then
    -- Populate table with daily dates
    set d1 = sd;
    while d1 < ed do
      set d2 = date_add( d1, interval 1 day );
      insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, timestampdiff( second, d1, d2 ) );
      set d1 = d2;
     end while;
 else
    -- Populate table with a single timeslot
   insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( sd, ed, timestampdiff( second, sd, ed ) );
 end if;

-- Add indexes to improve join performance
-- alter table

-- Generate slots for instances (with dead times)
insert into temp_instance_slots ( i_id, slot_start, slot_end, slot_duration, slot_nodata )
 select i_id, slot_start, slot_end, slot_duration,
  case
    when first_status_time <= slot_start then 0
    when first_status_time < slot_end then timestampdiff( second, slot_start, first_status_time )
    else slot_duration
   end
   +
  case
    when latest_status_time >= slot_end then 0
    when latest_status_time > slot_start then timestampdiff( second, latest_status_time, slot_end )
    else slot_duration
   end as slot_nodata
 from temp_slots s
  cross join ( select i.i_id, first_status_time, latest_status_time from event_instances i join temp_instance_ids t on i.i_id = t.i_id ) i2;

drop temporary table if exists temp_slots;

END $$

DELIMITER ;
