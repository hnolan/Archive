DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`cdb_check_datasets` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_check_datasets` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

main: BEGIN
declare pn varchar(50) default 'cdb_check_datasets';
declare rc integer default 0;
declare dsrcid integer default 0;
select count(*) from m06_datasources ds
 join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;
if rc = 1 then
  select ds.id from m06_datasources ds
   join m00_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;
select count(*) from tempds tds
 where cdc_dataset_id not in ( 
   select cdc_dataset_id from m07_dataset_map where cdb_datasource_id = dsrcid 
   )
 into rc;
if rc = 0 then
  leave main;
 end if;
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
create temporary table if not exists temp_datasets (
  cdc_dataset_id int unsigned not null,
  cdc_prefix varchar(50) NOT NULL,
  cdc_machine varchar(50) NOT NULL,
  cdc_object varchar(50) NOT NULL,
  cdc_instance varchar(50) NOT NULL,
  cdc_counter varchar(50) NOT NULL,
  cdc_path varchar(512) NOT NULL
  ) DEFAULT CHARSET=latin1
  select cdc_dataset_id, p_prefix as cdc_prefix, cdc_machine, cdc_object, cdc_instance, cdc_counter,
	convert( concat( '\\\\', cdc_machine, '\\', cdc_object, '(', cdc_instance, ')\\', cdc_counter ) using latin1 ) AS cdc_path
 from tempds tds where cdc_dataset_id not in (
  select cdc_dataset_id from m07_dataset_map where cdb_datasource_id = dsrcid
  );
call cdb_create_datasets();
insert into m07_dataset_map ( cdb_datasource_id, cdc_dataset_id, cdb_dataset_id )
  select dsrcid, t.cdc_dataset_id, d.id
    from temp_datasets t
     join m05_datasets d on t.cdc_prefix = d.cdb_prefix and t.cdc_path = d.cdb_path;
set rc = row_count();
drop temporary table temp_datasets;
call cdb_logit( pn, concat( 'Exit - ', rc, ' new dataset mappings created' ) );
END main;
END $$

DELIMITER ;
