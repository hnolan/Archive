DELIMITER $$

DROP PROCEDURE IF EXISTS `cdc_rtg`.`cdc_trim` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdc_trim` (
        days_old int
        )
BEGIN

declare pn varchar(50) default 'cdc_trim';
declare tc int default 0;
declare rc int default 0;
declare trim_before datetime;

-- Declare variables and cursors
declare done int default 0;
declare tabnam varchar(50);

-- Get list of data_tables from rtg_data_stats to ensure that
-- we only process tables which have data in them

declare tabcur cursor for SELECT distinct rtg_data_table FROM rtg_data_stats;
declare continue handler for not found set done = 1;

-- Check for valid datetime
set trim_before = date_add( curdate(), interval - days_old day );

call cdc_logit( pn, concat('Enter (Days old: ', days_old, ', Trim before: ', trim_before, ')') );

open tabcur;

-- Get first row from cursor
fetch next from tabcur into tabnam;

-- Trim rows from each table
repeat

  set tc = tc + 1;

  set @sql = CONCAT( 'delete from rtg.', tabnam, ' where dtime < ''', trim_before, '''' );
  prepare dt from @sql;
  execute dt;

  set rc = rc + row_count();

  fetch next from tabcur into tabnam;

 until done end repeat;

close tabcur;

call cdc_logit( pn, concat('Deleted a total of ', rc, ' rows from ', tc, ' rtg tables') );

delete from cdc_hourly_data where sample_time < trim_before;
set rc = row_count();

call cdc_logit( pn, concat('Exit. Deleted ', rc, ' rows from cdc_hourly_data') );


END $$

DELIMITER ;
