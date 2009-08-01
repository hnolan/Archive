BEGIN
  select * from cdc_rtg.cdc_log order by id desc limit 100;
END