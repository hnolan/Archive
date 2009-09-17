CONFIG = {
	:cdb_import_files => {
		:logname => '~/logs/cdb_import_files.log',
#		:loglevel => Logger::DEBUG,
		:importdir => '~/import/cdb',
		:db_info => [ 'localhost', 'cdbapp', 'artichoke', 'cdb_dev' ]
		},
	:nag_import_files => {
#		:logname => '~/logs/nag_import_files.log',
#		:importdir => '~/import/events',
		:logname => STDOUT,
#		:loglevel => Logger::DEBUG,
		:importdir => 'E:/Dev/TestData/NagEvt',
		:db_info => [ 'localhost', 'cdbapp', 'artichoke', 'cdb_dev' ]
		}
	}
