CONFIG = {
	:prefix => 'XXXX',
	:sysname => 'dev01',
	:nag_export_events => {
#		:logname => '~/logs/nag_export_events.log',
#		:archivedir => '/usr/local/nagios/var/archives',
#		:eventdir => '~/export/events',
		:logname => STDOUT,
		:archivedir => 'E:/Dev/TestData/NagLogs/Test',
		:eventdir => 'E:/Dev/TestData/NagLogs/Test/events',
		:maxlogs => 1
		}
	}
