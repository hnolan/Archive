BEGIN

-- Additional block to allow early exit from sproc
main: BEGIN

-- Declare variables and cursors
declare done int default 0;
-- declare piv varchar(50);
-- declare pivcur cursor for select pivot from pivot;
declare continue handler for 1051 set done = 1;

drop table if exists TempDatasets;
drop table if exists TempData;
drop table if exists TempSeries;

-- *************** Param validation ***************

set @st = p_startdate;
set @et = p_enddate;
-- set @st = '2009-04-06';
-- set @et = '2009-04-07';

-- *************** Dataset Selection ***************

create temporary table TempDatasets (
  dataset_id int not null,
  prefix varchar(50) not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

if p_seltype = 'Machine' then
  -- Machine selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.dataset_id, dd.prefix, dd.counter as selection, dd.instance as series
    from dataset_details dd
   where dd.prefix = p_prefix and dd.machine = p_selection;
 else
  -- Counter selected
  insert into TempDatasets ( dataset_id, prefix, selection, series )
   select dd.dataset_id, dd.prefix, dd.machine as selection, dd.instance as series
    from dataset_details dd
   where dd.prefix = p_prefix and dd.counter = p_selection;
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

  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select date_add('1900-01-01', interval sample_hour hour), cdb_dataset_id, min(data_min), max(data_max), sum(data_sum), sum(data_count)
   from hourly_data_sthc dt
    inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= @st and sample_time < @et
   group by sample_hour, cdb_dataset_id;
 else
  insert into TempData ( sample_time, dataset_id, data_min, data_max, data_sum, data_count )
  select sample_time, cdb_dataset_id, data_min, data_max, data_sum, data_count
   from hourly_data_sthc dt
    inner join TempDatasets ds on dt.cdb_dataset_id = ds.dataset_id
   where sample_time >= @st and sample_time < @et;
 end if;

-- select * from TempData;

-- *************** Data Processing portion ***************

create temporary table TempSeries (
  sample_time datetime not null,
  data_type varchar(20) not null,
  data_val float not null,
  selection varchar(50) not null,
  series varchar(250) not null
  );

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Min', data_min, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Max', data_max, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Avg', data_sum / data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

insert into TempSeries ( sample_time, data_type, data_val, selection, series )
 select sample_time, 'Cnt', data_count, selection, series from TempData dt
 inner join TempDatasets ds on dt.dataset_id = ds.dataset_id;

drop table TempDatasets;
drop table TempData;

select count(*) from TempSeries into @rc;

-- Exit here if no data was found
if @rc <= 0 then
  drop table TempSeries;
  leave main;
 end if;

select selection, series, data_type, sample_time, data_val from TempSeries
 order by selection, series, data_type, sample_time;

drop table TempSeries;

END main;

END