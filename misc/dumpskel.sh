PWD=passport
CWD=/home/huw/dev/cdb

# ---------------------------------------------------

DB=cdb_dev
DUMPFIL=${CWD}/db/${DB}/${DB}.skel.sql

mysqldump -p$PWD -u root ${DB} --no-data --routines --skip-dump-date | tr -d "\r" >$DUMPFIL
mysqldump -p$PWD -u root ${DB} cdb_customers cdb_objects cdb_datasources --skip-dump-date >>$DUMPFIL

# ---------------------------------------------------

DB=cdb_test
DUMPFIL=${CWD}/db/${DB}/${DB}.skel.sql

mysqldump -p$PWD -u root ${DB} --no-data --routines --skip-dump-date | tr -d "\r" >$DUMPFIL
mysqldump -p$PWD -u root ${DB} m00_customers m02_objects m06_datasources --skip-dump-date >>$DUMPFIL

# ---------------------------------------------------

DB=cdc_rtg
DUMPFIL=${CWD}/db/${DB}/${DB}.skel.sql

mysqldump -p$PWD -u root $DB --no-data --routines --skip-dump-date | tr -d "\r" >$DUMPFIL
mysqldump -p$PWD -u root $DB cdc_counters --skip-dump-date >>$DUMPFIL

# ---------------------------------------------------

DB=cdb_utils
DUMPFIL=${CWD}/db/${DB}/${DB}.skel.sql

mysqldump -p$PWD -u root $DB --no-data --routines --skip-dump-date | tr -d "\r" >$DUMPFIL
