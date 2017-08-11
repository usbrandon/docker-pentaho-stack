#!/bin/sh
# Create backups of the Docker Volumes for the solution stack
#    Todo:
#      *  Identify and Backup only volumes for the particular stack
# Author: Brandon Jackson
# Email : usbrandon@gmail.com
# ---------------------------------------------------------------------------------------------------------

## date format ##
NOW=$(date +"%F")
NOWT=$(date +"__%H_%M_%S")

## Backup path ##
BAK="./dockervolumes/$NOW"
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
														
sudo tar czvf ${BAK}/container_volumes_${NOW}${NOWT}.tar.gz /var/lib/docker/volumes
