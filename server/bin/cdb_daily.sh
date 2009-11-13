BINDIR=$HOME/apps/cdb/bin
LOG=$HOME/logs/cdb_daily.log
echo '------------------------------' >>$LOG
date >>$LOG
#
#	Get new files from serviceman1
#
rsync -rv --remove-source-files  serviceman1::cdb ~/import/cdb >>$LOG 2>&1
rsync -rv --remove-source-files  serviceman1::events ~/import/events >>$LOG 2>&1
#
#	Process data files
#
/usr/local/bin/ruby $BINDIR/cdb_import_perfdata.rb >>$LOG 2>&1
/usr/local/bin/ruby $BINDIR/cdb_import_events.rb >>$LOG 2>&1

