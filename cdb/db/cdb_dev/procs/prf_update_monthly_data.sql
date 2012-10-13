DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`prf_update_monthly_data` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prf_update_monthly_data` (
        p_year int,
        p_month int
        )
BEGIN

/*
Update monthly table from daily data
*/
-- Declare variables and cursors
declare pn varchar(50) default 'prf_update_monthly_data';
declare rc_upd integer default 0;
declare rc_ins integer default 0;
declare sd datetime;
declare ed datetime;

-- Construct dates for range selection
set sd = str_to_date(concat(p_year,'/',p_month,'/01'),'%Y/%m/%d');
set ed = date_add(sd,interval 1 month);

-- Log entry
call cdb_logit( pn, concat( 'Enter - data update - monthly ( ', p_year, ', ', p_month, ' )' ) );

-- Update existing data for given month
update prf_monthly_data md join (
-- explain select * from prf_monthly_data md join (
   select cdb_dataset_id, cdb_shift_id, min(data_min) as d_min,
           max(data_max) as d_max, sum(data_sum) as d_sum, sum(data_count) as d_count
    from dt30_daily_data
    where sample_time >= sd and sample_time < ed
    group by cdb_dataset_id, cdb_shift_id
   ) dts on md.cdb_dataset_id = dts.cdb_dataset_id and md.cdb_shift_id = dts.cdb_shift_id
  set data_min = d_min, data_max = d_max,
      data_sum = d_sum, data_count = d_count
  where sample_year = p_year and sample_month = p_month
   -- Only update entries that have additional datasets
   and d_count > data_count;

set rc_upd = row_count();

-- Insert new data for given month
insert into prf_monthly_data ( sample_year, sample_month, cdb_dataset_id, cdb_shift_id, data_min, data_max, data_sum, data_count )
 select sample_year, sample_month, cdb_dataset_id, cdb_shift_id,
    min(data_min), max(data_max), sum(data_sum), sum(data_count)
  from dt30_daily_data dt
  where sample_time >= sd and sample_time < ed and cdb_dataset_id not in (
    select cdb_dataset_id from prf_monthly_data as md
     where sample_year = p_year and sample_month = p_month and md.cdb_shift_id = dt.cdb_shift_id
    )
  group by sample_year, sample_month, cdb_dataset_id, cdb_shift_id;

set rc_ins = row_count();

-- update latest dates in cdb_datasets
if rc_ins > 0 then
  update cdb_datasets ds join (
    select cdb_dataset_id, max(str_to_date(concat(sample_year,'/',sample_month,'/01'),'%Y/%m/%d')) as latest
     from ( select distinct sample_year, sample_month, cdb_dataset_id from prf_monthly_data ) md
     group by cdb_dataset_id
    ) as t on ds.id = t.cdb_dataset_id
  set ds.dt50_latest=t.latest;
 end if;

-- report results
if rc_upd > 0 then
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted, ', rc_upd, ' rows updated' ) );
 else
    call cdb_logit( pn, concat( 'Exit - ', rc_ins, ' monthly rows inserted' ) );
 end if;

END $$

DELIMITER ;
