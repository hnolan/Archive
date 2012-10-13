require "pp"
require "nagcfginfo.rb"

#=====================================================================
#		Nagios Configuration
#=====================================================================
#
# The NagiosConfig class represents a complete Nagios configuration
# which consists of a single main configuration file and one or more
# object configuration files. 
#
# This class uses the NagiosConfigMainFile and NagiosConfigObjectFile
# classes (defined below) to interpret individual configuration files.
# 
# Any syntax errors encountered while reading the configuration are
# recorded in an array and can be processed subsequently.
#
class NagiosConfig

	def initialize( fname, pathsub = nil )
		
		# Initialise data structures
		@errors = Array.new
		@pathsub = pathsub

		# Config data
		@cfg_files = Array.new
		@cfg_objects = Hash.new
		@cfg_templates = Hash.new

		# Read main config file
		@mainfile = NagiosConfigMainFile.new(fname,get_local_name(fname))
		@mainfile.list_errors if @mainfile.has_errors?
		
		raise "No config variables found in file #{fname}" if @mainfile.var_count <= 0

		# collect object config files
		@mainfile.each { |v| 
			@cfg_files << v.value if v.name == "cfg_file" 
			@cfg_files.concat(getcfg_(v.value)) if v.name == "cfg_dir" 
			}

		# Collect objects from all config files
		@cfg_files.each { |f| 
			cf = NagiosConfigObjectFile.new(f,get_local_name(f))
			cf.list_errors if cf.has_errors?

			cf.each { |o|
				@cfg_objects[o.nagobj_type] = [] unless @cfg_objects.key?(o.nagobj_type)
				@cfg_objects[o.nagobj_type] << o
				if o.is_template?
					@cfg_templates[o.nagobj_type] = {} unless @cfg_templates.key?(o.nagobj_type)
					@cfg_templates[o.nagobj_type][o.template_name] = o 
				 end
				}
			}

		#	Calculate explicit object inheritance
		each_obj { |o|	
			next unless o.is_inheritor?	# Only process object which have a "use" attribute
			begin
				# Do inheritance for the object, passing in a list of templates to use
				o.inherit(@cfg_templates[o.nagobj_type])	
			 rescue 
				@errors << "Object Inheritance Failed: [#{$!}]"
			 end
			}

		puts "Found #{@errors.size} errors in nagios config file #{fname}" if has_errors?

	end

	def has_errors?
		@errors.size > 0
	end

	def list_errors
		@errors.each { |err| puts err }
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
		puts "\nReport for Nagios config file: #{@mainfile.filename}\n"
		puts "\tMainfile contains #{@mainfile.var_count} variables\n"
		puts "\tMainfile references #{@cfg_files.size} object files\n"
		puts "\nObject summary\n"
		@cfg_objects.keys.sort.each { |k| 
			puts "\t#{@cfg_objects[k].size.to_s.rjust(5)} #{k} definitions\n" 
			}
	end

	def dump_obj(objtypes=nil)
		puts "ObjectType\tObjectID\tAttributeName\tAttributeValue\tSourceObj\tSourceFile\tSourceLine"
		each_obj(objtypes) { |o|
			ot = o.nagobj_type
			oid = o.nagobj_id
			o.each_attribute { |a|
				puts "#{ot}\t#{oid}\t#{a.name}\t\"#{a.value}\"\t#{a.obj_handle}\t#{a.cfg_file}\t#{a.cfg_line}\n"
				}
			}
	end

	def report_inheritance

		puts "\n\n#=============================\n"
		puts "# Abstract Template Objects\n"
		puts "#=============================\n\n"
		each_obj { |o|
			next unless o.is_template? and o.is_abstract?
			puts o.nagobj_handle
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects that are also Templates\n"
		puts "#=============================\n\n"
		each_obj { |o|
			next unless o.is_template? and not o.is_abstract?
			puts o.nagobj_handle
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects using Inheritance\n"
		puts "#=============================\n\n"
		each_obj { |o|
			next unless o.is_inheritor? and not o.is_template?
			puts o.nagobj_handle
			puts "\t#{o.get_attribute('use')}"
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects with no Inheritance\n"
		puts "#=============================\n\n"
		each_obj { |o|
			next if o.is_inheritor? or o.is_template?
			puts o.nagobj_handle
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

#=====================================================================
#		Nagios Config Main File
#=====================================================================
#
# The NagiosConfigMainFile class represents the main Nagios 
# configuration file
# 
#	Although the class can validate the variable names using the data
# held in the info module, it only understands the lexical and structural
# rules outlined below, and in no way infers any meaning from the variables.
#
# Any syntax errors encountered while reading a config file are recorded
# in an array and can be processed subsequently.
#
# Main file structure
#
# These consist of a list of keyword=value pairs, with the following
# general rules for content:
#		Any lines starting with hash (#) are comments and can be ignored
#		Any lines which are blank or consist only of whitespace can be ignored
#		The keyword=value pairs must start in the first character of a line
#			( no whitespace is allowed before the keyword )
#		Trailing whitespace is not significant (it is stripped)
#
# Import object and variable definition data
#

class NagiosConfigMainFile

	attr_reader :filename, :var_count

	def initialize(fname,locname=nil)

		@filename = fname
		@vars = Array.new
		@errors = Array.new

		@f = File.open(locname ? locname : fname)

		linenum = 0; linebuf = ""; 

		@f.each { |fileline|
			linenum += 1
			
			# Discard comment lines and blank lines
			next if fileline =~ /^\s*#/
			next if fileline =~ /^\s*\;/
			next if fileline =~ /^\s*$/

			# Handle continuation lines
			if fileline =~ /(.*)\\$/
				linebuf += $1 ; next
			 else
				linebuf += fileline
			 end

			if linebuf =~ /^[\$\w_\[\]]+=/		# Variable definition
				begin
					@vars << NagiosConfigVariable.new(linebuf, fname, linenum)
				 rescue 
					@errors << "Bad variable found at line #{linenum}: #{$!}\n[#{linebuf}]"
				 end
			 else
				@errors << "Unrecognised entry at line #{linenum}: [#{linebuf}]"
			 end

			# Clear line buffer
			linebuf = ""

			}		

		@f.close

		@var_count = @vars.size

		puts "Found #{@errors.size} errors in nagios config file #{fname}" if has_errors?

	end

	def each
		@vars.each { |i| yield i }
	end

	def has_errors?
		@errors.size > 0
	end

	def list_errors
		@errors.each { |err| puts err }
	end

	def dumpcfg(dump_all=0)
		puts "\nNagios Main Config File : #{@filename}"
		if @var_count > 0 
			puts "\tFound #{@var_count} variables"
			@vars.each { |v| puts "\t\t#{v}" } if dump_all != 0
		 end
	end

end

# ------------------------------------------------

class NagiosConfigVariable

	attr_reader :name, :value, :cfg_file, :cfg_line

	def initialize(txt,fname,linenum)

		@cfg_file = fname
		@cfg_line = linenum

		# Validate input text
		# Handle global keyword=value (no whitespace allowed before keyword)
		if txt =~ /([\$\w_\[\]]+)\s*=\s*(.*)$/	
			@name = $1; @value = $2.strip
			raise "Unrecognised Variable Declaration [#{@name}]" unless NAG_MAINVARS.include?(@name)
		 else
			raise "Malformed Variable Declaration [#{txt}]"
		 end
		 
	end

	def to_s
		s = "#{@name}=#{@value}"
	end

end

#=====================================================================
#		Nagios Config Object File
#=====================================================================
#
# The NagiosConfigObjectFile class represents a single Nagios object
# configuration file.
# 
#	Although the class can validate the declaration and attribute names
# using the data held in the info module, it only understands the
# lexical and structural rules outlined below, and in no way infers any
# meaning from the objects that it reads.
#
# Any syntax errors encountered while reading config files are recorded
# in an array and can be processed subsequently.
#
# Object configuration file structure
#
# These files consist of a series of object definitions. An object
# definition is of the form:
#
#		 define objectname{
#				keyword	value
#				keyword	value	; optional comment
#				 ...
#				keyword	value
#				}
#
#		Any lines starting with hash (#) are comments and can be ignored
#		Any lines which are blank or consist only of whitespace can be ignored
#		The keyword/value pairs need not start in the first character of a line
#		The keyword and value pair are separated by whitespace
#		A keyword/value pair can optionally be followed by a comment. The comment 
#			is preceded by a semi-colon (;) 
#		The body of an object definition must only consist of keyword/value pairs
#		Whitespace is allowed within a value, but trailing whitespace is not 
#			significant (it is stripped)
#
class NagiosConfigObjectFile

	attr_reader :filename, :obj_count

	def initialize(fname,locname=nil)

		@filename = fname
		@objs = Array.new
		@errors = Array.new

		@f = File.open(locname ? locname : fname)

		linenum = 0; linebuf = ""; 
		nagobj_type = nil; objlinenum = 0
		objattr = Array.new;
		curr_obj = nil

		@f.each { |fileline|
			linenum += 1
			
			# Discard comment lines and blank lines
			next if fileline =~ /^\s*#/
			next if fileline =~ /^\s*\;/
			next if fileline =~ /^\s*$/

			# Handle continuation lines
			if fileline =~ /(.*)\\$/
				linebuf += $1 ; next
			 else
				linebuf += fileline
			 end

			if curr_obj == nil	# We are not in an object definition
			
				if linebuf =~ /^\s*define\s+(\w+)\s*\{\s*$/	# Object definition

					nagobj_type = $1

					# Start of object definition - create the new object
					begin
						curr_obj = NagiosConfigObject.new(nagobj_type, fname, linenum)
					 rescue 
						@errors << "Illegal Object found at line #{linenum}: #{$!}\n[#{linebuf}]"
					 end

				 else
					@errors << "Unrecognised entry at line #{linenum}: [#{linebuf}]"
				 end

			 else			 				# We are in an object definition

				if linebuf =~ /\}\s*$/

					# End of object definition - store the object
					@objs << curr_obj
					curr_obj = nil

				 else

					# Treat any lines within an object as an attribute
					begin
					 	curr_obj.new_attribute(linebuf, linenum)
					 rescue 
						@errors << "Bad object attribute found at line #{linenum}: #{$!}\n[#{linebuf}]"
					 end

			 	 end

			 end

			# Clear line buffer
			linebuf = ""

			}		

		@f.close

		@obj_count = @objs.size

		puts "Found #{@errors.size} errors in nagios config file #{fname}" if has_errors?

	end

	def each
		@objs.each { |i| yield i }
	end

	def has_errors?
		@errors.size > 0
	end

	def list_errors
		@errors.each { |err| puts err }
	end

	def dumpcfg(dump_all=0)
		puts "\nObject Config file : #{@filename}"
		if @obj_count > 0 
			puts "\tFound #{@obj_count} objects"
			@objs.each { |o| puts "\t\t#{o}" } if dump_all != 0
		 end
	end

	def report_inheritance

		puts "\n\n#=============================\n"
		puts "# Abstract Template Objects\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next unless o.is_template? and o.is_abstract?
			puts o.nagobj_handle
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects that are also Templates\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next unless o.is_template? and not o.is_abstract?
			puts o.nagobj_handle
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects using Inheritance\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next unless o.is_inheritor? and not o.is_template?
			puts o.nagobj_handle
			puts "\t#{o.get_attribute('use')}"
			}
		
		puts "\n\n#=============================\n"
		puts "# Objects with no Inheritance\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next if o.is_inheritor? or o.is_template?
			puts o.nagobj_handle
			}

	end

end

# ------------------------------------------------

class NagiosConfigObject

	attr_reader :nagobj_type, :nagobj_name, :template_name
	attr_reader :cfg_file, :cfg_line

	def initialize(nagobj_type,fname,linenum)

		# Validate object type
		raise "Unrecognised Object type [#{nagobj_type}]" unless NAG_OBJVARS.key?(nagobj_type)

		# Initialise variables
		@nagobj_type = nagobj_type
		@cfg_file = fname
		@cfg_line = linenum

		@max_attr_len = 0
		@valid_attr = NAG_OBJVARS[@nagobj_type]
		@attributes = Hash.new

		@nagobj_name = "NOID"
		@template_name = "NONAME"

		@inheriting = false
		@inherited = true

		# Properties
		@prop_register = true
		@prop_name = false
		@prop_use = false

	end

	# Object properties
	def is_abstract?
		not @prop_register
	end

	def is_template?
		@prop_name
	end

	def is_inheritor?
		@prop_use
	end

	def nagobj_handle
		s = "#{@nagobj_type}"
		s += " : #{@nagobj_name}" unless @nagobj_name == "NOID"
		s += " : (#{@template_name}) : t" if is_template?
		s += "a" if is_abstract?
		s
	end

	# --- Attribute methods

	# Check for presence of a named attribute
	def has_attribute?(attrname)
		@attributes.key?(attrname)
	end

	# Return named attribute	
	def get_attribute(attrname)
		@attributes[attrname]
	end
	
	# Create new attribute from text line and add to this object
	def new_attribute(linebuf, linenum)

		# Create new text attribute
		a = NagiosConfigAttribute.new(self, linebuf, linenum)
		
		# Validate attribute for this Object type
		raise "Invalid Object Attribute #{new_attr}" unless 
			a.is_custom? or 									# Don't validate custom attributes
			@valid_attr.include?(a.name) 	# Validate attribute name

		# Add attribute
		@attributes[a.name] = a

		# Adjust length for use by pretty printing
		@max_attr_len = a.name.length if a.name.length > @max_attr_len

		# Infer the identifier for this object from certain attributes
		@nagobj_name = a.value if a.name == "#{@nagobj_type}_name" or a.name == "#{@nagobj_type}_description"

		# Set object properties
		if a.name == "name"
			@template_name = a.value
			@prop_name = true
		 end 
		if a.name == "use"
			@prop_use  = true 
			@inherited = false
		end
		@prop_register = false if a.name == "register" and a.value == 0

	end

	# Add an inherited attribute to this object
	def add_attribute(a)
		return if has_attribute?(a.name)
		@attributes[a.name] = a
	end

	# Iterate over attribute array
	def each_attribute
		# Return attribute in order of valid list
		@valid_attr.each { |va|
			next unless has_attribute?(va)
			yield @attributes[va]
			}
		# Return custom attributes
		@attributes.each { |n,a|
			next unless a.is_custom?
			yield a
			}
	end

	def inherit( template_objects )

		# Raise an exception if we detect a loop
		raise "
		Inheritance loop found
		#{@nagobj_type} object #{@nagobj_name} inherits (possibly indirectly) from itself
		" if @inheriting

		# Return this object if inheritance has already been calculated for it
		return self if @inherited

		@inheriting = true		# Set marker that inheritance is in progress for this object	

		# Get ancestor list
		template_names = @attributes["use"].values

		# Get inheritance from each ancestor
		template_names.each { |tname| 
			raise "Template '#{tname}' not found for object '#{@nagobj_name}'" unless template_objects.key?(tname)

			# Get inheritance from ancestor
			template_object = template_objects[tname].inherit( template_objects )
			
			# Apply inheritance to this object
			template_object.each_attribute { |a|
				# Do not process inhertiance control attributes
				next if a.name == "name" or a.name == "use" or a.name == "register"	
				add_attribute(a)		# Add inherited attribute
				}
			}

		@inheriting = false	# Clear marker that inheritance is in progress for this object
		@inherited = true		# Set marker that inheritance is complete for this object
		return self
		
	end

	def dump_obj
		s = "#{@nagobj_type}	: #{@nagobj_name}\n"
		@attributes.each_key { |k| s += "\t[#{k}] : [#{@attributes[k].value}]\n" }
		s += "\n"
	end

	def to_s
		s = "\ndefine #{@nagobj_type}	{ \n"
		each_attribute { |a|
			s += "\t#{a.to_s(@max_attr_len)}"
			s += "\t; Inherited from #{a.template_name}" if nagobj_handle != a.nagobj_handle
			s += "\n" 
			}
		s += "\t}\n"
	end

end

# ------------------------------------------------

class NagiosConfigAttribute

	attr_reader :name, :value, :values, :cfg_line

	def initialize(nagobj,linebuf,linenum)

		@nagobj  = nagobj
		@cfg_line = linenum
	 	@multiref = false

		# Extract keyword/value pairs from raw text lines
		if linebuf =~ /^\s*([\w_]+)\s+(\d+)\s+\;.*$/		# Numeric value with comment
			@name = $1; @value = $2.to_i
		 elsif linebuf =~ /^\s*([\w_]+)\s+(\d+)\s*$/		# Numeric value without comment
			@name = $1; @value = $2.to_i
		 elsif linebuf =~ /^\s*([\w_]+)\s+(.*)\s+\;.*$/	# Line with comment
			@name = $1; @value = $2.strip
		 elsif linebuf =~ /^\s*([\w_]+)\s+(.*)$/				# Line without comment
			@name = $1; @value = $2.strip
		 elsif linebuf =~ /^\s*(\w[\w_]+)$/							# Line without value
			@name = $1; @value = nil
		 else
			raise "Unrecognised Attribute [#{linebuf}]"
		 end

		# Custom attributes begin with an underscore
		@custom = ( @name =~ /^\_/ )

		# Attribute properties
		if NAG_ATTR_MULTI.key?(@nagobj.nagobj_type) and NAG_ATTR_MULTI[@nagobj.nagobj_type].include?(@name)
			@multiref = true
			@values = @value.split(/\s*,\s*/)
		end

	end

	def is_custom?
		@custom
	end

	def is_multi?
		@multiref
	end

	# Return object's template_name
	def template_name
		@nagobj.template_name
	end

	# Return object's handle
	def nagobj_handle
		@nagobj.nagobj_handle
	end

	# Return object's id
	def nagobj_name
		@nagobj.nagobj_name
	end

	# Return object's filename
	def cfg_file
		@nagobj.cfg_file
	end

	def to_s(lj=0)
		s = "#{@name.ljust(lj)}\t#{@value}"
		if is_multi? and @values.size > 1
			s += "\t; Multi-value"
			@values.each { |v| s += "\n\t\t#{v}" }
		end
		s
	end

end

# ------------------------------------------------
