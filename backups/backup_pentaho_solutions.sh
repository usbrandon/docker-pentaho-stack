#!/bin/sh
# Creates a backup of the user content, schemas, connections and user created repository content
# and it stores is in the ./pentaho/yyyy-MM-dd/pentaho_content_date_time.zip
#
# Author: Brandon Jackson
# Email : usbrandon@gmail.com
# ---------------------------------------------------------------------------------------------------------

echo "----------------------------------------------------------------------------------------"
echo "Backing up user created Pentaho Content (Mondrian scheams, Dashboards, Connections, etc)"
echo "----------------------------------------------------------------------------------------"
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR} 
if [ -f ../secrets/pentaho_admin_user ]; then
	echo "../secrets/pentaho_admin_user found.     Great!"
else
        echo -n "Please enter a user name with Pentaho Administrative privileges and press [enter]:"
	read P_USER
	echo ${P_USER} > ../pentaho_admin_user
fi

if [ -f ../secrets/pentaho_admin_password ]; then
	echo "../secrets/pentaho_admin_password found. Super!"
else
	echo -n "Please enter the Pentaho Admin user's password and press [ENTER]:"
	read P_PASS
	echo ${P_PASS} > ../pentaho_admin_password
fi

if [ -f ../secrets/pentaho_server_url ]; then
	echo "../secrets/pentaho_server_url found.     Fantastic!"
else
	echo "Enter the fully qualified URL to your pentaho server, including /pentaho and press [ENTER]"
	echo -n "Server URL: "
	read P_URL
	echo ${P_URL} > ../secrets/pentaho_server_url
fi

## date format ##
NOW=$(date +"%F")
NOWT=$(date +"__%H_%M_%S")

## Backup path ##
BAK="./pentaho/$NOW"
if [ -d $BAK ]; then
        echo "Backup folder exists. Proceeding with backup."
else
        echo "Creating folder $BAK"
        mkdir $BAK
        if [ -d $BAK ]; then
                echo "Successfully created $BAK"
	        echo "Launching the Pentaho import-export.sh script to backup Pentaho User Content"
        else
                echo "Failed to create $BAK"
                exit 1
        fi
fi

## Login info ##
read PENTAHO_USER < ../secrets/pentaho_admin_user
read PENTAHO_PASS < ../secrets/pentaho_admin_password
read PENTAHO_URL  < ../secrets/pentaho_server_url

./import-export.sh --backup --url=${PENTAHO_URL} --username=${PENTAHO_USER} --password=${PENTAHO_PASS} --file-path=./pentaho/${NOW}/pentaho_content_${NOW}${NOWT}.zip --logfile=./pentaho/pentaho-content-backup.log
