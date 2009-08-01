truncate table tempds;
load data infile 'd:/projects/cdb/cdc_rtg/export/LHC.lancsman.20090731.0916.meta' into table tempds;

truncate table tempdt;
load data infile 'd:/projects/cdb/cdc_rtg/export/LHC.lancsman.20090731.0916.data' into table tempdt;

