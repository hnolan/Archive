DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`cdb_import_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_import_data` (
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
declare pn varchar(50) default 'cdb_import_data';
declare rc integer default 0;
declare dsrcid integer default 0;
declare hourtab varchar(50) default 'dt20_hourly_data';
declare sd date;
declare ed date;

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
   into dsrcid, hourtab;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- Populate new columns
update tempdt dt join m07_dataset_map dm
 on dt.cdc_dataset_id = dm.cdc_dataset_id and dm.cdb_datasource_id = dsrcid
  set dt.cdb_dataset_id = dm.cdb_dataset_id,
      dt.sample_time = date_add(dt.sample_date, interval dt.sample_hour hour );

-- Delete duplicate data or unknown datasets
delete from tempdt where cdb_dataset_id = 0;

set @sql = concat( 'delete from tempdt dt using tempdt dt join ', hourtab, ' ht ' );
set @sql = concat( @sql, '  on dt.cdb_dataset_id = ht.cdb_dataset_id and ht.sample_time = dt.sample_time' );

prepare deldup from @sql;
execute deldup;

set rc = row_count();
if rc > 0 then
  call cdb_logit( pn, concat( 'Discarded ', rc, ' duplicate rows' ) );
 end if;

-- Get bounds for date range to limit search of existing table data
select min(sample_date), max(date_add( sample_date, interval 1 day )) from tempdt into sd, ed;

-- ---------------------------
-- Import data
-- ---------------------------

-- Insert new mapped data
set @sql = concat( 'insert into ', hourtab, ' ' );
set @sql = concat( @sql, ' select sample_time, cdb_dataset_id, sample_date, sample_hour, ' );
set @sql = concat( @sql, '   data_min, data_max, data_sum, data_count from tempdt' );

prepare insnew from @sql;
execute insnew;

set rc = row_count();

-- Exit routine if no new data was found
if rc = 0 then
  call cdb_logit( pn, concat( 'Exit. No new data found' ) );
  select concat( 'cdb_import_data: No new data found'  ) as msg;
  leave main;
 end if;

-- update latest times in m05_datasets
set @sql = concat( 'update m05_datasets ds join ( ' );
set @sql = concat( @sql, '  select cdb_dataset_id, max(sample_time) as ''latest'' from ', hourtab, ' ' );
set @sql = concat( @sql, '   where sample_time between ''', sd, ''' and ''', ed, ''' group by cdb_dataset_id ' );
set @sql = concat( @sql, '   ) as t on ds.id = t.cdb_dataset_id set ds.dt20_latest=t.latest; ' );

prepare upd from @sql;
execute upd;

-- Log valid entry
call cdb_logit( pn, concat( 'Exit. Inserted ', rc, ' data rows into ', hourtab ) );

select concat( 'cdb_import_data: Inserted ', rc, ' data rows into ', hourtab  ) as msg;

-- End of main block
END;

END $$

DELIMITER ;
