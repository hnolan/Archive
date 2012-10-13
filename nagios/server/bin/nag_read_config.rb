# Add lib directory to load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'/../lib')

require "nagiosconfig.rb"

cf = "E:/Dev/testData/NagCW/nagios.cfg"
ps = Hash.new
ps['/usr/local/nagios/etc']="E:/Dev/testData/NagCW"


nc = NagiosConfig.new(cf,ps)

nc.report

nc.dump_obj
