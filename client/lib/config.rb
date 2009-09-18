CONFIG = {
	:prefix => ENV['SA_PREFIX'] || 'XXXX',
	:sysname => ENV['SA_SRCSRV'] || 'nohost',
	:nag_export_events => {
		:logname => '~/logs/nag_export_events.log',
		:archivedir => '/usr/local/nagios/var/archives',
		:eventdir => '~/export/events',
		:maxlogs => 5
		}
	}
