DELIMITER $$

DROP PROCEDURE IF EXISTS `cdc_rtg`.`rtg_refresh` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `rtg_refresh` ()
BEGIN

declare pn varchar(50) default 'rtg_refresh';
declare rc int default 0;

-- Declare variables and cursors
declare done int default 0;
declare tc int default 0;
declare rtg_rid int;
declare cdc_mib varchar(50);
declare badtab int default 0;
declare tabnam varchar(50);

-- The cursor is a cross join of all routers with all counters
declare tabcur cursor for select distinct rid, mib_item from rtg.router join cdc_counters;
declare continue handler for not found set done = 1;
-- Handle non-existant table
declare continue handler for 1146 set badtab = 1;

call cdc_logit( pn, concat( 'Enter' ) );

/*
--------------------------------------
 Refresh the rtg_data_stats
--------------------------------------
*/

-- Clear the stats table
truncate table rtg_data_stats;

-- Collect stats from each rawdata table
open tabcur;

fetch next from tabcur into rtg_rid, cdc_mib;

repeat

  set tc = tc + 1;

  -- Enter stats from one data table into rtg_data_stats table
  set tabnam = concat( cdc_mib, '_', rtg_rid );
  set @sql = 'insert into rtg_data_stats ( rtg_rid, rtg_iid, rtg_mib_item, rtg_data_table, ';
  set @sql = CONCAT( @sql, ' rtg_first_sample, rtg_last_sample, rtg_sample_count ) ' );
  set @sql = CONCAT( @sql, 'select ', rtg_rid, ', id, ''', cdc_mib, ''', ''', tabnam, ''',  min(dtime), max(dtime), count(dtime) ' );
  set @sql = CONCAT( @sql, ' from rtg.', tabnam, ' group by id;' );

  prepare ct from @sql;

  if badtab = 0 then
    execute ct;
    set rc = row_count();
   else
    call cdc_logit(pn,CONCAT( 'Table "', tabnam, '" does not exist' ));
    set badtab = 0;
   end if;

  fetch next from tabcur into rtg_rid, cdc_mib;

 until done end repeat;

close tabcur;

call cdc_logit( pn, concat( 'Exit. Refreshed stats from ', tc, ' rtg tables' ) );

END $$

DELIMITER ;
