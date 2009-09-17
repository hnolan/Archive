DELIMITER $$

DROP PROCEDURE IF EXISTS `cdc_rtg`.`cdc_export` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdc_export` (
        export_upto varchar(50),
        days_before int
        )
BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdc_export';

declare sd datetime;
declare ed datetime;

declare custpfx varchar(10);
declare hostnam varchar(50);
declare filedat varchar(30);
declare outdir  varchar(250);

declare datafil varchar(250);
declare metafil varchar(250);

declare rc integer default 0;
declare rc2 integer default 0;

-- Derive a start date (sd) and end date (ed) from the parameters passed in.
-- This allows the hourly data selection query to limit the source table to a
-- specific date range and so makes the query much more efficient when the
-- source table is large.

if export_upto = '' then
  set ed = now();
 else
  set ed = cast(export_upto as datetime);
 end if;

if days_before <= 0 then
  set sd = date_sub( ed, interval 14 day );
 else
  set sd = date_sub( ed, interval days_before day );
 end if;

-- Log entry
call cdc_logit( pn, concat( 'Enter (',export_upto,', ',days_before,') [ From ', sd, ' to ', ed, ' ]' ) );

-- Get data from config table
select prefix, hostname, export_dir from cdc_config into custpfx, hostnam, outdir;

-- Initialise filenames
set filedat = date_format(now(),'%Y%m%d.%H%i%s');
set datafil = concat(outdir,'/', custpfx, '.', hostnam, '.rtg.', filedat, '.data');
set metafil = concat(outdir,'/', custpfx, '.', hostnam, '.rtg.', filedat, '.meta');

-- ------------------------
--  Select data for export
-- ------------------------

-- Get all unexported rows (up to requested limit)
truncate table cdc_export_data;

insert into cdc_export_data
 select dt.hdate, dt.hhour, dt.dsid, dt.data_min, dt.data_max, dt.data_sum, dt.data_count
  from cdc_hourly_data dt join cdc_datasets ds on dt.dsid = ds.id
  where dt.sample_time between sd and ed and dt.sample_time >= ds.export_from;

set rc = row_count();
call cdc_logit( pn, CONCAT( 'Inserted ', rc, ' datasets into cdc_export_data' ) );

-- ----------------------
--  Export datasets
-- ----------------------

if rc > 0 then
  set @sql = 'select dsid, cdc_machine, cdc_object, cdc_instance, cdc_counter, speed, description ';
  set @sql = concat( @sql, ' from cdc_dataset_details dd where dd.dsid in ( select dsid from cdc_export_data ) ' );
  set @sql = concat( @sql, '  into outfile ''', metafil, ''' ' );
  prepare exp from @sql;
  execute exp;
  select count(distinct dsid) from cdc_export_data into rc2;
  call cdc_logit( pn, CONCAT( 'Exported ', rc2, ' datasets to ', metafil ) );
 end if;

-- ----------------------
--  Export data
-- ----------------------

if rc > 0 then

  set @sql = concat( 'select * from cdc_export_data into outfile ''', datafil, ''' ' );
  prepare exp from @sql;
  execute exp;

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

END $$

DELIMITER ;
