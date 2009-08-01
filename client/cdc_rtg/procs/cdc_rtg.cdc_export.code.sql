BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdc_export';
declare rc integer default 0;
declare rc2 integer default 0;

declare bt datetime;

-- declare prefix varchar(10) default 'LHC';
-- declare hostnam varchar(50) default 'lancsman';
-- declare outdir varchar(250) default 'd:/projects/cdb/export';

declare datafil varchar(250);
declare metafil varchar(250);

call cdc_logit( pn, concat( 'Enter (',bdt,')' ) );

set datafil = concat(outdir,'/', prefix, '.', hostnam, '.',date_format(now(),'%Y%m%d.%H%i'),'.data');
set metafil = concat(outdir,'/', prefix, '.', hostnam, '.',date_format(now(),'%Y%m%d.%H%i'),'.meta');

-- Set the upper date limit to now, or the value passed in, if present
if bdt = '' then
   set bt = now();
 else
   set bt = cast( bdt as datetime );
 end if;

-- ------------------------
--  Select data for export
-- ------------------------

-- Get all unexported rows (up to requested limit)
truncate table cdc_export_data;

insert into cdc_export_data
 select dt.hdate, dt.hhour, dt.dsid, dt.data_min, dt.data_max, dt.data_sum, dt.data_count
  from cdc_hourly_data dt join cdc_datasets ds on dt.dsid = ds.id
  where dt.sample_time >= ds.export_from and dt.sample_time < bt;

set rc = row_count();

-- ----------------------
--  Export datasets
-- ----------------------

if rc > 0 then
  set @sql = 'select dsid, cdc_machine, cdc_object, cdc_instance, cdc_counter, speed, description ';
  set @sql = concat( @sql, ' from cdc_dataset_details dd where dd.dsid in ( select dsid from cdc_export_data ) ' );
  set @sql = concat( @sql, '  into outfile ''', metafil, ''' ' );
  prepare ed from @sql;
  execute ed;
  select count(distinct dsid) from cdc_export_data into rc2;
  call cdc_logit( pn, CONCAT( 'Exported ', rc2, ' datasets to ', metafil ) );
 end if;

-- ----------------------
--  Export data
-- ----------------------

if rc > 0 then

  set @sql = concat( 'select * from cdc_export_data into outfile ''', datafil, ''' ' );
  prepare ed from @sql;
  execute ed;

  -- Update the export timestamps in cdb_datasets
  update cdc_datasets ds join (
    select dsid, max(date_add( sample_date, interval (sample_hour) hour)) as hwm
     from cdc_export_data group by dsid
     ) hw on ds.id = hw.dsid
      set ds.export_from = hw.hwm + interval 1 hour;

  call cdc_logit( pn, CONCAT( 'Exit. Exported ', rc, ' hourly rows to ', datafil ) );
 else
  call cdc_logit( pn, CONCAT( 'Exit. No new data to export' ) );
 end if;

END