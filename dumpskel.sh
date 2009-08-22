PWD=passport
CWD=/home/huw/dev/cdb

# ---------------------------------------------------

#DB=cdb_dev
#DUMPFIL=${CWD}/server/${DB}/sql/${DB}.skel.sql
#
#mysqldump -p$PWD -u root ${DB} --no-data --routines >$DUMPFIL
#mysqldump -p$PWD -u root ${DB} m00_customers m06_datasources >>$DUMPFIL

# ---------------------------------------------------

#DB=cdc_rtg
#DUMPFIL=${CWD}/client/${DB}/sql/${DB}.skel.sql
#
#mysqldump -p$PWD -u root $DB --no-data --routines >$DUMPFIL
#mysqldump -p$PWD -u root $DB cdc_counters        >>$DUMPFIL

# ---------------------------------------------------

DB=cdb_utils
DUMPFIL=${CWD}/misc/${DB}/sql/${DB}.skel.sql

mysqldump -p$PWD -u root $DB --no-data --routines >$DUMPFIL
