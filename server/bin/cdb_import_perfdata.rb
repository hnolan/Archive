#=====================================================================
#	cdb_import_files.rb
#---------------------------------------------------------------------
#
#	This script manages the importing of data files into the capacity 
# database. 
#
#	Most of the heavy lifting is done by classes which represent the 
# import directory and the connection to the database.
#
#		Huw Nolan.	Imerja Ltd.	Aug 2009.
#
#=====================================================================

# Add lib directory to load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'/../lib')

require "logger"
require "cdbimport"
require "config"

progname = "CDB Import"

# Read config
#
conf = CONFIG[:cdb_import_files]
#
logname = conf[:logname]
logname = File.expand_path(logname) if logname.class == String
loglevel = conf[:loglevel] || Logger::INFO
imppath = File.expand_path(conf[:importdir])
db_info = conf[:db_info]

# Set up log writer
#
logger = Logger.new(logname)
logger.progname = progname
logger.level = loglevel

logger.info ""	# Blank line to aid log readability
logger.info "---- Entering #{progname} ----"

begin
	imp = CdbImportDir.new( imppath, logger )
 rescue
	puts "** ERROR: Failed to scan import directory: #{$!}"
	logger.error "Failed to scan import directory: #{$!}"
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end

# Leave early if there were no new files
if imp.count == 0
	logger.warn "No new datafiles found"
	logger.info "---- Leaving #{progname} ----"
	exit
 end

begin
	cdb = CdbImportDB.new( db_info, logger ) 
 rescue
	puts "** ERROR: Failed to connect to database: #{$!}"
	logger.error "Failed to connect to database: #{$!}"
	logger.info "---- Leaving #{progname} (Aborted) ----"
  exit
 end
	
imp.each { |df| 
	begin
		puts "Processing: #{df}" 
		cdb.import_data(df)
		imp.move_to_save(df) 
	 rescue
		puts "** ERROR: Failed to import #{df} : #{$!}"
	  logger.error "Failed to import #{df} : #{$!}"
		imp.move_to_bad(df) 
	 end
	}

cdb.closedown

logger.info "---- Leaving #{progname} ----"
