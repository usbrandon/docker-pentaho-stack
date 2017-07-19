#
# Backups folder
#

The Pentaho solution stack stores files in a combination of bind mounts and named volumes.
Not everything in a bind mount is precious; for example the tomcat logs for the Pentaho Business Intelligence server
are probably worth keeping on disk for easy reference, but not necessairly worth making persistent backups of.
The repository database on the otherhand is critical to keeping a copy of user created content on the Pentaho BA server
and Wordpress site.

The structure here is:

Service Name
|_ ISO date folder
   |_ files with ISO Date + time in the name

Scripts that perform the actual backup and restore work stay in this base folder.

