
# ------------------------------------------------
#	A class representing a Nagios log file entry
# ------------------------------------------------
#
class NagLogEntry

	attr_reader :ts, :host, :service, :entrytype, :body
	attr_reader :extcmd, :rc, :msg, :state, :hardsoft, :svckey
	
	def initialize(logline)

		# Initialise instance variables
		@uxtime = 0
		@host = @service = ''
		@stateful = @current_state = false

		if logline =~ /^\[(\d{10})\]\s+(\w[\w\s]+)\:\s+(.*)/
			# Handle standard format entry
			@uxtime = $1; @entrytype = $2; @body = $3
			parse_entry(@body)
		 elsif logline =~ /^\[(\d{10})\]\s+(.*)/
			# Handle non-standard timestamped entry
			@uxtime = $1; @entrytype = "NONE"; @body = $2
			parse_nonstd_entry(@body)
		 else		
		 	# Handle non-timestamped entry
			raise "Unexpected line: #{logline}"
		 end

		@ts = Time.at(@uxtime.to_i)
		@svckey = "#@host:#@service"

	end

	# Class method to write out CSV header
	def self.csvhdr
		c = "EntryTime,EntryType,ExtCmd,Host,Service,"
		c += "Attempt,RC,State,HS,Message,"
		c += "Contact,Command,AckAuthor,AckData,"
		c
	end

	# Instance method to write out this log entry as CSV	
	def csv
		c = "#{entrytime},#@entrytype,#@extcmd,#@host,#@service,"
		c += "#@attempt,#@rc,#@state,#@hardsoft,\"#@msg\","
		c += "#@contact,#@command,#@ack_author,#@ack_data,"
		c
	end
	
	def to_s
		"\t#{entrytime}\t#@entrytype\t#@state\t#@host\t#@service"
	end
	
	def entrytime
		@ts.class == Time ? @ts.strftime("%Y/%m/%d %H:%M:%S") : ''
	end

	def stateful?
		@stateful
	end

	def current_state?
		@current_state
	end

	def stateOK?
		stateful? and ( @state == "OK" or @state == "UP" )
	end

 private
 	
 	def parse_entry( body )

		# Strip off any trailing perfdata
		bodydata, @perfdata = body.split(/\s*\|\s*/)

		# Split data into an array of params
		entryparams = bodydata.split(';')

		case @entrytype
		 when "EXTERNAL COMMAND"
				parse_external_command( entryparams )
		 when "SERVICE ALERT"
			( @host, @service, @state, @hardsoft, @attempt, @msg ) = entryparams
			@stateful = true
		 when "PASSIVE SERVICE CHECK"
			( @host, @service, @rc, @msg ) = entryparams
		 when "CURRENT SERVICE STATE"
			( @host, @service, @state, @hardsoft, @attempt, @msg ) = entryparams
			@stateful = @current_state = true
		 when "CURRENT HOST STATE"
			( @host, @state, @hardsoft, @attempt, @msg ) = entryparams
			@stateful = @current_state = true
		 when "HOST ALERT"
			( @host, @state, @hardsoft, @attempt, @msg ) = entryparams
			@stateful = true
		 when "Warning"
				parse_warning(@body)
		 when "PASSIVE HOST CHECK"
			( @host, @rc, @msg ) = entryparams
		 when "SERVICE NOTIFICATION"
			( @contact, @host, @service, @state, @command, @msg, @ack_author, @ack_data ) = entryparams
		 when "HOST NOTIFICATION"
			( @contact, @host, @state, @command, @msg, @ack_author, @ack_data ) = entryparams
		 when "LOG ROTATION", "LOG VERSION"
			# Do nothing for these
		 when "ndomod"
			raise body if body =~ /error/i
		 else
			raise "Unrecognised log entry [#@entrytype]: #{body}"
		 end
	
		@rc = @rc.to_i unless @rc.nil?
		@attempt = @attempt.to_i unless @attempt.nil?

 	end

 	def parse_external_command( cmdparams )
	  @extcmd = cmdparams.shift
		case @extcmd
		 when "PROCESS_SERVICE_CHECK_RESULT"
			( @host, @service, @rc, @msg ) = cmdparams
		 when "PROCESS_HOST_CHECK_RESULT"
			( @host, @rc, @msg ) = cmdparams
		 when "ACKNOWLEDGE_SVC_PROBLEM"
			( @host, @service, @i1, @i2, @i3, @ack_author, @ack_data ) = cmdparams
		 when "ACKNOWLEDGE_HOST_PROBLEM"
			( @host, @i1, @i2, @i3, @ack_author, @ack_data ) = cmdparams
		 else
			raise "Unrecognised external command, '#@extcmd': #{cmdparams.join(';')}"
		 end
	end
	
 	def parse_warning( body )
		if body =~ /service \'(.*)\' on host \'(.*)\'/
			@host = $2; @service = $1
		 elsif body =~ /host \'(.*)\'/
			@host = $1
		 end
	end
	
 	def parse_nonstd_entry( body )
		case 
		 when body =~ /^Auto-save of retention data/
		 when body =~ /^Caught SIGTERM/
		 when body =~ /^Successfully shutdown/
		 when body =~ /^Event broker module/
		 when body =~ /^Nagios \d\.\d\.\d starting/
		 when body =~ /^Local time is/
		 when body =~ /^Finished daemonizing/
		 else	raise "Unrecognised log message: #{body}"
		 end
	end

end

# ------------------------------------------------
#	A class representing a Nagios log file
# ------------------------------------------------
#
class NagLogFile

	attr_reader :vars, :hosts, :warnings, :events, :errors, :strange

	def initialize(fname)

		@filename = fname

		@logentries = Array.new
		@logtypes = Hash.new(0)
		@errors = Array.new
		@warnings = Hash.new(0)
		@strange = Array.new

		File.open(fname) do |@f|

			while fileline = @f.gets

				# Ignore very noisy diagnostic log entries
				#
				next if fileline =~ /\] EXTERNAL COMMAND: / or 
								fileline =~ /\] PASSIVE SERVICE CHECK: / or
								fileline =~ /\] PASSIVE HOST CHECK: /

				begin
					le = NagLogEntry.new(fileline.chomp)
					et = le.entrytype
				rescue
					if $!.message =~ /^Unrecognised/
						@strange << "Line #{@f.lineno}: #{$!}"
					 else
						@errors << "Error at line #{@f.lineno}: #{$!}"
					 end
					next
				end
	
				@logentries << le
				@logtypes[le.entrytype] += 1
				@warnings[le.body] += 1 if et == "Warning"

			end

		end

	end

	def each
		@logentries.each { |le| yield le }
	end

	def each_stateful
		@logentries.each { |le| yield le if le.stateful? }
	end

	def print_type_stats
		puts "Found #{@logtypes.keys.size} log entry types"
		@logtypes.each { |k,v| puts "#{v.to_s.rjust(8)}\t#{k}" }
	end

	def print_warn_stats
		puts "Found #{@warnings.keys.size} warnings"
		@warnings.each { |k,v| puts "#{v.to_s.rjust(8)}\t#{k}" }
	end

end

