call cdc_refresh();
call cdc_import('');
call cdc_export('');

select dt,pn,txt from ( select * from cdc_log order by id desc limit 20 ) l order by id;
