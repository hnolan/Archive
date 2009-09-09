CONFIG = {
	:prefix => 'IMJA',
	:sysname => 'dev01',
	:nag_export_events => {
		:logname => '~/logs/nag_export_events.log',
#		:archivedir => '/usr/local/nagios/var/archives',
		:archivedir => '~/tmp',
		:eventdir => '~/export/events',
		:maxlogs => 15
		}
	}
