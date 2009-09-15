DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`nag_import_events` $$
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
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc = 1 then
  select ds.id, ds.hourly_table from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid, eventtab;
 else
  set msg = concat( 'Exit. *** Error - ', rc, ' datasources found ***' );
  call cdb_logit( pn, msg );
  select msg;
  leave main;
 end if;

-- ---------------------------
-- Obtain instance lookup table
-- ---------------------------
create temporary table temp_instances like template_ev_inst;
call nag_check_instances( p_prefix, p_srcsrv, p_srcapp );

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new mapped data
-- ( We only want to store host/service alert records )
set @sql = concat( 'insert into ', eventtab, ' ( cdb_instance_id, cdb_datasource_id, ev_state, hard_soft, start_time, end_time, duration, next_state, message )' );
set @sql = concat( @sql, ' select ti.i_id, ', dsrcid, ', te.ev_state, te.hard_soft, te.start_time, te.end_time, te.duration, te.next_state, te.message ' );
set @sql = concat( @sql, '  from tempev te join temp_instances ti on te.host = ti.cdb_machine and te.service = ti.cdb_instance ' );
set @sql = concat( @sql, '   and ti.cdb_object = IF( reason = ''SERVICE ALERT'',  _latin1 ''NagiosServiceEvent'', _latin1 ''NagiosHostEvent'' ) ' );
set @sql = concat( @sql, '  where te.reason = ''SERVICE ALERT'' or te.reason = ''HOST ALERT'' order by start_time ' );

prepare imp from @sql;
execute imp;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  set msg = concat( 'Exit. No new events found' );
  call cdb_logit( pn, msg );
  select msg;
  leave main;
 end if;

-- ---------------------------------------
-- Update instance table with latest times
-- ---------------------------------------
update m03_instances i join temp_instances ti on ti.i_id = i.id
 set i.latest_event = ti.latest_event;

-- Tidy up
drop temporary table temp_instances;

-- Log valid entry
set msg = concat( 'Exit. Inserted ', rc, ' event rows into ', eventtab );
call cdb_logit( pn, msg );
select msg;

-- End of main block
END;

END $$

DELIMITER ;
