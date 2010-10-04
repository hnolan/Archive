require "pp"
require "nagcfg.rb"
require "naginst.rb"

class NagiosConfig

	def initialize( fname, pathsub = nil )
		
		# Initialise data structures
		@errors = Array.new
		@pathsub = pathsub

		# Config data
		@cfg_files = Array.new
		@cfg_objects = Hash.new
		@cfg_ancestors = Hash.new

		# Object Instance data
		@inst_data = NagiosInstanceContainer.new

		# Read main config file
		@mainfile = NagCfg_File.new(fname,get_local_name(fname))
		@mainfile.list_errors if @mainfile.has_errors?
		
		raise "No config variables found in file #{fname}" if @mainfile.var_count <= 0

		# collect object config files
		@mainfile.each_var { |v| 
			@cfg_files << v.value if v.name == "cfg_file" 
			@cfg_files.concat(getcfg_(v.value)) if v.name == "cfg_dir" 
			}

		# Collect objects from all config files
		@cfg_files.each { |f| 
			cf = NagCfg_File.new(f,get_local_name(f))
			cf.list_errors if cf.has_errors?

			cf.each_obj { |o|
				@cfg_objects[o.objtype] = [] unless @cfg_objects.key?(o.objtype)
				@cfg_objects[o.objtype] << o
				if o.has_name?
					@cfg_ancestors[o.objtype] = {} unless @cfg_ancestors.key?(o.objtype)
					@cfg_ancestors[o.objtype][o.name] = o 
				 end
				}
			}

		#	Calculate explicit object inheritance
		@cfg_objects.each_key { |objtype|	
			# Process each objtype for inheritance
			@cfg_objects[objtype].each { |o|
				next unless o.has_use?	# Only process object which have a "use" attribute
				begin
					o.inherit(@cfg_ancestors[objtype])	# do inheritance for the object
				 rescue 
					@errors << "Object Inheritance: [#{$!}]"
				 end
				}
			}

		# Fill in defaults

		# Gather the 1:1 object instances
		%w( timeperiod command contact contactgroup host hostextinfo hostgroup servicegroup ).each { |objtype|
			next unless @cfg_objects.key?(objtype)
			@cfg_objects[objtype].each { |o|
				next unless o.register?	# Do not instantiate config object if register is 0
				inst = nil
				begin
					# Create type-specific instance from the object
					if objtype == "command" 					then inst = NagiosCommand.new(o)	
					 elsif objtype == "contact" 			then inst = NagiosContact.new(o)
					 elsif objtype == "contactgroup" 	then inst = NagiosContactGroup.new(o)
					 elsif objtype == "host" 					then inst = NagiosHost.new(o)
					 elsif objtype == "hostextinfo" 	then inst = NagiosHostExtInfo.new(o)
					 elsif objtype == "hostgroup" 		then inst = NagiosHostGroup.new(o)
					 elsif objtype == "servicegroup"  then inst = NagiosServiceGroup.new(o)
					 elsif objtype == "timeperiod"  	then inst = NagiosTimePeriod.new(o)
					 end
				 rescue 
					@errors << "Object Instantiation: failed for object:\n#{o}\n[#{$!}]\n\n"
				 end
				@inst_data.add(inst) if inst
				}
			}
			
		# Gather the 1:Many object instances
#		%w( hostdependency hostescalation service serviceextinfo servicedependency serviceescalation  )
#					 elsif objtype == "hostdependency"		then inst = NagiosHostDependency.new(o)
#					 elsif objtype == "hostescalation"		then inst = NagiosHostEscalation.new(o)
#					 elsif objtype == "service"						then inst = NagiosService.new(o)
#					 elsif objtype == "servicedependency"	then inst = NagiosServiceDependency.new(o)
#					 elsif objtype == "serviceescalation"	then inst = NagiosServiceEscalation.new(o)
#					 elsif objtype == "serviceextinfo"		then inst = NagiosServiceExtInfo.new(o)

		#	Calculate implicit object inheritance

		puts "Found #{@errors.size} errors in nagios config file #{fname}" if has_errors?

	end

	def has_errors?
		@errors.size > 0
	end

	def list_errors
		@errors.each { |err| puts err }
	end

	def list_instances(typ=nil)
		@inst_data.each(typ) { |inst| puts inst.to_s }
	end

	def object_types
		NAG_OBJTYP
	end

	def each_obj(objtypes=nil)
		objarr = Array.new
		if objtypes.class == Array
			objarr = objtypes
		 elsif objtypes.class == String
		 	objarr[0] = objtypes
		 else
		 	objarr = 	@cfg_objects.keys
		 end
		objarr.each { |t| @cfg_objects[t].each { |o| yield o } }
	end

	def report
		puts "Report for Nagios config file: #{@mainfile.filename}\n"
		puts "\tMainfile contains #{@mainfile.var_count} variables\n"
		puts "\tMainfile references #{@cfg_files.size} object files\n"
		puts "Object summary\n"
		@cfg_objects.keys.sort.each { |k| 
			puts "\t#{@cfg_objects[k].size.to_s.rjust(5)} #{k} definitions\n" 
			}
	end

	def dump_obj(objtypes=nil)
#		puts "ObjectType,ObjectID,AttributeName,AttributeValue,SourceObj,SourceFile,SourceLine"
		puts "ObjectType\tObjectID\tAttributeName\tAttributeValue\tSourceObj\tSourceFile\tSourceLine"
		each_obj(objtypes) { |o|
			ot = o.objtype
			oid = o.objid
			o.each_attribute { |a|
#				puts "#{ot},#{oid},#{a.name},\"#{a.value}\",#{a.objname},#{a.cfgfile},#{a.cfgline}\n"
				puts "#{ot}\t#{oid}\t#{a.name}\t\"#{a.value}\"\t#{a.objname}\t#{a.cfgfile}\t#{a.cfgline}\n"
				}
			}
	end

 private

	# Convert file and directory references to use local path names
	def get_local_name(n)
		# Ensure that we operate on a new object rather than 
		# a reference to the parameter
		newname = n.clone
		
		# Substitute path names
		@pathsub.each { |k,v|
			newname.sub!(k,v)
			} if @pathsub.class == Hash
		newname
	end

	# Compile a list of all config files (*.cfg files)
	# in the supplied directory
	def getcfg_(d)

		# Strip trailing separator, if present
		cfg_dir = d.sub(/[\/\\]$/,'')
		
		# Get locally converted name
		locdir = get_local_name(cfg_dir)

		cfg_files = Array.new		

		# Scan directory entries for config files
		Dir.new(locdir).entries.each do |f|
			next unless f =~ /\.cfg$/			# Exclude any non *.cfg_ files
			cfg_files << ("#{cfg_dir}/#{f}")		# Add to array
		 end
	
		cfg_files	# Return the array
			
	end

end

