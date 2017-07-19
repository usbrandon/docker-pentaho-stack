# Bind Mounts Folder

# There is a separation between content that changes and that which does not. The current best practice for docker images is to have images that do not change.
# You would not want your BI Server image to be changable once it runs; that would be a potential security hole. It would be better to have a blessed image that is known
# to be the most secure state where all modifications that yielded an image in that way are recorded in Dockerfile's and scripts.
# The information that the BI Server utilizes for its configuration, user generated content, schemas and so on should be stored outside the image in one of two ways.
#
# On one of the docker host machines as a bind mount (on its local disk and folder structure)
# Alternatively, on a named volume with a storage driver that is multi-host aware.
#
# Docker does not solve all the problems of scaling an application out horizontally. It will start multiple copies of a container and could start them on a different docker host if there are no deploy contraints
# present within the docker-compose.yml file. It is up to the application designer or system administrator to update specific application configuration to enable whatever the clustering strategy happens to be.
# 
# MySQL Sharding configuration is specific to MySQL
# Pentaho Load Balancing, sticky sessions, shared repository are specific settings to Pentaho
#
# As containers run, they need to store stateful information on disk so that if they are restarted, they can resume where they left off.
#
#
# Bind mounts are the lowest common denominator.
# They are structured as
# Service Name
# |_specific directories for holding stateful content
#
#
# The content that will appear in the above structure is fully documented in the docker-compose.yml file under volumes: for a given service.  In the format   local folder:/internal container folder

