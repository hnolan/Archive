DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`cdb_import_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_import_data` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

main: BEGIN
declare pn varchar(50) default 'cdb_import_data';
declare rc integer default 0;
declare dsrcid integer default 0;
declare hourtab varchar(50) default 'dt20_hourly_data';
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
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
set @sql = concat( 'insert into ', hourtab, ' ' );
set @sql = concat( @sql, ' select date_add(dt.sample_date, interval dt.sample_hour hour ), dm.cdb_dataset_id, ' );
set @sql = concat( @sql, '   dt.sample_date, dt.sample_hour, data_min, data_max, data_sum, data_count ' );
set @sql = concat( @sql, '  from tempdt dt join m07_dataset_map dm ' );
set @sql = concat( @sql, '   on dt.cdc_dataset_id = dm.cdc_dataset_id where dm.cdb_datasource_id = ', dsrcid, ' ' );
set @sql = concat( @sql, ' and not exists ( select * from ', hourtab, ' ht ' );
set @sql = concat( @sql, '  where ht.sample_time = date_add(dt.sample_date, interval dt.sample_hour hour ) and ht.cdb_dataset_id = dm.cdb_dataset_id )' );
prepare imp from @sql;
execute imp;
set rc = row_count();
if rc = 0 then
  call cdb_logit( pn, concat( 'Exit. No new data found' ) );
  leave main;
 end if;
set @sql = concat( 'update m05_datasets ds join ( ' );
set @sql = concat( @sql, '  select cdb_dataset_id, max(sample_time) as ''latest'' from ', hourtab, ' group by cdb_dataset_id ' );
set @sql = concat( @sql, '   ) as t on ds.id = t.cdb_dataset_id set ds.dt20_latest=t.latest; ' );
prepare upd from @sql;
execute upd;
call cdb_logit( pn, concat( 'Exit. Inserted ', rc, ' data rows into ', hourtab ) );
END;
END $$

DELIMITER ;
