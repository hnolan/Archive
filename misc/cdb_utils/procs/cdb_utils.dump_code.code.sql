BEGIN

declare pn varchar(50) default 'dump_code';
declare rc int default 0;

-- Declare variables and cursors
declare done int default 0;

-- declare dumpdir varchar(250);
declare dumpdat varchar(20);
declare dumpdb varchar(50);
declare dumpdir varchar(50);
declare dumpfil varchar(250);
declare dumpfil2 varchar(250);
declare procname varchar(50);
declare viewname varchar(50);

declare proccur cursor for select db, name from mysql.proc;
-- declare viewcur cursor for select TABLE_NAME from information_schema.VIEWS where TABLE_SCHEMA = dumpdb;
declare continue handler for not found set done = 1;
declare continue handler for 1086 set done = 1;        -- Dumpfile already exists

set dumpdir = 'E:/Dev/MySQL/Procs';
set dumpdat = date_format(now(),'%Y%m%d.%H%i');

open proccur;

fetch next from proccur into dumpdb, procname;

repeat

  set dumpfil = concat( dumpdir, '/', dumpdb, '.', procname, '.code.sql' );
  set @sql = 'select body from mysql.proc ';
  set @sql = concat( @sql, ' where db = ''', dumpdb, ''' and name = ''', procname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil, ''' ' );
  prepare ct from @sql;
  execute ct;

  set dumpfil2 = concat( dumpdir, '/', dumpdb, '.', procname, '.param.sql' );
  set @sql = 'select param_list from mysql.proc ';
  set @sql = concat( @sql, ' where db = ''', dumpdb, ''' and name = ''', procname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil2, ''' ' );
  prepare ct from @sql;
  execute ct;

  fetch next from proccur into dumpdb, procname;

 until done end repeat;

 close proccur;

 /*
set done=0;
open viewcur;

fetch next from viewcur into viewname;

repeat

  set dumpfil = concat( dumpdir, '/V.', viewname, '.', date_format(now(),'%Y%m%d.%H%i'), '.txt' );

  set @sql = 'SELECT VIEW_DEFINITION FROM information_schema.VIEWS ';
  set @sql = concat( @sql, ' where TABLE_SCHEMA = ''', dumpdb, ''' and TABLE_NAME = ''', viewname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil, ''' ' );

  prepare ct from @sql;
  execute ct;

  fetch next from viewcur into viewname;
 until done end repeat;

 close viewcur;
*/
END