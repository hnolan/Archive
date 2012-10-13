DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`evt_update_stats_monthly` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `evt_update_stats_monthly` (
        p_year int,
        p_month int
        )
BEGIN

/*
Update monthly table from daily data
*/
-- Declare variables and cursors
declare pn varchar(50) default 'evt_update_stats_monthly';
declare rc_upd integer default 0;
declare rc_ins integer default 0;
declare sd datetime;
declare ed datetime;

-- Log entry
call cdb_logit( pn, concat( 'Enter - event stats update - monthly ( ', p_year, ', ', p_month, ' )' ) );

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);


-- Update existing data for given month
update evt_stats_monthly md join (
    select cdb_instance_id, event_state, event_grade, sum(event_duration) as m_duration, sum(event_count) as m_count
      from evt_stats_daily
     where sample_date >= sd and sample_date < ed
      group by cdb_instance_id, event_state, event_grade
    ) dts on md.cdb_instance_id = dts.cdb_instance_id and md.event_state = dts.event_state and md.event_grade = dts.event_grade
  set event_duration = m_duration, event_count = m_count
  where sample_year = p_year and sample_month = p_month
   -- Only update entries that have additional events
   and m_count > event_count;

set rc_upd = row_count();

-- Insert new data for given month
insert into evt_stats_monthly ( sample_year, sample_month, cdb_instance_id, event_state, event_grade, event_duration, event_count )
 select year(sample_date), month(sample_date), cdb_instance_id, event_state, event_grade, sum(event_duration), sum(event_count)
   from evt_stats_daily e1
  where sample_date >= sd and sample_date < ed and cdb_instance_id not in (
    select cdb_instance_id from evt_stats_monthly as e2
     where sample_year = p_year and sample_month = p_month
      and e2.event_state = e1.event_state and e2.event_grade = e1.event_grade
    )
  group by year(sample_date), month(sample_date), cdb_instance_id, event_state, event_grade;

set rc_ins = row_count();

-- report results
if rc_upd > 0 then
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted, ', rc_upd, ' rows updated' ) );
 else
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted' ) );
 end if;

END $$

DELIMITER ;
