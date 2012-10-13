DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`cdb_import_test` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_import_test` (
        p_prefix varchar(10),
        p_srcsrv varchar(45),
        p_srcapp varchar(45)
        )
BEGIN

declare hourtab varchar(50) default 'hourly_data_sthc';

-- update latest times in m05_datasets
set @sql = concat( 'update m05_datasets ds join ( ' );
set @sql = concat( @sql, '  select cdb_dataset_id, max(sample_time) as ''latest'' from ', hourtab, ' group by cdb_dataset_id ' );
set @sql = concat( @sql, '   ) as t on ds.id = t.cdb_dataset_id set ds.dt20_latest=t.latest; ' );

prepare upd from @sql;
execute upd;

if p_prefix = 'RS' then
  select * from m06_datasources;
 end if;

select * from m06_datasources;

END $$

DELIMITER ;
