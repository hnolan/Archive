BEGIN

/*

This procedure produces hourly summaries from data in rtg data tables.

It assumes that the polling interval is the default of 5 mins (300 secs).

The main query uses mappings in the cdb_counters table to convert the
raw data to use more sustainable units (e.g. KBytes rather than bytes,
or KPkts rather than packets).

*/

-- Declare variables and cursors
declare pn varchar(50) default 'cdc_import';
declare rc integer default 0;
declare tc integer default 0;
declare rctot integer default 0;
declare rcout integer default 0;

declare done int default 0;
declare tabnam varchar(50);

-- Assume default duration is 5 mins (300 secs)
declare dur integer default 300;

-- Get list of data_tables from cdb_datasets
declare tabcur cursor for SELECT distinct rtg_data_table FROM cdc_datasets;
declare continue handler for not found set done = 1;

call cdc_logit( pn, concat( 'Enter (',bdt,')' ) );

/*
----------------------------------------------
 Prepare for import
 Create tempdata table and set the import_from
 field for each dataset to be one hour later than
 the latest sample in the hourly data table.
----------------------------------------------
*/

-- Update hourly stats
update cdc_datasets ds
 join cdc_hourly_stats h on ds.id = h.dsid
 set ds.import_from = h.next_hourly_sample;

-- Create temp table to accept new raw data
create temporary table tempdata (
 dsid int unsigned not null,
 dtime datetime not null,
 dval float not null
 );

/*
----------------------------------------------
 Collect raw data from multiple rtg tables
 into a single tempdata table
----------------------------------------------
*/
open tabcur;

-- Get first row from cursor
fetch next from tabcur into tabnam;

-- Update the data from each table
repeat
  set tc = tc + 1;

  set @sql = 'insert into tempdata ( dsid, dtime, dval ) ';
  set @sql = CONCAT( @sql, ' select ds.id as dsid, d.dtime, d.counter from rtg.', tabnam, ' d ' );
  set @sql = CONCAT( @sql, ' join cdc_interfaces ci on d.id = ci.rtg_iid join cdc_datasets ds on ci.id = ds.cdc_iid ' );
  set @sql = CONCAT( @sql, ' where ds.rtg_data_table = ''', tabnam, ''' and dtime >= ds.import_from' );

  -- Add endpoint condition, if supplied
  if bdt = '' then
    -- Empty param, so no condition
    set @sql = CONCAT( @sql, ';' );
   elseif length(bdt) < 3 then
    -- Short param, assume its a number of days
    set @sql = CONCAT( @sql, ' and dtime <= date_add( ds.import_from, interval ', bdt, ' day );' );
   else
    -- Longer param, assume its an explicit date
    set @sql = CONCAT( @sql, ' and dtime <= ''', bdt, ''';' );
   end if;

  prepare uht from @sql;
  execute uht;

  fetch next from tabcur into tabnam;

 until done end repeat;

close tabcur;

select count(*) from tempdata into rc;

call cdc_logit( pn, concat( 'Selected ', rc ,' raw data rows from ', tc ,' tables' ) );

/*
----------------------------------------------
 Process the temp table of raw data
----------------------------------------------
*/

-- Add an index to speed up processing
alter table tempdata add index idx1 (dsid);

/*
To prevent the query from summarising the final (potentially incomplete) hour, we
find the latest timestamp for each raw dataset, round it down to a whole hour and
only process data less than (prior to) this high water mark.
*/

-- Update cdb_datasets with raw data high water marks
update cdc_datasets ds join (
 select dsid, date_add( date(max(dtime)), interval hour(max(dtime)) hour ) as hwm
  from tempdata group by dsid
  ) td on ds.id = td.dsid
 set ds.import_before = td.hwm;

-- Insert data into the hourly table
insert into cdc_hourly_data ( sample_time, dsid, hdate, hhour, data_min, data_max, data_sum, data_count )
 select date_add( date(dtime), interval hour(dtime) hour ) as sample_time, d.dsid, date(dtime) as hdate, hour(dtime) as hhour,
  case dd.map_type when 'rate' then min(dval)/(factor * dur) when 'util' then ((min(dval)*factor/dur)/speed)*100 end,
  case dd.map_type when 'rate' then max(dval)/(factor * dur) when 'util' then ((max(dval)*factor/dur)/speed)*100 end,
  case dd.map_type when 'rate' then sum(dval)/(factor * dur) when 'util' then ((sum(dval)*factor/dur)/speed)*100 end,
  count(dval)
 from tempdata d
  inner join cdc_dataset_details dd on dd.dsid = d.dsid
 where d.dtime < dd.import_before
 group by sample_time, d.dsid;

set rc = row_count();

drop temporary table tempdata;

-- Log exit
call cdc_logit( pn, CONCAT( 'Exit. Imported ', rc, ' hourly rows' ) );

END