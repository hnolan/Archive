create temporary table tempds like template_ds;
create temporary table tempdt like template_dt;

load data infile 'd:/projects/cdb/rtg_cdb/export/LHC.lancsman.20090729.1239.meta' into table tempds;
load data infile 'd:/projects/cdb/rtg_cdb/export/LHC.lancsman.20090729.1239.data' into table tempdt;

call cdb_check_datasets( 'LAHC', 'lancsman', 'rtg' );
call cdb_import_data( 'LAHC', 'lancsman', 'rtg' );

drop temporary table tempds;
drop temporary table tempdt;

select dt,pn,txt from ( select * from cdb_log order by id desc limit 20 ) l order by id;
