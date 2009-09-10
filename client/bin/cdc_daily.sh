#!/bin/sh
# Get global variables for this system
#
. $HOME/.imerja_env

# Define local variables
#
BINDIR=$HOME/apps/cdc/bin
EXPDIR=$HOME/export/cdc

# Run daily routines to export data
#
mysql -proc -u cdc cdc_rtg <${BINDIR}/cdc_daily.sql

# Send export files to central server
#
rsync -rzv --remove-source-files --include=${PREFIX}\*ta --exclude \* ${EXPDIR}/ sm1::cdb

# That's it

