CONFIG = {
	:prefix => 'STHC',
	:sysname => 'sthman3',
	:nag_export_events => {
#		:logname => '~/logs/nag_export_events.log',
#		:archivedir => '/usr/local/nagios/var/archives',
#		:eventdir => '~/export/events',
		:logname => STDOUT,
		:archivedir => 'E:/Dev/TestData/NagLogs/Test',
		:eventdir => 'E:/Dev/TestData/NagEvt',
		:maxlogs => 10
		}
	}
