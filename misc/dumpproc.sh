PWD=passport
CWD=/home/huw/dev/cdb

DUMPDIR=/home/huw/dev/mysql/procs
DST=/home/huw/dev/cdb/db

# Clear the temporary holding directory
rm -f $DUMPDIR/*.sql

# Dump the procedure code and params
mysql -p$PWD -u root -e "call cdb_utils.dump_code()"

# Combine dumped fragments and store under parent DB
cd $DUMPDIR

for CodeFile in `ls cdb_dev.*.code.sql cdb_test.*.code.sql cdb_utils.*.code.sql`
 do
	# Parse filename to extract fields
	#
	DB=`echo $CodeFile | cut -d'.' -f1`
	ProcName=`echo $CodeFile | cut -d'.' -f2`
	PramFile=$DB.$ProcName.param.sql
	NewFile=$DST/$DB/procs/$ProcName.sql

	# Output the new file
	#
	echo "DELIMITER \$\$" >$NewFile
	echo "" >>$NewFile
	echo "DROP PROCEDURE IF EXISTS \`$DB\`.\`$ProcName\` \$\$" >>$NewFile
	echo -n "CREATE DEFINER=\`root\`@\`localhost\` PROCEDURE \`$ProcName\` (" >>$NewFile
	cat $PramFile | tr -d "\r" >>$NewFile
	echo ")" >>$NewFile
	cat $CodeFile | tr -d "\r" >>$NewFile
	echo " \$\$" >>$NewFile
	echo "" >>$NewFile
	echo "DELIMITER ;" >>$NewFile

	echo "Created file : $NewFile"

 done

