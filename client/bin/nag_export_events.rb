#=====================================================================
#	nag_export_events.rb
#---------------------------------------------------------------------
#
#	This script creates events from state information recorded in nagios
# archive logs and stores the events in a CSV file.
#
#	Most of the heavy lifting is done by classes which represent the 
# archive directory, logfiles and events.
#
#		Huw Nolan.	Imerja Ltd.	Sep 2009.
#
#=====================================================================

# Add lib directory to load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'/lib')
puts $LOAD_PATH

require "nagarch"
require 'nagevent'
require "naglog"
require "fileutils"
require "logger"
require "config"

progname = "Export Events"

logger = Logger.new(CONFIG[:logfile])

logger.progname = progname
# logger.level = Logger::INFO
logger.level = Logger::DEBUG

logger.info ""	# Blank line to aid log readability
logger.info "---- Entering #{progname} ----"

# require "profile"

# Read config
#
prefix = CONFIG[:prefix]
sysname = CONFIG[:sysname]
archdirname = CONFIG[:archivedir]
maxlogs = CONFIG[:maxlogs] || 0
	
puts maxlogs

# --------------------------------------------------------------------
#	Main routine
# --------------------------------------------------------------------

# Check for destination directory
#
csvdir = File.join(archdirname,"events")
unless File.directory?(csvdir)
	logger.info "Creating #{csvdir}"
	begin
		FileUtils.mkdir csvdir 
	 rescue
		msg = "Failed to create CSV directory: #{$!}"
		puts "** ERROR: #{msg}"
		logger.error msg
		logger.info "---- Leaving #{progname} (Aborted) ----"
	  exit
	 end
 end
unless File.writable?(csvdir)
	msg = "Permission problem. Directory #{csvdir} is not writable"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

# Build CSV filename
#
csvtime = Time.new.strftime("%Y%m%d.%H%M%S") 
csvfile = "#{prefix}.#{sysname}.nagevent.#{csvtime}.csv"
csvfull = File.join(csvdir,csvfile)

#	Create the archive directory object 
#
begin
	archdir = NagArchLogDir.new( archdirname, logger )
 rescue
 	msg = "Failed to scan archive directory: #{$!}"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

# Leave early if there are no new files
#
if archdir.count == 0
	logger.warn "No new logfiles found"
	logger.info "---- Leaving #{progname} ----"
	exit
 end

# Create the event store to hold new events
#
begin
	evstore = NagEventStore.new
 rescue
 	msg = "Failed to create event store: #{$!}"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

#	Process each new logfile in the archive dir
#
logno = 0
archdir.each do |fn|
	begin

		logger.info "Processing: #{File.basename(fn)}" 
		lf = NagLogFile.new(fn)

		# Process each stateful log entry
		lf.each_stateful { |le| 
			evstore.process_log_entry(le)
			}

		# Tell the archdir object that a file has been processed
		archdir.processed(fn)
		logno += 1

		if maxlogs > 0 and logno >= maxlogs
			logger.warn "Processed maximum number of logifles (#{logno})"
			break 
		 end

	 rescue
		msg = "Failed to process #{fn} : #{$!}"
		puts "** ERROR: #{msg}"
		logger.error msg
		logger.info "---- Leaving #{progname} (Aborted) ----"
	  exit
	 end
 end

# Save the events to a CSV file
#
begin
	logger.info "Saving events to '#{csvfull}'"
	evstore.save_events(csvfull)
 rescue
	msg = "Failed to save events to '#{csvfull}': #{$!}"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

logger.info "---- Leaving #{progname} ----"

