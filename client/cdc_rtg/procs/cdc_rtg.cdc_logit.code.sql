BEGIN
  insert into cdc_log (dt,pn,txt) values (now(),pn,txt);
END