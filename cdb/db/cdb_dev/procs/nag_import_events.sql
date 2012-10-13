DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`nag_import_events` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nag_import_events` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*
This procedure expects a table called tempdt to exist
with at least the following columns:

  sample_date date not null,
  sample_hour int(10) unsigned not null,
  cdc_dataset_id int(10) unsigned not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int(10) unsigned not null

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'nag_import_events';
declare rc integer default 0;
declare dsrcid integer default 0;
declare eventtab varchar(50) default 'dt15_nagios_events';
declare msg varchar(250) default '';

-- log entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- ---------------------------
-- Validate datasource
-- ---------------------------

-- Check that a unique datasource exists
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.target_table from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, eventtab;
 else
  set msg = concat( '*** Error - ', rc, ' datasources found ***' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- ---------------------------
-- Obtain instance lookup table
-- ---------------------------
call nag_check_instances( p_prefix, p_srcsrv, p_srcapp );

-- ---------------------------
-- Discard duplicate data
-- ---------------------------

-- Discard events that already exist
set @sql = concat( 'delete tempev t from tempev t join ', eventtab, ' e '  );
set @sql = concat( @sql, '   on t.start_time = e.start_time and t.i_id = e.cdb_instance_id ' );

prepare dup from @sql;
execute dup;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  set msg = concat( 'Discarded ', rc, ' duplicate events' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;


-- -------------------------------
-- Process CURRENT_x_STATE events
-- -------------------------------

-- Discard 'current' events if they already exist in the same state
set @sql = concat( 'delete tempev t from tempev t join ', eventtab, ' e on t.i_id = e.cdb_instance_id ' );
set @sql = concat( @sql, '  and t.ev_state = e.ev_state ' ); -- and t.hard_soft = e.hard_soft
set @sql = concat( @sql, ' where t.entry_type in ( ''CURRENT HOST STATE'', ''CURRENT SERVICE STATE'' ) and e.end_time is null ' );
set @sql = concat( @sql, '   and t.start_time >= e.start_time and t.end_time is null ' );

prepare dup from @sql;
execute dup;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  set msg = concat( 'Discarded ', rc, ' open but unchanged current state entries' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;

-- Close any open events that match current states
set @sql = concat( 'update ', eventtab, ' e join tempev t on t.i_id = e.cdb_instance_id ' );
set @sql = concat( @sql, '  and t.ev_state = e.ev_state ' ); --  and t.hard_soft = e.hard_soft
set @sql = concat( @sql, ' set t.svc_id = 0, e.end_time = t.end_time, e.next_state = t.next_state, ' );
set @sql = concat( @sql, '   e.duration = timestampdiff(SECOND,e.start_time,t.end_time) ' );
set @sql = concat( @sql, ' where t.entry_type in ( ''CURRENT HOST STATE'', ''CURRENT SERVICE STATE'' ) and e.end_time is null ' );
set @sql = concat( @sql, '   and t.start_time >= e.start_time and t.end_time is not null ' );

prepare upd from @sql;
execute upd;

set rc = row_count();

-- Exit routine if no new data was found
if rc > 0 then
  -- rc is twice the no of events closed since an update was made to both tables
  set rc = rc / 2;
  set msg = concat( 'Closed ', rc, ' existing open events from current state entries' );
  call cdb_logit( pn, concat( msg ) );
  select msg;
 end if;

-- Discard the current state events that closed existing events
delete from tempev where svc_id = 0;

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new event data
set @sql = concat( 'insert into ', eventtab, ' (start_time, cdb_instance_id, cdb_datasource_id, ' );
set @sql = concat( @sql, '  end_time, duration, ev_state, hard_soft, next_state, entry_type, message) ' );
set @sql = concat( @sql, ' select start_time, i_id, ', dsrcid, ', end_time, duration, ev_state, ' );
set @sql = concat( @sql, '   hard_soft, next_state, entry_type, message  from tempev' );

prepare imp from @sql;
execute imp;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  set msg = concat( 'No new events found' );
  call cdb_logit( pn, concat( 'Exit. ', msg ) );
  select msg;
  leave main;
 end if;

-- Log valid entry
set msg = concat( 'Inserted ', rc, ' event rows into ', eventtab );
call cdb_logit( pn, concat( 'Exit. ', msg ) );

-- Return a resultset consisting of the exit message
select msg;

-- End of main block
END;

END $$

DELIMITER ;
