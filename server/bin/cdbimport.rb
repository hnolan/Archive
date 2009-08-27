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
#  CdbDatafile objects
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
			next unless f =~ /\.data$/			# Ignore any non *.data files
			begin
				df = CdbDatafile.new(@baddir,f)
				@baddata[df.srckey] = 1				
			 rescue 
				# Ignore exceptions for baddir
			 end
		 end

		bad_found = @baddata.keys.size
		log_warn "Found bad files from #{bad_found} datasources" if bad_found > 0

		Dir.new(@holddir).entries.each do |f|
			next unless f =~ /\.data$/			# Ignore any non *.data files
			begin
				df = CdbDatafile.new(@holddir,f)
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
			next unless f =~ /\.data$/			# Ignore any non *.data files
			begin
				df = CdbDatafile.new(@dirname,f)
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
class CdbDatafile

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
		raise "No meta file" unless FileTest.exist?(@metafull)

		# Check that we have the rights to move these files
		raise "Permission problem. #@metafull is not writable" unless File.writable?(@metafull)
		raise "Permission problem. #@datafull is not writable" unless File.writable?(@datafull)
		
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
			FileUtils.move( @metafull, metanew )
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

	end

	def import_data(df)

		# Import dataset details into a temp table
		db_query( "truncate table tempds" )
		db_query( "load data infile '#{df.metafull}' into table tempds" )
		log_info "Imported #{@db.affected_rows} rows from #{df.metafile} into tempds"

		# Call procedure to check (and create) datasets
		log_debug "SQL: call cdb_check_datasets( '#{df.prefix}', '#{df.srcsrv}', '#{df.srcapp}' )"
		@db.query("call cdb_check_datasets( '#{df.prefix}', '#{df.srcsrv}', '#{df.srcapp}' )") { |rs|
			log_info(rs.fetch_row[0]) if rs.num_rows > 0
			}

		# Import data into a temp table
		db_query( "truncate table tempdt" )
		db_query( "load data infile '#{df.datafull}' into table tempdt" )
		log_info "Imported #{@db.affected_rows} rows from #{df.datafile} into tempdt"

		# Call procedure to store new data into the customer specific table
		log_debug "SQL: call cdb_import_data( '#{df.prefix}', '#{df.srcsrv}', '#{df.srcapp}' )"
		@db.query("call cdb_import_data( '#{df.prefix}', '#{df.srcsrv}', '#{df.srcapp}' )") { |rs|
			log_info(rs.fetch_row[0]) if rs.num_rows > 0
			}
	
	end

	def test(tab)
		res = @db.query( "select * from #{tab}" )
		res.each { |r| puts r }
	end	

	def closedown
		db_query( "drop temporary table tempds" )
		db_query( "drop temporary table tempdt" )
		@db.close
	end

 private
 
  def db_query(sql)
		log_debug("SQL: #{sql}")
		@db.query(sql)
  end

end

