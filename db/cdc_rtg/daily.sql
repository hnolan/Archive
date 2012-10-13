call cdc_refresh();
call cdc_import('',0);
call cdc_export('',0);

select dt,pn,txt from ( select * from cdc_log order by id desc limit 20 ) l order by id;
