DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`evt_update_stats_daily` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `evt_update_stats_daily` (
        update_upto varchar(50),
        days_before int
        )
BEGIN

-- Declare variables
declare pn varchar(50) default 'evt_update_stats_daily';
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);

-- ---------------------
--  Validate params
-- ---------------------

if update_upto = '' then
  set ed = now();
 else
  set ed = cast(update_upto as date);
 end if;

if days_before <= 0 then
  set sd = date_sub( ed, interval 14 day );
 else
  set sd = date_sub( ed, interval days_before day );
 end if;

call cdb_logit( pn, concat( 'Enter (',update_upto,', ',days_before,') [ From ', sd, ' to ', ed, ' ]' ) );

-- ---------------------
--  Generate slot table
-- ---------------------

-- Generate a temporary table containing timeslots in the range
drop temporary table if exists temp_slots;
create temporary table temp_slots (
 slot_start date,
 slot_end date,
 slot_duration int
 );

-- Generate time slots; populate table with daily dates
set d1 = sd;
while d1 < ed do
  set d2 = date_add( d1, interval 1 day );
  insert into temp_slots ( slot_start, slot_end, slot_duration ) value ( d1, d2, timestampdiff( second, d1, d2 ) );
  set d1 = d2;
 end while;

ALTER TABLE temp_slots ADD INDEX `IDX_slot_start`(`slot_start`);
ALTER TABLE temp_slots ADD INDEX `IDX_slot_end`(`slot_end`);

-- select * from temp_slots;

-- ----------------------------
--  Select/Slice events to slots
-- ----------------------------
create temporary table temp_event_slots
 select slot_start as sample_date, cdb_instance_id, ev_state as event_state, hard_soft as event_grade,
   TIMESTAMPDIFF( SECOND, greatest(start_time,slot_start), least(end_time,slot_end) ) as effective_duration
 from nagios_events_merge e
  cross join temp_slots s
   -- Select only completed events - ignore events with NULL end_time
 where start_time < ed and end_time > sd
  and start_time < slot_end and end_time > slot_start;

-- select * from temp_event_slots order by sample_date, cdb_instance_id;

-- ----------------------------
--  Aggregate slot data
-- ----------------------------

-- Aggregate event data to temp table
create temporary table temp_agg_event_slots
 select sample_date, cdb_instance_id, event_state, event_grade,
  sum(effective_duration) as event_duration, count(*) as event_count
 from temp_event_slots
  group by sample_date, cdb_instance_id, event_state, event_grade;

-- select * from temp_agg_event_slots order by sample_date, cdb_instance_id;

-- ----------------------------
--  Update daily table
-- ----------------------------

-- Insert new event data into daily table
insert into evt_stats_daily ( sample_date, cdb_instance_id, event_state, event_grade, event_duration, event_count )
 select t1.sample_date, t1.cdb_instance_id, t1.event_state, t1.event_grade, t1.event_duration, t1.event_count
  from temp_agg_event_slots t1
  where t1.sample_date not in (
   select t2.sample_date from evt_stats_daily t2
   where t2.cdb_instance_id = t1.cdb_instance_id and t2.event_state = t1.event_state and t2.event_grade = t1.event_grade
  );

-- Log exit
set rc = row_count();
call cdb_logit( pn, concat( 'Exit -  ',rc,' new rows inserted' ) );

-- Tidy up, before exit
drop temporary table if exists temp_slots;
drop temporary table if exists temp_event_slots;
drop temporary table if exists temp_agg_event_slots;

END $$

DELIMITER ;
