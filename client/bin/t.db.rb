#!/usr/bin/ruby -w
# simple.rb - simple MySQL script using Ruby DBI module

gem 'dbi'
require 'dbi'

# puts $:

begin
	# connect to the MySQL server
	dbh = DBI.connect("DBI:Mysql:nagios:localhost", "naglog", "nagios")


	sql = "INSERT INTO events (host,service,state,hardsoft,starttime,endtime,duration,nextstate,reason,message) "
	sql += " VALUES ('host','svc','DOWM','SOFT','2009-03-25 10:00:00','2009-03-25 10:01:00',60,'UP','TESTONLY','No message')"
	rc = dbh.do(sql)
	puts "Rows affected: #{rc}"

	# Do DB stuff
	rows = dbh.select_all("SELECT * FROM events")
	puts "Row Count: #{rows.size}"

rescue DBI::DatabaseError => e
	puts "An error occurred"
	puts "Error code: #{e.err}"
	puts "Error message: #{e.errstr}"
ensure
	# disconnect from server
	dbh.disconnect if dbh
end

