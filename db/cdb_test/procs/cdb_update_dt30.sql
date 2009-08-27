DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_test`.`cdb_update_dt30` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `cdb_update_dt30` ()
BEGIN
main: BEGIN

declare pn varchar(50) default 'cdb_update_dt30';
declare rc integer default 0;
declare pfx varchar(10);
declare rcnew integer default 0;
declare done int default 0;
declare tabnam varchar(50);
declare tabcur cursor for select distinct prefix from m00_customers m0 join m06_datasources m6 on m0.id = m6.cdb_customer_id;
declare continue handler for not found set done = 1;
call cdb_logit( pn, concat( 'Enter - data update - daily' ) );
create temporary table temp_data (
  sample_time datetime NOT NULL,
  cdb_dataset_id int(10) unsigned NOT NULL,
  sample_date datetime NOT NULL,
  sample_hour int(10) unsigned NOT NULL,
  data_min float NOT NULL,
  data_max float NOT NULL,
  data_sum float NOT NULL,
  data_count int(10) unsigned NOT NULL,
  sample_dow int
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
open tabcur;
fetch next from tabcur into pfx;
repeat
  set @sql = 'insert into temp_data ';
  set @sql = CONCAT( @sql, 'select dt.*, dayofweek(dt.sample_date) as sample_dow from hourly_data_', pfx, ' dt ' );
  set @sql = CONCAT( @sql, '   inner join m05_datasets d on dt.cdb_dataset_id = d.id ' );
  set @sql = CONCAT( @sql, '  where dt.sample_date > d.dt30_latest and ' );
  set @sql = CONCAT( @sql, '        dt.sample_time < date(d.dt20_latest); ' );
  prepare itd from @sql;
  execute itd;
  set rc = row_count();
  call cdb_logit( pn, concat( 'Found ', rc, ' hourly data rows for prefix ', pfx ) );
  fetch next from tabcur into pfx;
 until done end repeat;
close tabcur;
select count(*) from temp_data into rc;
if rc <= 0 then
  drop temporary table temp_data;
  call cdb_logit( pn, concat( 'Exit - no new data found' ) );
  leave main;
 end if;
insert into dt30_daily_data ( sample_time, cdb_dataset_id, cdb_shift_id, data_min, data_max,
	 data_sum, data_count, sample_week, sample_month, sample_year )
 select dt.sample_date, dt.cdb_dataset_id, 1 as shift_id,
    min(dt.data_min) as data_min, max(dt.data_max) as data_max,
    sum(dt.data_sum) as data_sum, sum(dt.data_count) as data_count,
    week(sample_date,0), month(sample_date), year(sample_date)
  from temp_data as dt
  group by dt.sample_date, dt.cdb_dataset_id;
set rc = row_count();
set rcnew = rcnew + rc;
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' daily data rows inserted (shift 1)' ) );
 end if;
insert into dt30_daily_data ( sample_time, cdb_dataset_id, cdb_shift_id, data_min, data_max,
	 data_sum, data_count, sample_week, sample_month, sample_year )
 select dt.sample_date, dt.cdb_dataset_id, 2 as shift_id,
    min(dt.data_min) as data_min, max(dt.data_max) as data_max,
    sum(dt.data_sum) as data_sum, sum(dt.data_count) as data_count,
    week(sample_date,0), month(sample_date), year(sample_date)
  from temp_data as dt
   where dt.sample_hour >= 7 and dt.sample_hour <= 18 and dt.sample_dow >=2 and dt.sample_dow <=6
  group by dt.sample_date, dt.cdb_dataset_id;
set rc = row_count();
set rcnew = rcnew + rc;
if rc > 0 then
  call cdb_logit( pn, concat( rc, ' daily data rows inserted (shift 2)' ) );
 end if;
if rcnew > 0 then
  update m05_datasets ds join (
   select cdb_dataset_id, max(sample_time) as 'latest' from dt30_daily_data group by cdb_dataset_id
   ) as t on ds.id = t.cdb_dataset_id
  set ds.dt30_latest=t.latest;
 end if;
call cdb_logit( pn, concat( 'Exit - ', rcnew, ' daily data rows inserted' ) );
drop table temp_data;
END main;
END $$

DELIMITER ;
