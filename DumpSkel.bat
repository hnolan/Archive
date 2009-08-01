SET PWD=flg

REM ---------------------------------------------------

SET DB=cdb_dev
SET DUMPFIL=D:\Dev\CDB\server\%DB%\sql\%DB%.skel.sql

mysqldump -p%PWD% -u root %DB% --no-data --routines >%DUMPFIL%
mysqldump -p%PWD% -u root %DB% m00_customers m06_datasources >>%DUMPFIL%

REM ---------------------------------------------------

SET DB=cdc_rtg
SET DUMPFIL=D:\Dev\CDB\client\%DB%\sql\%DB%.skel.sql

mysqldump -p%PWD% -u root %DB% --no-data --routines >%DUMPFIL%
mysqldump -p%PWD% -u root %DB% cdc_counters        >>%DUMPFIL%

REM ---------------------------------------------------

SET DB=cdb_utils
SET DUMPFIL=D:\Dev\CDB\misc\%DB%\sql\%DB%.skel.sql

mysqldump -p%PWD% -u root %DB% --no-data --routines >%DUMPFIL%

pause
