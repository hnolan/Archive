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

require "logger"
require "cdbimport"

logger = Logger.new("cdb_import_files.log")

# logger = Logger.new(STDOUT)
logger.progname = "CDB Import"
# logger.level = Logger::INFO
logger.level = Logger::DEBUG

logger.info ""	# Blank line to aid log readability
logger.info "---- Entering CDB Import ----"

begin
	imp = CdbImportDir.new( "/var/cdb/import", logger )
 rescue
	puts "** ERROR: Failed to scan import directory: #{$!}"
	logger.error "Failed to scan import directory: #{$!}"
	logger.info "---- Leaving CDB Import (Aborted) ----"
  exit
 end

# Leave early if there were no new files
if imp.count == 0
	logger.warn "No new datafiles found"
	logger.info "---- Leaving CDB Import ----"
	exit
 end

conninfo = [ 'localhost', 'root', 'passport', 'cdb_dev' ]

begin
	cdb = CdbImportDB.new( conninfo, logger ) 
 rescue
	puts "** ERROR: Failed to connect to database: #{$!}"
	logger.error "Failed to connect to database: #{$!}"
	logger.info "---- Leaving CDB Import (Aborted) ----"
  exit
 end
	
imp.each { |df| 
	begin
		cdb.import_data(df)
		imp.move_to_save(df) 
	 rescue
	  logger.error "Import of #{df} failed : #{$!}"
		imp.move_to_bad(df) 
	 end
	}

cdb.closedown

logger.info "---- Leaving CDB Import ----"
