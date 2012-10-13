DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`event_info` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `event_info` (
        p_prefix varchar(10),
        p_start datetime,
        p_end datetime
        )
BEGIN

declare p_total int;
set p_total = TIMESTAMPDIFF(SECOND,p_start,p_end);

select entry_type,
 count(*), sum( TIMESTAMPDIFF( SECOND,
 CASE when start_time < p_start then p_start else start_time END,
 CASE when end_time is null then p_end when end_time > p_end then p_end else end_time END
 )) dur,
 100 * sum( TIMESTAMPDIFF( SECOND,
 CASE when start_time < p_start then p_start else start_time END,
 CASE when end_time is null then p_end when end_time > p_end then p_end else end_time END
 )) / p_total as '% dur'
 from nagios_events_sthc e
 where e.start_time < p_end and ( end_time > p_start or end_time is null )
 group by entry_type;

END $$

DELIMITER ;
