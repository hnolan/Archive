require "mysql"
require "fileutils"
require "pp"
require "logger"

#-------------------------------------------------
# Module to allow class-specific logging to be
#  mixed-in to other classes
module MyLog
	def log_debug(msg) @log.debug(self.class.name) { msg }	end
	def log_info(msg)  @log.info(self.class.name)  { msg }	end
	def log_warn(msg)  @log.warn(self.class.name)  { msg }	end
	def log_error(msg) @log.error(self.class.name) { msg }	end
	def log_fatal(msg) @log.fatal(self.class.name) { msg }	end
end

#-------------------------------------------------
# An import directory that holds a collection of
#  CdbDataFile objects
class CdbImportDir

	include MyLog
	attr_reader :dirname

	def initialize( d, logger = nil )

		# Set up logging for this instance
		@log = logger.class == Logger ? logger : Logger.new(STDOUT)

		# Validate parameter
		raise "Import directory not found, #{d}" unless File.directory?(d)
		@dirname = File.expand_path(d)

		log_info "Import directory, #@dirname"

		raise "Permission problem. Directory #{@dirname} is not writable" unless File.writable?(@dirname)

		# Initialise hashes
		@newdata = Hash.new		
		@baddata = Hash.new		
	
		# Check for sub-directory structure (bad, hold, save)
		@baddir  = check_dir( "bad" )	
		@holddir = check_dir( "hold" )
		@savedir = check_dir( "save" )

		# Scan bad and hold directories for data files
		# ( We don't need to store details, just a marker that 
		#   files from this datasource exist )
	
		Dir.new(@baddir).entries.each do |f|
			next unless CdbDataFile.valid_name?(f)
			begin
				df = CdbDataFile.new(@baddir,f)
				@baddata[df.srckey] = 1				
			 rescue 
				# Ignore exceptions for baddir
			 end
		 end

		bad_found = @baddata.keys.size
		log_warn "Found bad files from #{bad_found} datasources" if bad_found > 0

		Dir.new(@holddir).entries.each do |f|
			next unless CdbDataFile.valid_name?(f)
			begin
				df = CdbDataFile.new(@holddir,f)
				@baddata[df.srckey] = 1
			 rescue 
				log_error "'#{$!}' error while processing #{f} in #{@holddir}. File ignored"
			 end
		 end

		held_found = @baddata.keys.size - bad_found
		log_warn "Found held files from #{held_found} datasources" if held_found > 0

		# Compile a list of new data files (look for *.data files)
		# Scan import directory entries for new data files
		Dir.new(@dirname).entries.each do |f|
			next unless CdbDataFile.valid_name?(f)
			begin
				df = CdbDataFile.new(@dirname,f)
				@newdata[df.sortkey] = df
				move_to_hold(df) if @baddata.has_key?(df.srckey)
			 rescue 
			 	if $!.message =~ /Permission problem/
			 		raise
			 	 else
					log_error "'#{$!}' error while processing #{@dirname}/#{f}. Moving file to #{@baddir}"
					FileUtils.move( File.join( @dirname, f ), File.join( @baddir, f ) )
				 end
			 end
		 end
		
		log_info "Valid datafiles found: #{@newdata.keys.size}"
		
		# Log debug info
		@newdata.keys.sort.each { |k| log_debug "    #{@newdata[k]}" }
		log_debug "  Bad     : #@baddir" 
		log_debug "  Hold    : #@holddir" 
		@baddata.keys.sort.each { |k| log_debug "    #{k}" }
		log_debug "  Save    : #@savedir" 

	end

	def move_to_bad(df)
		df.move( @baddir )
		@newdata.delete(df.sortkey)
		@baddata[df.srckey] = 1
		log_error "Moved #{df} to #@baddir"
	end

	def move_to_hold(df)
		df.move( @holddir )
		@newdata.delete(df.sortkey)
		@baddata[df.srckey] = 1
		log_warn "Moved #{df} to #@holddir"
	end

	def move_to_save(df)
		df.move( @savedir )
		@newdata.delete(df.sortkey)
		log_info "Moved #{df} to #@savedir"
	end

	def each
		# Return each new datafile found 
		# (unless a matching badfile exists, in which case hold it)
		@newdata.keys.sort.each do |k| 
			df = @newdata[k]
			if @baddata.has_key?(df.srckey)
				move_to_hold(df)
			 else
				yield df 
			 end
		 end
	end

	def count
		@newdata.keys.size
	end

 private

	def check_dir(dtype)
		dname = File.join( @dirname, dtype )	
		FileUtils.mkdir dname unless File.directory?(dname)
		raise "Permission problem. Directory #{dname} is not writable" unless File.writable?(dname)
		dname
	end

end

#-------------------------------------------------
class CdbDataFile

# A pair of data xfer files
# <PFX>.<srcsrv>.<srcapp>.<date>.<time>.meta
# <PFX>.<srcsrv>.<srcapp>.<date>.<time>.data

	attr_reader	:prefix, :srcsrv, :srcapp, :dattim
	attr_reader :datafull, :metafull, :datafile, :metafile

	def initialize(d,f)
		if f =~ /^(\w+)\.(\w+)\.(\w+)\.(\d+\.\d+)\.data$/
			@prefix, @srcsrv, @srcapp, @dattim = $1, $2, $3, $4
		 elsif f =~ /^(\w+)\.(\w+)\.(\d+\.\d+)\.data$/
			@prefix, @srcsrv, @srcapp, @dattim = $1, $2, '', $3
		 else
			raise "Unrecognised filename"
		 end

		@datapath = d
		@datafile = f
		
		if @srcapp == ''
			@metafile = "#{@prefix}.#{@srcsrv}.#{@dattim}.meta"
			@srcapp = 'rtg'
		 else
			@metafile = "#{@prefix}.#{@srcsrv}.#{@srcapp}.#{@dattim}.meta"
		 end

		@datafull = File.join( @datapath, @datafile )
		@metafull = File.join( @datapath, @metafile )

		# Check that *.meta file exists
		raise "No meta file" if has_meta? and not FileTest.exist?(@metafull)

		# Check that we have the rights to move these files
		raise "Permission problem. #@metafull is not writable" if has_meta? and not File.writable?(@metafull)
		raise "Permission problem. #@datafull is not writable" unless File.writable?(@datafull)
		
	end

	# Detect filenames that seem valid
	def self.valid_name?(f)
		f =~ /^(\w+)\.(\w+)\.(\w+)\.(\d+\.\d+)\.data$/ or f =~ /^(\w+)\.(\w+)\.(\d+\.\d+)\.data$/
	end

	# Move the pair of files to a new directory
	def move(d)

		# Validate target directory
		raise "Target directory not found, #{d}" unless File.directory?(d)
		dname = File.expand_path(d)

		# Construct target pathnames		
		metanew = File.join( dname, @metafile )
		datanew = File.join( dname, @datafile )
		
		# Move the pair to new directory
		begin
			FileUtils.move( @metafull, metanew ) if has_meta?
		 rescue
			raise "Move failed for #{@metafull} to #{metanew}: $!"
		 end
		
		begin
			FileUtils.move( @datafull, datanew )
		 rescue
			raise "Move failed for #{@datafull} to #{datanew}: $!"
		 end

		# Update instance variables
		@dirname = dname
		@metafull = metanew
		@datafull = datanew
		
	end

	def has_meta?
		true	# @srcapp == 'rtg'
	end

	def sortkey
		"#@dattim.#@prefix.#@srcsrv.#@srcapp"
	end
	
	def srckey
		"#@prefix.#@srcsrv.#@srcapp"
	end
	
	def to_s
		@datafile
	end

end

#-------------------------------------------------
class CdbImportDB

	include MyLog

	def initialize( conninfo, logger = nil )

		host, user, pswd, db = conninfo

		# Set up logging for this instance
		@log = logger.class == Logger ? logger : Logger.new(STDOUT)

		@db = Mysql.new( host, user, pswd, db, nil, nil, Mysql::CLIENT_MULTI_RESULTS )
		
		log_debug "Connected to database #{db} on #{host}"		

		db_query( "create temporary table tempds like template_ds" )
		db_query( "create temporary table tempdt like template_dt" )
		db_query( "create temporary table tempin like template_in" )
		db_query( "create temporary table tempev like template_ev" )

	end

	def import_data(df)

		@cdb_err = nil

		if df.srcapp == 'rtg'

			# Import dataset details into a temp table
			load_data( df.metafull, 'tempds' )
	
			# Call procedure to check (and create) datasets
			db_call("cdb_check_datasets",df)
	
			# Import hourly data into a temp table
			load_data( df.datafull, 'tempdt' )
	
			# Call procedure to store new data into the customer specific table
			db_call("cdb_import_data",df)

		 elsif df.srcapp == 'nagevt'

			# Load raw event data into temp tables
			load_data( df.metafull, 'tempin' )
			load_data( df.datafull, 'tempev' )

			# Call procedure to store new events into the customer specific table
			db_call("nag_import_events",df)

		 else
			@cdb_err = "Import failed, unknown srcapp '#{df.srcapp}' for file '#{df.datafull}'"
		 end
	
		raise @cdb_err if @cdb_err

	end

	def test(tab)
		res = @db.query( "select * from #{tab}" )
		res.each { |r| puts r }
	end	

	def closedown
		db_query( "drop temporary table tempds" )
		db_query( "drop temporary table tempdt" )
		db_query( "drop temporary table tempin" )
		db_query( "drop temporary table tempev" )
		@db.close
	end

 private

	def load_data(fn,tt)

		# Build sql statement
		sql = "load data infile '#{fn}' into table #{tt} " + 
		case tt
		 when 'tempds' :
		 	" ( cdc_dataset_id, cdc_machine, cdc_object, cdc_instance, cdc_counter, speed, description )"
		 when 'tempdt' :		
			" ( sample_date, sample_hour, cdc_dataset_id, data_min, data_max, data_sum, data_count )"
		 when 'tempin' :		
			" fields terminated by ',' optionally enclosed by '\"' lines terminated by '\\n'  ignore 1 lines " +
			" ( svc_id, host, service, first_status_time, latest_status_time )"
		 when 'tempev' :		
			" fields terminated by ',' optionally enclosed by '\"' lines terminated by '\\n'  ignore 1 lines " +
 			" ( svc_id, ev_state, hard_soft, start_time, end_time, duration, next_state, entry_type, message )"
		 end

		# Empty the temp table
		db_query( "truncate table #{tt}" )

		# Call the data load statement
		db_query( sql )

		# Report response to logs
		msg = "Loaded #{@db.affected_rows} rows from #{File.basename(fn)} into #{tt}"
		log_info msg
		@db.query( "call cdb_logit('cdb_import_files','#{msg}')" )
	
	end

	def db_call( sp, df )
		sql = "call #{sp}( '#{df.prefix}', '#{df.srcsrv}', '#{df.srcapp}' )"
		log_debug "SQL: #{sql}"
		@db.query(sql) { |rs|
			msg = rs.fetch_row[0] or @cdb_err = "No message returned from #{sp}"
			@cdb_err = msg if msg =~ /error/i
			log_info(msg) unless @cdb_err
			}
	end
 
  def db_query(sql)
		log_debug("SQL: #{sql}")
		@db.query(sql)
  end

end

