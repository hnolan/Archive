DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`test_evt_topn_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_evt_topn_data` (
        p_prefix varchar(20),
        p_year  int,
        p_month int,
        p_topn  int,
        p_grade varchar(20)
        )
BEGIN

declare sd datetime;
declare ed datetime;

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);

create temporary table temp_evt_topn (
        toptype varchar(50),
        topval int,
        i_id integer,
        event_state enum('UP','DOWN','UNREACHABLE','OK','WARNING','CRITICAL','UNKNOWN','NODATA') NOT NULL,
        event_grade enum('HARD','SOFT') NOT NULL,
        event_count int,
        event_duration int
        );

-- Get Event Top Tens
call _evt_topn_monthly( p_prefix, p_year, p_month, p_topn, p_grade );

select toptype, topval, sample_date, cdb_prefix, cdb_machine, cdb_instance, event_state, event_grade, d.duration as event_duration, d.event_count
 from temp_evt_topn t
  join event_instances i on i.i_id = t.i_id
  join evt_stats_daily d on d.cdb_instance_id = t.i_id and d.event_state = t.event_state and d.event_grade = t.event_grade
 where sample_date >= sd and sample_date < ed
 order by toptype, topval desc, cdb_instance_id, event_state, event_grade;

drop temporary table if exists temp_evt_topn;

END $$

DELIMITER ;
