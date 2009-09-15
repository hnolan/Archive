#!/bin/sh
# Get global variables for this system
#
. $HOME/.imerja_env

# Define local variables
#
BINDIR=$HOME/apps/nagios/bin
EXPDIR=$HOME/export/events

# Run daily routines to export data
#
/usr/bin/ruby ${BINDIR}/nag_export_events.rb

# Send export files to central server
#
rsync -rzv --remove-source-files --include=${PREFIX}\*ta --exclude \* ${EXPDIR}/ sm1::events

# That's it

