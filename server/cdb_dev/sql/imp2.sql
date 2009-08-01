create temporary table tempds (
  cdc_dataset_id int(10) unsigned not null,
  cdc_machine varchar(45) not null,
  cdc_object varchar(45) not null,
  cdc_instance varchar(45) not null,
  cdc_counter varchar(45) not null,
  speed bigint(20) unsigned not null,
  description varchar(250) not null
) engine=InnoDB default charset=latin1;

create temporary table tempdt (
  sample_date date not null,
  sample_hour int(10) unsigned not null,
  cdc_dataset_id int(10) unsigned not null,
  data_min float not null,
  data_max float not null,
  data_sum float not null,
  data_count int(10) unsigned not null
) engine=MyISAM default charset=latin1;

load data infile 'd:/projects/cdb/cdc_rtg/export/LHC.lancsman.20090731.0916.meta' into table tempds;
load data infile 'd:/projects/cdb/cdc_rtg/export/LHC.lancsman.20090731.0916.data' into table tempdt;

call cdb_check_datasets( 'LAHC', 'lancsman', 'rtg2' );

drop temporary table tempds;
drop temporary table tempdt;

select dt,pn,txt from ( select * from cdb_log order by id desc limit 20 ) l order by id;
