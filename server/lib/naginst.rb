require "nagcfg.rb"

		# Fill in defaults

#		# Gather the 1:1 object instances
#		%w( timeperiod command contact contactgroup host hostextinfo hostgroup servicegroup ).each { |nagobj_type|
#			next unless @cfg_objects.key?(nagobj_type)
#			@cfg_objects[nagobj_type].each { |o|
#				next unless o.register?	# Do not instantiate config object if register is 0
#				inst = nil
#				begin
#					# Create type-specific instance from the object
#					if nagobj_type == "command" 					then inst = NagiosCommand.new(o)	
#					 elsif nagobj_type == "contact" 			then inst = NagiosContact.new(o)
#					 elsif nagobj_type == "contactgroup" 	then inst = NagiosContactGroup.new(o)
#					 elsif nagobj_type == "host" 					then inst = NagiosHost.new(o)
#					 elsif nagobj_type == "hostextinfo" 	then inst = NagiosHostExtInfo.new(o)
#					 elsif nagobj_type == "hostgroup" 		then inst = NagiosHostGroup.new(o)
#					 elsif nagobj_type == "servicegroup"  then inst = NagiosServiceGroup.new(o)
#					 elsif nagobj_type == "timeperiod"  	then inst = NagiosTimePeriod.new(o)
#					 end
#				 rescue 
#					@errors << "Object Instantiation: failed for object:\n#{o}\n[#{$!}]\n\n"
#				 end
#				@inst_data.add(inst) if inst
#				}
#			}
			
		# Gather the 1:Many object instances
#		%w( hostdependency hostescalation service serviceextinfo servicedependency serviceescalation  )
#					 elsif nagobj_type == "hostdependency"		then inst = NagiosHostDependency.new(o)
#					 elsif nagobj_type == "hostescalation"		then inst = NagiosHostEscalation.new(o)
#					 elsif nagobj_type == "service"						then inst = NagiosService.new(o)
#					 elsif nagobj_type == "servicedependency"	then inst = NagiosServiceDependency.new(o)
#					 elsif nagobj_type == "serviceescalation"	then inst = NagiosServiceEscalation.new(o)
#					 elsif nagobj_type == "serviceextinfo"		then inst = NagiosServiceExtInfo.new(o)

		#	Calculate implicit object inheritance
#	def list_instances(typ=nil)
#		@inst_data.each(typ) { |inst| puts inst.to_s }
#	end


# ------------------------------------------------

class NagiosInstanceContainer

	def initialize
		@instances = Array.new
	
		# Initialise indexes
		@indexbytype = Hash.new
		NAG_OBJTYP.each { |t| @indexbytype[t] = {} }
	
		@indexbyid = Hash.new
	end
	
	# Add a new instance to this container.
	# Index the instance for future access.	
	def add(inst)
	
		# Two instances of the same type with the same id is not allowed
		raise "Error: A #{inst.type} called #{inst.id} already exists" if @indexbytype[inst.type].key?(inst.id)
	
		# Store instance
		@instances << inst
	
		# Update indexbytype
		@indexbytype[inst.type][inst.id] = inst 
	
		# It is possible to have two instances with the same id if they are of different types
		if @indexbyid.key?(inst.id)
			curritem = @indexbyid[inst.id]
			if curritem.class == Array
				curritem << inst
			 else
				@indexbyid[inst.id] = [ curritem, inst ]
			 end
		 else
			@indexbyid[inst.id] = inst
		 end
		 
	end
	
	def get_by_id(i)
		@indexbyid[i]
	end
	
	def each(typ=nil)
		if typ
			@indexbytype[typ].each {|k,i| yield i }
		 else
			@instances.each {|i| yield i }
		 end
	end

end

# ------------------------------------------------

# Ancestor class for all classes of nagios instances
class NagiosInstance

	attr_reader :type, :id
	
	def initialize( cfg_obj )
		@cfg_obj = cfg_obj
		@type = @cfg_obj.objtype
		@id = "Not Set"
	end

	def get_list(txt)
		txt.split(/\s*,\s*/)
	end
	
	def to_s
		s = "#{@type}\t#{@id}"
	end

end

# ------------------------------------------------
class NagiosCommand < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("command_name").value
	end

end

# ------------------------------------------------
class NagiosContact < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("contact_name").value
	end

end

# ------------------------------------------------
class NagiosContactGroup < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("contactgroup_name").value
	end

end

# ------------------------------------------------
class NagiosHost < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("host_name").value
	end

end

# ------------------------------------------------
class NagiosHostDependency < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = "Not Set"
	end

end

# ------------------------------------------------
class NagiosHostEscalation < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("host_name").value
	end

end

# ------------------------------------------------
class NagiosHostExtInfo < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("host_name").value
	end

end

# ------------------------------------------------
class NagiosHostGroup < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("hostgroup_name").value
	end

end

# ------------------------------------------------
class NagiosService < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = "Not Set"
	end

end

# ------------------------------------------------
class NagiosServiceDependency < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = "Not Set"
	end

end

# ------------------------------------------------
class NagiosServiceEscalation < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = "Not Set"
	end

end

# ------------------------------------------------
class NagiosServiceExtInfo < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = "Not Set"
	end

end

# ------------------------------------------------
class NagiosServiceGroup < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("servicegroup_name").value
	end

end

# ------------------------------------------------
class NagiosTimePeriod < NagiosInstance

	def initialize( cfg_obj )
		super
		@id = @cfg_obj.get_attribute("timeperiod_name").value
	end

end

# ------------------------------------------------
