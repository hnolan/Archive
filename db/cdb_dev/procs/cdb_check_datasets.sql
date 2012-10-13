DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`cdb_check_datasets` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_check_datasets` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

/*
This procedure expects a table called tempds to exist
with at least the following columns:

  cdc_dataset_id int(10) unsigned not null,
  cdc_machine varchar(45) not null,
  cdc_object varchar(45) not null,
  cdc_instance varchar(45) not null,
  cdc_counter varchar(45) not null

Any other columns are ignored.

*/

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_check_datasets';
declare rc integer default 0;
declare dsrcid integer default 0;

-- Check whether a unique datasource exists
select count(*) from cdb_datasources ds
 join cdb_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

-- Create datasource if one was not found
if rc = 0 then
  call cdb_create_datasource( p_prefix, p_srcsrv, p_srcapp );
  select count(*) from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into rc;
 end if;

-- Double check for valid datasource
if rc = 1 then
  select ds.id from cdb_datasources ds
   join cdb_customers c on c.id = ds.cdb_customer_id
   where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
   into dsrcid;
 else
  call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );
  call cdb_logit( pn, concat( 'Exit. *** Error - ', rc, ' datasources found ***' ) );
  leave main;
 end if;

-- Check for unmapped datasets
select count(*) from tempds tds
 where cdc_dataset_id not in (
   select cdc_dataset_id from cdb_dataset_map where cdb_datasource_id = dsrcid
   )
 into rc;

-- Exit routine silently, if no new datasets were found
if rc = 0 then
  leave main;
 end if;

-- Log valid entry
call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- Create input table for cdb_create_datasets
create temporary table if not exists temp_datasets (
  cdc_dataset_id int unsigned not null,
  cdc_prefix varchar(50) NOT NULL,
  cdc_machine varchar(50) NOT NULL,
  cdc_object varchar(50) NOT NULL,
  cdc_instance varchar(50) NOT NULL,
  cdc_counter varchar(50) NOT NULL,
  cdc_path varchar(512) NOT NULL
  ) DEFAULT CHARSET=utf8
  select cdc_dataset_id, p_prefix as cdc_prefix, cdc_machine, cdc_object, cdc_instance, cdc_counter,
	convert( concat( '\\\\', cdc_machine, '\\', cdc_object, '(', cdc_instance, ')\\', cdc_counter ) using utf8 ) AS cdc_path
 from tempds tds where cdc_dataset_id not in (
  select cdc_dataset_id from cdb_dataset_map where cdb_datasource_id = dsrcid
  );

-- select * from temp_datasets;
call cdb_create_datasets();

-- Update Map table with new dataset mappings
insert into cdb_dataset_map ( cdb_datasource_id, cdc_dataset_id, cdb_dataset_id )
  select dsrcid, t.cdc_dataset_id, d.id
    from temp_datasets t
     join cdb_datasets d on t.cdc_prefix = d.cdb_prefix and t.cdc_path = d.cdb_path;

set rc = row_count();

drop temporary table temp_datasets;

-- Log results on exit
call cdb_logit( pn, concat( 'Exit - ', rc, ' new dataset mappings created' ) );

END main;

END $$

DELIMITER ;
