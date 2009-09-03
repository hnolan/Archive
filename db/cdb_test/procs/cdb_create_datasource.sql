DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`cdb_create_datasource` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_create_datasource` (
        p_prefix varchar(10),
        p_srcsrv varchar(50),
        p_srcapp varchar(50)
        )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare pn varchar(50) default 'cdb_add_datasource';
declare rc integer default 0;
declare dsrcid integer default 0;
declare tabnam varchar(50);
declare pfxid int;

call cdb_logit( pn, concat( 'Enter ( ', p_prefix, ', ', p_srcsrv, ', ', p_srcapp, ' )' ) );

-- Check for prefix
select count(*) from m00_customers where prefix = p_prefix into rc;

if rc = 1 then
  select id from m00_customers where prefix = p_prefix into pfxid;
 else
  call cdb_logit( pn, concat( 'Exit. *** Error - customer not found ***' ) );
  leave main;
 end if;

-- Check whether the datasource already exists
select count(*) from m06_datasources ds join m00_customers c on c.id = ds.cdb_customer_id
 where c.prefix = p_prefix and ds.source_server = p_srcsrv and ds.source_app = p_srcapp
 into rc;

if rc >= 1 then
  call cdb_logit( pn, concat( 'Exit. *** Error - datasource already exists ***' ) );
  leave main;
 end if;

-- Check for data table
set tabnam = concat( 'hourly_data_', lower(p_prefix) );
set @sql = concat( 'create table if not exists ', tabnam, ' like dt20_hourly_data;' );
prepare nt from @sql;
execute nt;

-- Create new datasource
set @sql = concat( 'insert into m06_datasources ( cdb_customer_id, source_server, source_app, hourly_table ) ' );
set @sql = concat( @sql, ' values ( ', pfxid, ', ''', p_srcsrv, ''', ''', p_srcapp, ''', ''', tabnam, ''' );' );
prepare nd from @sql;
execute nd;

call cdb_logit( pn, concat( 'Exit - created datasource for table ', tabnam, ' ' ) );

END main;

END $$

DELIMITER ;
