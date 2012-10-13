DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`test_evt_topn_list` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_evt_topn_list` (
        p_prefix varchar(20),
        p_year   int,
        p_month  int,
        p_topn   int,
        p_grade  varchar(20)
        )
BEGIN

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

-- select * from temp_evt_topn;


select toptype, topval, cdb_prefix, cdb_machine, cdb_instance,
        event_count, event_duration as total_duration, sec_to_time(t.event_duration) as total_hours
 from temp_evt_topn t
  join event_instances i on i.i_id = t.i_id
 order by toptype, topval desc;

drop temporary table if exists temp_evt_topn;

END $$

DELIMITER ;
