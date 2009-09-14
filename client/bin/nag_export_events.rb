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
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'/../lib')

require "nagarch"
require 'nagevent'
require "naglog"
require "fileutils"
require "logger"
require "config"

progname = "Export Events"

# Read config
#
prefix  = CONFIG[:prefix]
sysname = CONFIG[:sysname]
#
conf = CONFIG[:nag_export_events]
#
logname  = conf[:logname]
# Only expand Strings (allows an IO object to be specified, e.g. STDOUT)
logname  = File.expand_path(logname) if logname.class == String
archpath = File.expand_path(conf[:archivedir])
destpath = File.expand_path(conf[:eventdir])
maxlogs  = conf[:maxlogs] || 0
	
logger = Logger.new(logname,'monthly')

logger.progname = progname
# logger.level = Logger::INFO
logger.level = Logger::DEBUG

logger.info ""	# Blank line to aid log readability
logger.info "---- Entering #{progname} ----"

# --------------------------------------------------------------------
#	Main routine
# --------------------------------------------------------------------

# Check for destination directory
#
unless File.directory?(destpath) and File.writable?(destpath)
	msg = "Permission problem. Directory #{destpath} is not writable"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

# Build CSV filename
#
csvtime = Time.new.strftime("%Y%m%d.%H%M%S") 
csvfile = "#{prefix}.#{sysname}.nagevt.#{csvtime}.data"
csvfull = File.join(destpath,csvfile)

#	Create the archive directory object 
#
begin
	archdir = NagArchLogDir.new( archpath, logger )
 rescue
 	msg = "Failed to scan archive directory '#{archpath}': #{$!}"
	puts "** ERROR: #{msg}"
	logger.error msg
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

# Leave early if there are no new files
#
if archdir.count == 0
	msg = "No new logfiles found"
	puts msg
	logger.warn msg
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

		msg = "Processing: #{File.basename(fn)}" 
		puts msg
		logger.info msg
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

