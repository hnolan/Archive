DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`get_perf_chart_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_perf_chart_data` (
 p_prefix varchar(50),
 p_seltype varchar(50),
 p_selection varchar(50),
 p_startdate datetime,
 p_enddate datetime,
 p_period int
 )
BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare done int default 0;
-- declare piv varchar(50);
-- declare pivcur cursor for select pivot from pivot;

declare sd datetime;
declare ed datetime;
declare fmt varchar(30);

declare continue handler for 1051 set done = 1;

drop table if exists TempDatasets;
drop table if exists TempData;
drop table if exists TempSeries;

-- *************** Param validation ***************

set sd = p_startdate;
set ed = p_enddate;

-- *************** Dataset Selection ***************

create temporary table TempDatasets (
  dataset_id int not null,
  prefix varchar(50) not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

if p_seltype = 'Machine' or p_seltype = 'MachineInOut' then
  -- Machine selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.cdb_dataset_id, dd.cdb_prefix, dd.cdb_counter as selection, dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_machine = p_selection;
 else
  -- Counter selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.cdb_dataset_id, dd.cdb_prefix, dd.cdb_machine as selection, dd.cdb_instance as series
    from dataset_details dd
   where dd.cdb_prefix = p_prefix and dd.cdb_counter = p_selection;
 end if;

-- select * from TempDatasets;
-- drop table TempDatasets;


-- *************** Table specific portion ***************

create temporary table TempData (
  sample_time datetime not null,
  dataset_id int not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int not null
  );

if p_period = 21 then
  set fmt = '%H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select date_add(''1900-01-01'', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, ''' ' );
  set @sql = concat( @sql, ' group by sample_hour, cdb_dataset_id;' );
  prepare tmpd from @sql;
  execute tmpd;
 elseif p_period = 20 then
  set fmt = '%Y-%m-%d %H:%i';
  set @sql = concat( 'insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )' );
  set @sql = concat( @sql, 'select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count' );
  set @sql = concat( @sql, ' from hourly_data_', lower(p_prefix), ' dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id' );
  set @sql = concat( @sql, ' where sample_time >= ''', sd, ''' and sample_time < ''', ed, '''; ' );
  prepare tmpd from @sql;
  execute tmpd;
 else
  set fmt = '%Y-%m-%d';
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from dt30_daily_data dt inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= sd and sample_time < ed and cdb_shift_id = 1;
 end if;

-- select * from TempData;

-- *************** Data Processing portion ***************

create temporary table TempSeries (
  sample_time varchar(30) not null,
  data_type varchar(20) not null,
  data_val float not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

/*
insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Min', data_min, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Max', data_max, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Cnt', data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;
*/


if p_seltype = 'MachineInOut' then
  insert into TempSeries ( sample_time, data_type, data_val, selection, series )
   select date_format(sample_time,fmt), 'Avg', IF(c.counter_subtype = 'Out', ( data_sum / data_count ) * -1 , data_sum / data_count ),
    c.counter_type, concat(ds.series,' (',c.counter_subtype,')') from TempData dt
   inner join TempDatasets ds on dt.dataset_id = ds.dataset_id
   inner join cdb_counters as c on ds.selection = c.counter_name;
 else
  insert into TempSeries ( sample_time, data_type, data_val, selection, series )
   select date_format(sample_time,fmt), 'Avg', data_sum / data_count, selection, series from TempData dt
   inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;
 end if;

drop table TempDatasets;
drop table TempData;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

END main;

END $$

DELIMITER ;
