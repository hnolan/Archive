SET PWD=flg

SET DUMPDIR=E:\Dev\MySQL\Procs

DEL %DUMPDIR%\*.sql
mysql -p%PWD% -u root -e "call cdb_utils.dump_code()"

move %DUMPDIR%\cdb_dev.*.sql   D:\Dev\CDB\server\cdb_dev\procs
move %DUMPDIR%\cdc_rtg.*.sql   D:\Dev\CDB\client\cdc_rtg\procs
move %DUMPDIR%\cdb_utils.*.sql D:\Dev\CDB\misc\cdb_utils\procs

pause
