
# ------------------------------------------------
#	A collection of Nagios Events
# ------------------------------------------------
#
class NagEventStore

	def initialize()
	
		# Initialise in memory event structures
		@events = Array.new
		@openevents = Hash.new

		# Initialise stats
		@statnewcalls = 0
		@statcurrent = 0
		@statnew = 0
		@statfoundopen = 0
		@statclosed = 0

	end

	#	Convert the log entry to an event
	#
	def process_log_entry(le)
		if event_open?(le)
			ev = find_event(le)
			@statfoundopen += 1
			# Only need to take action if the state has changed
			if ev.state_change?(le)
				# Close any existing event for this log entry
				close_event(ev,le) 
				# Try to open an event with the new state
				new_event(le)
			 end
		 else
			# No open event, try to create one
			new_event(le)
		 end
	end

	def each
		@events.each { |ev| yield(ev) }
	end

	def print_stats
		puts "\nEvent statistics"
		puts " Found Events   : #@statfoundopen"
		puts " Closed Events  : #@statclosed"
		puts " New calls      : #@statnewcalls"
		puts " Current Events : #@statcurrent"
		puts " New Events     : #@statnew"
		puts " Stored Events  : #{@events.size}"
		puts " Open Events    : #{@openevents.keys.size}"
		puts
	end

	def dump_events
		puts NagEvent.csvhdr
		@events.each { |ev| puts ev.csv }
	end

	def save_events(filename)
		File.open(filename,"w") do |f| 
			f.puts NagEvent.csvhdr
			@events.each { |ev| f.puts ev.csv }
		 end
	end

 private

	# Processes a NagLog_Entry to create a NagEvent
	# (An event is only created if the log entry is not UP/OK)
	#
	def new_event(le)
		@statnewcalls += 1

		# If log entry state is OK, create an event only
		# if it is a current host/service state entry
		if le.stateOK?
			if le.current_state?
				# Open, then close, an Event in memory
				ev = NagEvent.new(le)
				ev.close(le)
				@events << ev
				@statcurrent += 1
			 end
			return 
		 end
			
		# Create new Event in memory
		@events << NagEvent.new(le)

		# Record key to new event
		@openevents[le.svckey] = @events.size - 1

		@statnew += 1
	end

	#	Close off an event
	#
	def close_event(ev,le)
		# Close existing Event in memory
		ev.close(le)
		# Clear pointer to open event
		@openevents.delete(le.svckey)
		@statclosed += 1
	end


	# Check for existing open event
	#
	def event_open?(le)
		@openevents.key?(le.svckey)
	end

	# Find an existing open event
	#
	def find_event(le)
		@events[@openevents[le.svckey]] or raise "No event found for #{le.svckey}"
	end
	
end

# ------------------------------------------------
#	A class representing a Nagios state event
# ------------------------------------------------
#
class NagEvent

	attr_reader :host, :service, :starttime, :endtime, :duration, :state
	attr_reader :hardsoft, :reason, :nextstate, :msg, :svckey

	def initialize(le)
	 	raise "Unrecognised parameter class for NagEvent.new [#{le.class}]" unless le.class == NagLogEntry
		@host, @service, @starttime, @state = le.host, le.service, le.ts, le.state
		@hardsoft, @reason, @msg = le.hardsoft, le.entrytype, le.msg
		@endtime = @duration = @nextstate = nil
		@svckey = le.svckey
	end

	def close(le)
		raise "Error: Attempt to close event for '#{@svckey}' with logentry for '#{le.svckey}'" if @svckey != le.svckey
		@endtime = le.ts
		@duration = @endtime - @starttime
		@nextstate = le.state
		self	# return this object to allow method chaining
	end

	def self.csvhdr
		c = "Host,Service,State,HardSoft,"
		c += "StartTime,EndTime,Duration,"
		c += "NextState,Reason,Message"
		c
	end
	
	def csv
		c = "#@host,#@service,#@state,#@hardsoft,"
		c += "#{showtime(@starttime)},#{showtime(@endtime)},#{@duration.nil? ? 'NULL' : @duration},"
		c += "#{@nextstate.nil? ? 'NULL' : @nextstate},#@reason,\"#@msg\""
		c
	end

	def state_change?(le)
		@state != le.state or @hardsoft != le.hardsoft
	end
	
	def showtime(ts)
		ts.class == Time ? ts.strftime("%Y/%m/%d %H:%M:%S") : 'NULL'
	end
	
end	
