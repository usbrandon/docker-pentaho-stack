This directory only pertains to the inital startup of a Pentaho Docker Stack
Upon first run the bind mount exposed to the mariadb:10.3 image will pick up the
scripts in the specially named directory and execute them in alphabetical order.

- Goals
   - Establish database users for Quartz, JCR Repository, Hibernate and Sampledata
   - Load sampledata
