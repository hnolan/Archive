BEGIN

declare pn varchar(50) default 'xpv';
declare rc int default 0;

-- Declare variables and cursors
declare done int default 0;

declare dumpdir varchar(250);
declare dumpfil varchar(250);
declare procname varchar(50);
declare viewname varchar(50);

declare proccur cursor for select ROUTINE_NAME from information_schema.ROUTINES where ROUTINE_SCHEMA = dumpdb;
declare viewcur cursor for select TABLE_NAME from information_schema.VIEWS where TABLE_SCHEMA = dumpdb;
declare continue handler for not found set done = 1;

set dumpdir = concat('d:/projects/cdb/', dumpdb, '/dumps');
open proccur;

fetch next from proccur into procname;

repeat

  set dumpfil = concat( dumpdir, '/P.', procname, '.', date_format(now(),'%Y%m%d.%H%i'), '.txt' );

  set @sql = 'SELECT ROUTINE_DEFINITION FROM information_schema.ROUTINES ';
  set @sql = concat( @sql, ' where ROUTINE_SCHEMA = ''', dumpdb, ''' and ROUTINE_NAME = ''', procname, ''' ' );
  set @sql = concat( @sql, '  into dumpfile ''', dumpfil, ''' ' );

  prepare ct from @sql;
  execute ct;

  fetch next from proccur into procname;
 until done end repeat;

 close proccur;

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

END