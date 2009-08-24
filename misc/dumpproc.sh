PWD=passport
CWD=/home/huw/dev/cdb

DUMPDIR=/home/huw/dev/mysql/procs

rm -f $DUMPDIR/*.sql
mysql -p$PWD -u root -e "call cdb_utils.dump_code()"

# move $DUMPDIR/cdb_dev.*.sql   $CWD/server/cdb_dev/procs
# move $DUMPDIR/cdc_rtg.*.sql   $CWD/client/cdc_rtg/procs
# mv $DUMPDIR/cdb_utils.*.sql $CWD/misc/cdb_utils/procs

# Combine dumped fragments and store under parent DB
$CWD/misc/convproc.sh
