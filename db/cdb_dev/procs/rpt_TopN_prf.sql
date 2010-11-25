DELIMITER $$

DROP PROCEDURE IF EXISTS `cdb_dev`.`rpt_TopN_prf` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `rpt_TopN_prf` (
        p_prefix varchar(20),
        p_year   int,
        p_month  int
        )
BEGIN

create temporary table tmpTopN (
        toptype varchar(50),
        dsid integer,
        avg_all float,
        sample_count int
        );

-- Top 10 util (In)
insert into tmpTopN ( toptype, dsid, avg_all, sample_count )
 select 'Top 10 In', dt.cdb_dataset_id, data_sum/data_count as avg_all, data_count
  from prf_monthly_data dt join dataset_details dd on dt.cdb_dataset_id = dd.cdb_dataset_id
  where cdb_shift_id = 1 and cdb_counter = 'ifIn%Util'
   and cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
 order by avg_all DESC limit 10;

-- Top 10 util (Out)
insert into tmpTopN ( toptype, dsid, avg_all, sample_count )
 select 'Top 10 Out', dt.cdb_dataset_id, data_sum/data_count as avg_all, data_count
  from prf_monthly_data dt join dataset_details dd on dt.cdb_dataset_id = dd.cdb_dataset_id
  where cdb_shift_id = 1 and cdb_counter = 'ifOut%Util'
   and cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
 order by avg_all DESC limit 10;

-- Top 10 util (Out)
insert into tmpTopN ( toptype, dsid, avg_all, sample_count )
 select 'Top 10 Overall', dt.cdb_dataset_id, data_sum/data_count as avg_all, data_count
  from prf_monthly_data dt join dataset_details dd on dt.cdb_dataset_id = dd.cdb_dataset_id
  where cdb_shift_id = 1 and  ( cdb_counter = 'ifIn%Util' or cdb_counter = 'ifOut%Util' )
   and cdb_prefix = p_prefix and sample_year = p_year and sample_month = p_month
 order by avg_all DESC limit 10;

select cdb_prefix, cdb_machine, cdb_object, cdb_instance, cdb_counter, t.*
 from tmpTopN t join dataset_details dd on t.dsid = dd.cdb_dataset_id;

drop temporary table if exists tmpTopN;

END $$

DELIMITER ;
