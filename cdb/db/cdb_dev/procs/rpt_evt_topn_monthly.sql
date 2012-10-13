DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`rpt_evt_topn_monthly` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `rpt_evt_topn_monthly` (
        p_prefix varchar(10),
        p_year   int,
        p_month  int,
        p_topn   int,
        p_slots  varchar(10),
        p_grade  varchar(20)
        )
BEGIN

declare sd datetime;
declare ed datetime;

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);

call cdb_logit( 'rpt_evt_topn_monthly', 'Enter' );

-- ------------------------
--  Select matching instances
-- ------------------------

drop temporary table if exists temp_evt_topn;
create temporary table temp_evt_topn (
        toptype varchar(50),
        topval int,
        i_id integer,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_count int,
        event_duration int
        );

call _evt_topn_monthly( p_prefix, p_year, p_month, p_topn, p_grade );

-- Add index to speed up final join (below)
alter table temp_evt_topn add index IDX_i_id(i_id);

call cdb_logit( 'rpt_evt_topn_monthly', 'After topn' );
-- select * from temp_evt_topn;

-- ------------------------
--  Create event slots
-- ------------------------

-- Populate input table
drop temporary table if exists temp_instance_ids;
create temporary table temp_instance_ids
 select distinct i_id from temp_evt_topn;

-- Create output table
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

-- Call routine to populate output table
call _event_slots( sd, ed, p_slots, p_grade);

call cdb_logit( 'rpt_evt_topn_monthly', 'After es2' );

-- Discard temp table
drop temporary table if exists temp_instance_ids;

-- ------------------------
--  Report data
-- ------------------------

-- Add index to speed up final join (below)
alter table temp_event_slots add index IDX_i_id(i_id);

-- select * from temp_evt_topn t
select toptype, topval, t.event_count as total_count, t.event_duration as total_duration, cdb_machine, cdb_instance,
        slot_start, s.event_state, s.event_grade, s.event_duration, s.event_percent
 from temp_event_slots s
  join temp_evt_topn t on s.i_id = t.i_id
  join event_instances i on i.i_id = t.i_id
 order by toptype, topval desc, slot_start, event_sort;

-- ------------------------
--  Tidy & exit
-- ------------------------

drop temporary table if exists temp_evt_topn;
drop temporary table if exists temp_event_slots;
drop temporary table if exists temp_instance_slots;

call cdb_logit( 'rpt_evt_topn_monthly', 'Exit' );

END $$

DELIMITER ;
