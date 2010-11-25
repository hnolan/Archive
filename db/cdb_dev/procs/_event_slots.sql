DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`_event_slots` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `_event_slots` (
        p_start_date varchar(20),
        p_end_date   varchar(20),
        p_slot_size  varchar(20),
        p_grade      varchar(20)
        )
BEGIN

/*
----------------------------------------------------
This routine expects the calling routine to have
created temp tables with the following names and
layouts. This routine reads the input table and
populates the output table.
----------------------------------------------------
Input Table:
  create temporary table temp_instance_ids (
        i_id integer
        );
----------------------------------------------------
Output Table:
  create temporary table temp_event_slots (
        i_id int,
        slot_start date,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_duration int,
        event_percent decimal
        );
----------------------------------------------------
*/

declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare slot_len int;
declare v_grade varchar(20);
declare daily_slots boolean;

-- ------------------------
--  Param validation
-- ------------------------

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

-- Set size of slot to use
if lcase(p_slot_size) = 'day' or lcase(p_slot_size) = 'daily' then
    -- Use slots of one day each
    set slot_len = 86400;
    set daily_slots = true;
 else
    -- Use one single slot
    set slot_len = timestampdiff( second, sd, ed );
    set daily_slots = false;
 end if;

-- Validate grade of event
if ucase(p_grade) = 'HARD' then
    set v_grade = 'HARD';
  elseif ucase(p_grade) = 'SOFT' then
    set v_grade = 'SOFT';
  else
    set v_grade = '%';
  end if;

-- ------------------------
--  Create base slots
-- ------------------------

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
        slot_start date,
        slot_end date,
        slot_duration int
        );

-- Generate time slots
if daily_slots then
    -- Populate table with daily dates
    set d1 = sd;
    while d1 < ed do
      set d2 = date_add( d1, interval 1 day );
      insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, slot_len );
      set d1 = d2;
     end while;
 else
    -- Populate table with a single timeslot
    insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( sd, ed, slot_len );
 end if;

-- ------------------------
--  Create instance slots
-- ------------------------

-- Generate slots for instances (with dead times)
drop temporary table if exists temp_instance_slots;
create temporary table temp_instance_slots
 select i_id, slot_start, slot_end, slot_duration, state_id, event_state, event_grade,
  case when o_id = 2 then 'UP' else 'OK' end as up_state,
  case when event_state = 'NODATA' then
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
   end
    else 0
   end as event_duration
 from temp_slots s
  cross join (
    select i.i_id, first_status_time, latest_status_time, e.o_id, e.id as state_id, event_state, event_grade
    from event_instances i
     join temp_instance_ids t on i.i_id = t.i_id
     join cdb_event_states e on e.o_id = i.o_id
    ) i2;

-- Discard temp table
drop temporary table if exists temp_slots;

-- select * from temp_instance_slots;

-- ------------------------
--  Create outage slots
-- ------------------------

-- Add outage from daily event stats
drop temporary table if exists temp_outage_slots;
create temporary table temp_outage_slots (
        slot_start date,
        i_id int,
        item_duration int,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA','UP/OK') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL
        );

if daily_slots then
    update temp_instance_slots i
      join evt_stats_daily e on e.cdb_instance_id = i.i_id and e.sample_date = i.slot_start
        and e.event_state = i.event_state and e.event_grade = i.event_grade
     set i.event_duration = e.event_duration
      where i.event_state not in ( 'UP', 'OK', 'NODATA' ) and i.event_grade like v_grade;
  else
    update temp_instance_slots i
      join (
        select sd as slot_start, cdb_instance_id as i_id, sum(event_duration) as event_duration, event_state, event_grade
         from evt_stats_daily s where sample_date >= sd and sample_date < ed
         group by i_id, event_state, event_grade
        ) e on e.i_id = i.i_id and e.slot_start = i.slot_start
        and e.event_state = i.event_state and e.event_grade = i.event_grade
     set i.event_duration = e.event_duration
      where i.event_state not in ( 'UP', 'OK', 'NODATA' ) and i.event_grade like v_grade;
  end if;

-- ------------------------
--  Create uptime slots
-- ------------------------

-- Calculate uptime of slots with outages
drop temporary table if exists temp_uptime_slots;
 create temporary table temp_uptime_slots
 select slot_start, i_id, slot_len - sum(event_duration) as event_duration, up_state as event_state, 'HARD' as event_grade
  from temp_instance_slots group by slot_start, i_id;

-- Update slot table with uptimes
update temp_instance_slots i
      join temp_uptime_slots u on u.i_id = i.i_id and u.slot_start = i.slot_start
        and u.event_state = i.event_state and u.event_grade = i.event_grade
     set i.event_duration = u.event_duration;

-- Return slot data with percentages
insert into temp_event_slots ( i_id, slot_start, slot_end, event_sort, event_state, event_grade, event_duration, event_percent )
 select i_id, slot_start, slot_end, state_id, event_state, event_grade, event_duration,
   ( 100.00 * event_duration / slot_duration ) as event_percent
  from temp_instance_slots;

-- ------------------------
--  Tidy & exit
-- ------------------------

drop temporary table if exists temp_instance_slots;
drop temporary table if exists temp_uptime_slots;

END $$

DELIMITER ;
