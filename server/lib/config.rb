CONFIG = {
	:cdb_import_files => {
#		:logname => '~/logs/cdb_import_files.log',
#		:importdir => '~/import/cdb',
		:logname => STDOUT,
		:importdir => 'E:/Dev/TestData/NagEvt',
		:db_info => [ 'localhost', 'cdbapp', 'artichoke', 'cdb_dev' ]
		}
	}
