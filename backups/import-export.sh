#!/bin/sh
DIR_REL=`dirname $0`
cd $DIR_REL
DIR=`pwd`
#cd -

# uses Java 6 classpath wildcards
# quotes required around classpath to prevent shell expansion
java -Xmx2048m -XX:MaxPermSize=256m -Dfile.encoding=utf8 -classpath "commons-io-2.2.jar:kettle-core-7.1.0.0-12.jar:pentaho-platform-core-7.1.0.0-12.jar:pentaho-platform-extensions-7.1.0.0-12.jar:jersey-bundle-1.19.1.jar:commons-lang-2.6.jar:commons-cli-1.2.jar:pentaho-platform-api-7.1.0.0-12.jar:commons-logging-1.1.3.jar" org.pentaho.platform.plugin.services.importexport.CommandLineProcessor ${1+"$@"}
