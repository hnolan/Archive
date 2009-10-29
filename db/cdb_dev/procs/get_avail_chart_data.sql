DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`get_avail_chart_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_avail_chart_data` (
        p_prefix varchar(10),
        p_machine varchar(250),
        p_instance varchar(250),
        start_date varchar(30),
        end_date varchar(30),
        slot_size varchar(20)
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables
declare sd date;
declare ed date;
declare d1 date;
declare d2 date;
declare rc int default 0;
declare msg varchar(250);
declare event_table varchar(50);

-- ---------------------
--  Validate params
-- ---------------------

-- Check that an event table is defined for this prefix
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_app = 'nagevt'
 into rc;

if rc = 1 then
  select ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_app = 'nagevt'
   into event_table;
 else
  set msg = concat( 'Exit. *** Error - ', rc, ' datasources found ***' );
  call cdb_logit( 'event_info', msg );
  select msg;
  leave main;
 end if;

-- Validate input dates
if end_date = '' then
  set ed = cast(now() as date);
 else
  set ed = cast(end_date as date);
 end if;

if start_date = '' then
  set sd = date_sub( ed, interval 30 day );
 else
  set sd = cast(start_date as date);
 end if;

set slot_size = lcase(slot_size);

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

-- ------------------------
--  Select matching instances
-- ------------------------

drop temporary table if exists temp_selections;

create temporary table temp_selections
 select i_id, concat( cdb_machine, if(cdb_instance='','',':'), cdb_instance ) as selection
 from event_instances where cdb_machine like p_machine and cdb_instance like p_instance;

-- ------------------------
--  Select matching events
-- ------------------------

drop temporary table if exists temp_events;

set @sql = concat( 'create temporary table temp_events ' );
set @sql = concat( @sql, 'select selection, concat( ev_state, '' - '', hard_soft ) as series, e.* ' );
set @sql = concat( @sql, ' from ', event_table, ' e join temp_selections s on e.cdb_instance_id = s.i_id ' );
set @sql = concat( @sql, '  where e.start_time < ''', ed, ''' and ( e.end_time > ''', sd, ''' or e.end_time is null )' );

prepare evtsel from @sql;
execute evtsel;

-- ------------------------
--  Calculate outage slots
-- ------------------------

drop temporary table if exists temp_outage_slots;

create temporary table temp_outage_slots
select slot_start, slot_duration, series, selection,
 count(*) as event_count,
 sum(
   TIMESTAMPDIFF(
     SECOND,
     CASE when start_time < slot_start then slot_start else start_time END,
     CASE when end_time is null then slot_end when end_time > slot_end then slot_end else end_time END
     )
   ) event_duration
 from temp_events e join temp_slots s
  on e.start_time < slot_end and ( end_time > slot_start or end_time is null )
 group by slot_start, slot_end, series, selection
 order by slot_start, slot_end, series;

-- ------------------------
--  Calculate uptime slots
-- ------------------------

drop temporary table if exists temp_uptime_slots;

create temporary table temp_uptime_slots
select e.selection,
   case
     when s.slot_end < i.first_status_time or s.slot_start > i.latest_status_time then 'NO DATA'
     when instr(e.selection,':') then 'OK'
     else 'UP'
    end as series,
   s.slot_start as category,
   1 as event_count, s.slot_duration, s.slot_duration - ifnull(o.down_time,0) as event_duration
  from temp_slots s
   cross join temp_selections e
   left join cdb_instances i on e.i_id = i.id
   left join (
    select slot_start, selection, sum(event_duration) as down_time
     from temp_outage_slots group by slot_start, selection
    ) o on s.slot_start = o.slot_start and e.selection = o.selection;

-- ------------------------
--  Combine up and out time
-- ------------------------
select selection, category, series, slot_duration, event_count, event_duration, round(100 * event_duration / slot_duration,2) as 'event_percent'
  from temp_uptime_slots where event_duration > 0
 union
  select selection, slot_start as category, series,
    slot_duration, event_count, event_duration, round(100 * event_duration / slot_duration,2) as 'event_percent'
   from temp_outage_slots
 order by selection, category, series;

END; -- end of 'main' block

-- Tidy up, before exit
drop temporary table if exists temp_uptime_slots;
drop temporary table if exists temp_outage_slots;
drop temporary table if exists temp_events;
drop temporary table if exists temp_selections;
drop temporary table if exists temp_slots;

END $$

DELIMITER ;
