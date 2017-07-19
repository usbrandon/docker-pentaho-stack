#!/bin/sh
# Create backups of the MySQL database for the docker solution stack
# Author: Brandon Jackson
# Email : usbrandon@gmail.com
# ---------------------------------------------------------------------------------------------------------
 
## date format ##
NOW=$(date +"%F")
NOWT=$(date +"__%H_%M_%S")
 
## Backup path ##
BAK="./mariadb/$NOW"
if [ -d $BAK ]; then
	echo "Backup folder exists. Proceeding with backup."
else
	echo "Creating folder $BAK"
	mkdir $BAK
	if [ -d $BAK ]; then
		echo "Successfully created $BAK"
	else
		echo "Failed to create $BAK"
		exit 1
	fi
fi

## Login info ##
MUSER="root"
read MPASS < ../secrets/mariadb_root_password
MHOST="127.0.0.1"
 
## Binary path ##
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
GZIP="/bin/gzip"
 

## Get database list ##
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
 
## Use shell loop to backup each db ##
for db in $DBS
do
   FILE="$BAK/mysql-$db-$NOW$NOWT.gz"
   echo "Creating backup of $db."
   echo "$BAK/mysql-$db-$NOW$NOWT.gz"
   # echo "$MYSQLDUMP -u $MUSER -h $MHOST -p(hidden_password) $db | $GZIP -9 > $FILE"
   $MYSQLDUMP --single-transaction -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done
