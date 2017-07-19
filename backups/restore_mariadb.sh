#!/bin/sh
# Restor from backups of the MySQL database for the docker solution stack
# Author: Brandon Jackson
# Email : usbrandon@gmail.com
# ---------------------------------------------------------------------------------------------------------
 
 
## Login info ##
MUSER="root"
read MPASS < ../secrets/mariadb_root_password
MHOST="127.0.0.1"
 
## Binary path ##
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
GUNZIP="/bin/gunzip"
 

## Get database list ##
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
 
## Use shell loop to backup each db ##
for f in ./mariadb/2017-07-17/*.gz;
do
   echo "Restoring backup file $f."
   db=`expr match "$f" '.*mysql-\([A-Za-z\-\_]*\)-.*'`
   echo "Destination is schema $db."
   # echo "$MYSQLDUMP -u $MUSER -h $MHOST -p(hidden_password) $db | $GZIP -9 > $FILE"
   $GUNZIP -c $f | $MYSQL -u $MUSER -h $MHOST -p$MPASS $db 
done
