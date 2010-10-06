#
# The NagCfg_File class represents a single Nagios text configuration file
# These config files can be main files or object configuration files.
# 
#	Although the NagCfg_File class can validate the variable and declaration names
# using the data held in the info module, it only understands the lexical and structural
# rules outlined below, and in no way infers any meaning from the variables and
# objects that it reads. It stores the information extracted from the files 
# as arrays of NagCfg_Variable or NagCfg_Object items.
#
# Any syntax errors encountered while reading a config file are recorded in 
# an array and can be processed subsequently.
#
# Main files
#
# These consist of a list of keyword=value pairs, with the following
# general rules for content:
#		Any lines starting with hash (#) are comments and can be ignored
#		Any lines which are blank or consist only of whitespace can be ignored
#		The keyword=value pairs must start in the first character of a line
#			( no whitespace is allowed before the keyword )
#		Trailing whitespace is not significant (it is stripped)
#
# Object configuration files 
#
# These consist of a series of object definitions. An object definition is
# of the form:
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

# Import object and variable definition data
#
require "nagcfginfo.rb"

#=====================================================================
#		Nagios Main Config File
#=====================================================================
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
					@vars << NagiosConfigFileVariable.new(linebuf, fname, linenum)
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

class NagiosConfigFileVariable

	attr_reader :name, :value, :cfgfile, :cfgline

	def initialize(txt,fname,linenum)

		@cfgfile = fname
		@cfgline = linenum

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
#		Nagios Object Config File
#=====================================================================
#

class NagiosConfigObjectFile

	attr_reader :filename, :obj_count

	def initialize(fname,locname=nil)

		@filename = fname
		@objs = Array.new
		@errors = Array.new

		@f = File.open(locname ? locname : fname)

		linenum = 0; linebuf = ""; 
		objtype = nil; objlinenum = 0
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

					objtype = $1

					# Start of object definition - create the new object
					begin
						curr_obj = NagiosConfigFileObject.new(objtype, fname, linenum)
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
			puts "#{o.objtype} : name = #{o.name}"
			}
		
		puts "\n\n#=============================\n"
		puts "# Normal Template Objects\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next unless o.is_template? and not o.is_abstract?
			puts "#{o.objtype} : name = #{o.name} : #{o.objid}"
			}
		
		puts "\n\n#=============================\n"
		puts "# Inheritor Objects\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next unless o.is_inheritor? and not o.is_template?
			puts "#{o.objtype} : #{o.objid}"
			puts "\t#{o.attributes['use']}"
			}
		
		puts "\n\n#=============================\n"
		puts "# Non Inheritor Objects\n"
		puts "#=============================\n\n"
		@objs.each { |o|
			next if o.is_inheritor? or o.is_template?
			puts "#{o.objtype} : #{o.objid}"
			}

	end

end

# ------------------------------------------------

class NagiosConfigFileObject

	attr_reader :objtype, :cfgfile, :cfgline
	attr_reader :attributes, :objid, :name

	def initialize(objtype,fname,linenum)

		# Validate object type
		raise "Unrecognised Object type [#{objtype}]" unless NAG_OBJVARS.key?(objtype)

		# Initialise variables
		@objtype = objtype
		@cfgfile = fname
		@cfgline = linenum

		@max_attr_len = 0
		@valid_attr = NAG_OBJVARS[@objtype]
		@attributes = Hash.new

		@objid = "NOID"
		@name = "NONAME"

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

	# --- Attribute methods

	# Check for presence of a named attribute
	def has_attribute?(attrname)
		@attributes.key?(attrname)
	end

	# Return named attribute	
	def get_attribute(attrname)
		@attributes[attrname]
	end
	
	# Create new attribute and add to this object
	def new_attribute(linebuf, linenum)

		# Create new text attribute
		a = NagiosConfigFileAttribute.new(self, linebuf, linenum)
		
		# Validate attribute for this Object type
		raise "Invalid Object Attribute #{new_attr}" unless 
			a.custom or 									# Don't validate custom attributes
			@valid_attr.include?(a.name) 	# Validate attribute name

		# Add attribute
		@attributes[a.name] = a

		# Adjust length for use by pretty printing
		@max_attr_len = a.name.length if a.name.length > @max_attr_len

		# Infer the identifier for this object from certain attributes
		@objid = a.value if a.name == "#{@objtype}_name" or a.name == "#{@objtype}_description"

		# Set object properties
		if a.name == "name"
			@name = a.value
			@prop_name = true
		 end 
		@prop_use  = true if a.name == "use"
		@prop_register = false if a.name == "register" and a.value == 0

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
			next unless a.custom
			yield a
			}
	end

	def dump_obj
		s = "#{@objtype}	: #{@objid}\n"
		@attributes.each_key { |k| s += "\t[#{k}] : [#{@attributes[k].value}]\n" }
		s += "\n"
	end

	def to_s_d
		s = "#{@objtype}	: #{@objid}"
	end

	def to_s
		s = "\ndefine #{@objtype}	{ \n"
		each_attribute { |a|
			s += "\t#{a.to_s(@max_attr_len)}"
			s += "\n" 
			}
		s += "\t}\n"
	end

end

# ------------------------------------------------

class NagiosConfigFileAttribute

	attr_reader :name, :value, :values, :cfgobj, :cfgline, :custom

	def initialize(cfgobj,linebuf,linenum)

		@cfgobj  = cfgobj
		@cfgline = linenum
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
		if NAG_ATTR_MULTI.key?(@cfgobj.objtype) and NAG_ATTR_MULTI[@cfgobj.objtype].include?(@name)
			@multiref = true
			@values = @value.split(/\s*,\s*/)
		end

	end

	def is_multi?
		@multiref
	end

	# Return text object's filename
	def cfgfile
		@cfgobj.cfgfile
	end

	def to_s_d(x)
		s = "[#{@name}] : [#{@value}]"
	end

	def to_s(lj=0)
		s = "#{@name.ljust(lj)}\t#{@value}"
		if is_multi?
			s += "\t; Multi-value"
			@values.each { |v| s += "\n\t\t#{v}" } 
		end
		s
	end

end

# ------------------------------------------------

## ------------------------------------------------
#
#class NagCfg_Object
#
#	attr_reader :objtype, :cfgfile, :cfgline, :objid, :name
#
#	def initialize(objtype,objattr,fname,linenum)
#
#		# Validate object type
#		raise "Unrecognised NagCfg_Object type [#{objtype}]" unless NAG_OBJVARS.key?(objtype)
#
#		# Initialise variables
#		@valid_attr = NAG_OBJVARS[objtype]
#		@max_attr_len = 0
#		@objtype = objtype
#		@cfgfile = fname
#		@cfgline = linenum
#		@attributes = Hash.new
#
#		# Add collected attributes
#		objattr.each { |a| add_attribute(a) }
#
#		# Infer the identifier for this object
#		if has_attribute?("#{@objtype}_name")
#			@objid = get_attribute("#{@objtype}_name").value
#		 elsif has_attribute?("#{@objtype}_description")
#			@objid = get_attribute("#{@objtype}_description").value
#		 else
#			@objid = "NONAME"
#		 end
#
#		if has_name?
#			@name = get_attribute("name").value 
#			each_attribute { |a| a.objname = @name }
#		 end
#			
#		@inheriting = false
#		@inherited = has_use? ? false : true
#
#	end
#
#	def has_name?
#		has_attribute?("name")
#	end
#
#	def has_use?
#		has_attribute?("use")
#	end
#
#	def register?
#		# Register the object unless register attribute is explicitly set to 0
#		!( has_attribute?("register") and get_attribute("register").value == 0 )
#	end
#
#	def inherit( named_objects )
#
#		raise "
#		Inheritance loop found
#		#{@objtype} object #{@objid} inherits (possibly indirectly) from itself
#		" if @inheriting
#
#		# Return this object if inheritance has already been calculated for it
#		return self if @inherited
#
#		@inheriting = true		# Set marker that inheritance is in progress for this object	
#
#		# Get ancestor list
#		ancestor_names = get_attribute("use").value.split(/\s*,\s*/)
#
#		# Get inheritance from each ancestor
#		ancestor_names.each { |ancname| 
#			raise "Ancestor not found" unless named_objects.key?(ancname)
#
#			# Get inheritance from ancestor
#			ancestor_object = named_objects[ancname].inherit( named_objects )
#			
#			# Apply inheritance to this object
#			ancestor_object.each_attribute { |ancattr|
#				# Do not process inhertiance control attributes
#				next if ancattr.name == "name" or ancattr.name == "use" or ancattr.name == "register"	
#				add_attribute(ancattr,"inherited")		# Add inherited attribute
#				}
#			}
#
#		@inheriting = false	# Clear marker that inheritance is in progress for this object
#		@inherited = true		# Set marker that inheritance is complete for this object
#		return self
#		
#	end
#
#	# --- Attribute methods
#
#	# Check for presence of a named attribute
#	def has_attribute?(attrname)
#		@attributes.key?(attrname)
#	end
#
#	# Return named attribute	
#	def get_attribute(attrname)
#		@attributes[attrname][0]
#	end
#	
#	# Add new attribute to this object
#	def add_attribute(attrib,scope="local")
#
#		# Prevent existing attributes from being overwritten
#		return if has_attribute?(attrib.name)
#
#		# Validate attribute for this Object type
#		raise "Invalid Object Attribute #{attrib}" unless 
#			attrib.custom or 										# Don't validate custom attributes
#			@valid_attr.include?(attrib.name) 	# Validate attribute name
## @objtype == "timeperiod" or 
#
#		# Add attribute with its scope specifier
#		@attributes[attrib.name] = [ attrib, scope ]
#
#		# Adjust length for use by pretty printing
#		@max_attr_len = attrib.name.length if attrib.name.length > @max_attr_len
#
#	end
#
#	# Iterate over attribute array
#	def each_attribute(scope="")
#		# Return attribute in order of valid list
#		@valid_attr.each { |va|
#			next unless has_attribute?(va)
#			yield @attributes[va][0] if scope == "" or @attributes[va][1] == scope
#			}
#		# Return custom attributes
#		@attributes.each { |a|
#			next unless a[1][0].custom
#			yield a[1][0] if scope == "" or a[1][1] == scope
#			}
#	end
#
#	# --- End attribute methods
#
#	def dump_obj
#		s = "#{@objtype}	: #{@objid}\n"
#		@attributes.each_key { |k| s += "\t[#{k}] : [#{@attributes[k].value}]\n" }
#		s += "\n"
#	end
#
#	def to_s_d
#		s = "#{@objtype}	: #{@objid}"
#	end
#
#	def to_s
#		s = "\ndefine #{@objtype}	{ \n"
#		each_attribute { |a|
#			s += "\t#{a.to_s(@max_attr_len)}"
#			s += "\t\t; inherited from #{a.objname}" if a.objname != @name
#			s += "\n" 
#			}
#		s += "\t}\n"
#	end
#
#end
#
## ------------------------------------------------
#
#class NagCfg_Attribute
#
#	attr_reader :name, :value, :cfgfile, :cfgline, :custom
#	attr_accessor :objname
#
#	def initialize(txt,linenum)
#
#		@txt = txt
#		@cfgobj = fname
#		@cfgline = linenum
#
#		@objname = nil
#
#		# Extract keyword/value pairs from raw text lines
#		if txt =~ /^\s*([\w_]+)\s+(\d+)\s+\;.*$/		# Numeric value with comment
#			@name = $1; @value = $2.to_i
#		 elsif txt =~ /^\s*([\w_]+)\s+(\d+)\s*$/		# Numeric value without comment
#			@name = $1; @value = $2.to_i
#		 elsif txt =~ /^\s*([\w_]+)\s+(.*)\s+\;.*$/	# Line with comment
#			@name = $1; @value = $2.strip
#		 elsif txt =~ /^\s*([\w_]+)\s+(.*)$/				# Line without comment
#			@name = $1; @value = $2.strip
#		 elsif txt =~ /^\s*(\w[\w_]+)$/							# Line without value
#			@name = $1; @value = nil
#		 else
#			raise "Unrecognised NagCfg_Attribute [#{@txt}]"
#		 end
#
#		# Custom attributes begin with an underscore
#		@custom = ( @name =~ /^\_/ )
#
#	end
#
#	# Set parent object
#	def set_obj(o)
#		@cfgobj = o
#	end
#
#	# Return object's filename
#	def cfgfile
#		@cfgobj.cfgfile
#	end
#
#	def to_s_d(x)
#		s = "[#{@name}] : [#{@value}]"
#	end
#
#	def to_s(lj=0)
#		s = "#{@name.ljust(lj)}\t#{@value}"
#	end
#
#end
#
## ------------------------------------------------
