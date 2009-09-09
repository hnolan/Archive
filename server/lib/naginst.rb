require "nagcfg.rb"

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
