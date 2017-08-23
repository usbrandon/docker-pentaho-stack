#
# Docker image for Pentaho BA server community edition.
#

# Pull base image
# Its Dockerfile is at https://github.com/usbrandon/docker-java
FROM usbrandon/java:8

# Set maintainer

MAINTAINER Brandon Jackson <usbrandon@gmail.com>
# Greatly inspired and adapted by Zhichun Wu's CE BI image
#   Improvements made in the area of image structure, updates, permissions, named volumes, backup and restore scripts 
# Todos:
#   1. Build the APR better based on the official build.  Errors crop up about a shared library
#   2. Use the new shared build feature to pull from maven and build CE tags and deploy CE images
#   3. Further separate last mile configurations in docker-entrypoint.sh instead of baking them into the image. (generic usability)

# Set environment variables
#  - Adapting the build environment similar to CBF2

ENV BISERVER_VERSION=7.1 BISERVER_BUILD=7.1.0.3-54 PDI_PATCH=7.0.0.0.3 \
	BISERVER_HOME=/pentaho/pentaho-server BISERVER_USER=pentaho \
        KETTLE_HOME=/home/pentaho \
#	KETTLE_HOME=/pentaho-server/pentaho-solutions/system/kettle \
	 CASSANDRA_DRIVER_VERSION=0.6.3 \
              JTDS_DRIVER_VERSION=1.3.1 \
             MYSQL_DRIVER_VERSION=5.1.42 \  
	POSTGRESQL_DRIVER_VERSION=9.4.1212 \
           VERTICA_DRIVER_VERSION=7.1.2-0 \
	H2DB_VERSION=1.4.195 HSQLDB_VERSION=2.4.0 XMLA_PROVIDER_VERSION=1.0.0.103 

# Set label

LABEL java_server="Pentaho BA Server ${BISERVER_VERSION} Community Edition"

# Install vanilla Pentaho server along with minor changes to configuration

ADD /image-init-files/biserver/software/pentaho-server-ce-7.1.0.3-54.zip software/
RUN echo "Unpack Pentaho server..." \
	&& unzip -q software/*.zip -d /pentaho \
	&& rm -rf software \
	&& find $BISERVER_HOME -name "*.bat" -delete \
	&& find $BISERVER_HOME -name "*.exe" -delete \
	&& mkdir -p $BISERVER_HOME/data/.hsqldb \
	&& /bin/cp -rf $BISERVER_HOME/data/hsqldb/* $BISERVER_HOME/data/.hsqldb/. \
		&& apt-get update \
	&& echo "Installing xvfb to support Pentaho Reporting Engine running in systems without X11" \
		# https://help.pentaho.com/Documentation/7.1/Installation/Archive/015_Prepare_linux_environment
		# To generate charts, the Pentaho Reporting engine requires functions found in X11. If you are unwilling or unable to install an X server, you can install the xvfb package instead.
		# The xvfb package provides the X11 framebuffer emulation, which performs all graphical operations in the memory rather than sending them to the screen. 
		&& apt-get install -y xvfb \
	&& echo "Install APR for Tomcat..." \
		&& tar zxf $BISERVER_HOME/tomcat/bin/tomcat-native.tar.gz \
		&& cd tomcat-native*/native \
		# Dependencies to build the APR for Tomcat.
		&& apt-get install -y libapr1-dev gcc make \
		&& ./configure --with-apr=/usr/bin/apr-config --disable-openssl --with-java-home=$JAVA_HOME --prefix=$BISERVER_HOME/tomcat \
		&& make \
		&& make install \
		&& sed -i -e 's|\(SSLEngine="\).*\("\)|\1off\2|' \
			-e 's|\(<Engine name="Catalina" defaultHost="localhost">\)|\1\n      <Valve className="org.apache.catalina.valves.RemoteIpValve" internalProxies=".*" remoteIpHeader="x-forwarded-for" remoteIpProxiesHeader="x-forwarded-by" protocolHeader="x-forwarded-proto" />|' $BISERVER_HOME/tomcat/conf/server.xml \
		&& cd / \
		&& rm -rf tomcat-native* $BISERVER_HOME/tomcat/bin/tomcat-native.tar.gz \
		&& apt-get autoremove -y libapr1-dev gcc make \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* \
	&& echo "Update server configuration..." \
		&& cd $BISERVER_HOME \
		&& sed -i -e 's/\(exec ".*"\) start/\1 run/' tomcat/bin/startup.sh \
		&& rm -f promptuser.* pentaho-solutions/system/default-content/* \
		&& sed -i -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">\n        <extension>xlsx</extension>\n      </MimeTypeDefinition>\n\1|' \
  		          -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.template">\n        <extension>xltx</extension>\n      </MimeTypeDefinition>\n\1|' \
			  -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.ms-excel.sheet.macroEnabled.12">\n        <extension>xlsm</extension>\n      </MimeTypeDefinition>\n\1|' \
			  -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.ms-excel.template.macroEnabled.12">\n        <extension>xltm</extension>\n      </MimeTypeDefinition>\n\1|' \
			  -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.ms-excel.addin.macroEnabled.12">\n        <extension>xlam</extension>\n      </MimeTypeDefinition>\n\1|' \
			  -e 's|\(      <MimeTypeDefinition mimeType="application/vnd.ms-excel">\)|      <MimeTypeDefinition mimeType="application/vnd.ms-excel.sheet.binary.macroEnabled.12">\n        <extension>xlsb</extension>\n      </MimeTypeDefinition>\n\1|' \
			  -e 's|\(        <extension>xls</extension>\)|\1\n        <extension>xlt</extension>\n        <extension>xla</extension>|' \
			  -e 's|\(        <extension>sql</extension>\)|\1\n        <extension>txt</extension>\n        <extension>csv</extension>|' pentaho-solutions/system/ImportHandlerMimeTypeDefinitions.xml \
		&& sed -i -e 's|\(,csv,\)|\1sql,|' pentaho-solutions/system/*.xml \
		&& sed -i -e 's|\(,xlsx,\)|\1xltx,xlsm,xltm,xlam,xlsb,|' pentaho-solutions/system/*.xml \
	&& echo "Add Pentaho user..." \
		&& useradd --create-home --home /home/$BISERVER_USER --shell /bin/bash $BISERVER_USER \
        && echo "Change directory ownerships to $BISERVER_USER" \
                && chown -R $BISERVER_USER.$BISERVER_USER /home/$BISERVER_USER \
                && chown -R $BISERVER_USER.$BISERVER_USER /pentaho

# Configure EXT Startup and DynamicFilter

#ADD ./image-init-files/biserver/customizations/applicationContext-EXT-DynamicDataFiltering.xml /pentaho/pentaho-server/pentaho-solutions/system/
#ADD ./image-init-files/biserver/customizations/applicationContext-EXT-SessionStartUp.xml /pentaho/pentaho-server/pentaho-solutions/system/
#ADD ./image-init-files/biserver/customizations/EXT-DynamicDataFiltering-3.1.1.jar /pentaho/pentaho-server/tomcat/webapps/pentaho/WEB-INF/lib/
#ADD ./image-init-files/biserver/customizations/EXT-DynamicDataFiltering.properties /pentaho/pentaho-server/tomcat/webapps/pentaho/WEB-INF/classes/

# Add internal Pentaho Data Integration environment variables to the container for the $BISERVER_USER
#   1. Add the applicationContext-EXT-SessionStartup.xml to pentaho-spring-beans.xml
#   2. Enable CDA caching segments by tenant ID's (different companies)
#ADD ./image-init-files/biserver/customizations/kettle.properties /home/$BISERVER_USER/.kettle/
#RUN chown pentaho:pentaho /home/pentaho/.kettle/kettle.properties \
#    && perl -pi -e 's#</beans>#<import resource="applicationContext-EXT-SessionStartUp.xml" /><import resource="applicationContext-EXT-DynamicDataFiltering.xml" /></beans>#' /pentaho/pentaho-server/pentaho-solutions/system/pentaho-spring-beans.xml \
#       perl -pi -e 's#requireService ["analyzer/vizApi.conf"] = "pentaho.config.spec.IRuleSet#//requireService ["analyzer/vizApi.conf"] = "pentaho.config.spec.IRuleSet#' /pentaho/pentaho-server/pentaho-solutions/system/analyzer/scripts/analyzer-require-js-cfg.js && \
RUN    sed -i -e '$apt.webdetails.cda.cache.extraCacheKeys.tenant_id=${[session:tenant_id]}' /pentaho/pentaho-server/pentaho-solutions/system/cda/cda.properties
        # && \
        # perl -pi -e 's#<prop key="admin">password,Administrator,Authenticated</prop>#<prop key="admin">password,Administrator,Authenticated</prop><prop key="Amy">password,Administrator,Authenticated</prop>#<prop key="James">password,Administrator,Authenticated</prop><prop key="Richard">#password,Administrator,Authenticated</prop><prop key="John">password,Administrator,Authenticated</prop>#' /pentaho/pentaho-server/pentaho-solutions/system/applicationContext-spring-security-memory.xml


# Place the custom login page

#COPY ./image-init-files/biserver/customizations/custom_login/index.jsp /pentaho/pentaho-server/tomcat/webapps/pentaho/
#COPY ./image-init-files/biserver/customizations/custom_login/jsp/PUCLogin.jsp /pentaho/pentaho-server/tomcat/webapps/pentaho/jsp/
#COPY ./image-init-files/biserver/customizations/custom_login/images/logo.png /pentaho/pentaho-server/tomcat/webapps/pentaho-style/images/
#COPY ./image-init-files/biserver/customizations/custom_login/images/hero.mp4 /pentaho/pentaho-server/tomcat/webapps/pentaho-style/images/
#COPY ./image-init-files/biserver/customizations/custom_login/images/video_placeholder.jpg /pentaho/pentaho-server/tomcat/webapps/pentaho-style/images/

# Change work directory

WORKDIR $BISERVER_HOME

# Add latest JDBC drivers and XMLA connector

RUN echo "Download and install JDBC drivers..." \
	&& wget --progress=dot:giga https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
			http://central.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
			http://central.maven.org/maven2/net/sourceforge/jtds/jtds/${JTDS_DRIVER_VERSION}/jtds-${JTDS_DRIVER_VERSION}.jar \
			http://central.maven.org/maven2/com/github/zhicwu/cassandra-jdbc-driver/${CASSANDRA_DRIVER_VERSION}/cassandra-jdbc-driver-${CASSANDRA_DRIVER_VERSION}-shaded.jar \
			http://central.maven.org/maven2/com/h2database/h2/${H2DB_VERSION}/h2-${H2DB_VERSION}.jar \
			http://central.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar \
	&& wget --progress=dot:giga  -O tomcat/webapps/pentaho/docs/xmla-connector.exe https://sourceforge.net/projects/xmlaconnect/files/XMLA_Provider_v${XMLA_PROVIDER_VERSION}.exe/download \
	&& sed -i -e 's|\( class="bannercontent">.*\)\(<br /></td>\)|\1<br />To access OLAP cube via Excel/SharePoint, please install <a href="xmla-connector.exe">XMLA Connector</a> from <a href="http://www.arquery.com">Arquery</a>.\2|' tomcat/webapps/pentaho/docs/InformationMap.jsp \
	&& rm -f tomcat/lib/postgre*.jar tomcat/lib/mysql*.jar tomcat/lib/jtds*.jar tomcat/lib/h2*.jar tomcat/lib/hsqldb*.jar \
	&& mv *.jar $BISERVER_HOME/tomcat/lib/.

# Add any custom JDBC drivers from the local jdbc-drivers folder

COPY ./image-init-files/biserver/jdbc-drivers/* $BISERVER_HOME/tomcat/lib/.

# Install plugins

RUN echo "Download plugins..." \
	&& wget -P $BISERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib https://github.com/zhicwu/saiku/releases/download/3.8.8-SNAPSHOT/saiku-olap-util-3.8.8.jar \
	&& wget -O btable.zip https://sourceforge.net/projects/btable/files/Version3.0-3.6/BTable-pentaho7-3.6-STABLE.zip/download \
	&& wget -O saiku-chart-plus.zip http://sourceforge.net/projects/saikuchartplus/files/SaikuChartPlus3/saiku-chart-plus-vSaiku3-plugin-pentaho.zip/download \
	&& wget --progress=dot:giga https://github.com/zhicwu/saiku/releases/download/3.8.8-SNAPSHOT/saiku-plugin-p6-3.8.8.zip \
			http://ci.pentaho.com/job/webdetails-cte/lastSuccessfulBuild/artifact/dist/cte-8.0-SNAPSHOT.zip \
			http://ctools.pentaho.com/files/d3ComponentLibrary/14.06.18/d3ComponentLibrary-14.06.18.zip \
			https://github.com/rpbouman/pash/raw/master/bin/pash.zip \
	&& echo "Installing plugins..." \
		&& for i in *.zip; do echo "Unpacking $i..." && unzip -q -d pentaho-solutions/system $i && rm -f $i; done \
		&& rm -f pentaho-solutions/system/BTable/resources/datasources/*.cda \
	&& echo "Update configuration..." \
		&& sed -i -e 's|\(<entry key="jpeg" value-ref="streamConverter"/>\)|\1<entry key="saiku" value-ref="streamConverter"/>|' \
			-e 's|\(<value>.xcdf</value>\)|\1<value>.saiku</value>|' \
			-e 's|\(<value>xcdf</value>\)|\1<value>saiku</value>|' pentaho-solutions/system/importExport.xml \
		&& sed -i -e 's|\(<extension>xcdf</extension>\)|\1<extension>saiku</extension>|' pentaho-solutions/system/ImportHandlerMimeTypeDefinitions.xml \
		&& touch pentaho-solutions/system/saiku/ui/js/saiku/plugins/CCC_Chart/cdo.js \
		&& wget -P pentaho-solutions/system/saiku/components/saikuWidget https://github.com/OSBI/saiku/raw/release-3.8/saiku-bi-platform-plugin-p5/src/main/plugin/components/saikuWidget/SaikuWidgetComponent.js \
		&& sed -i -e "s|\(: data.query.queryModel.axes.FILTER\)\(.*\)|\1 == undefined ? [] \1\2|" \
			-e "s|\(: data.query.queryModel.axes.COLUMNS\)\(.*\)|\1 == undefined ? [] \1\2|" \
			-e "s|\(: data.query.queryModel.axes.ROWS\)\(.*\)|\1 == undefined ? [] \1\2|" \
			-e "s|\(request.setRequestHeader('Authorization', auth);\)|// \1|" pentaho-solutions/system/saiku/ui/js/saiku/embed/SaikuEmbed.js \
		&& sed -i -e 's|\(var query = Saiku.tabs._tabs\[0\].content.query;\)|\1\nif (query == undefined ) query = Saiku.tabs._tabs[1].content.query;|' pentaho-solutions/system/saiku/ui/js/saiku/plugins/BIServer/plugin.js \
		&& sed -i -e 's|self.template()|"Error!"|' \
			-e 's|http://meteorite.bi/|/|' pentaho-solutions/system/saiku/ui/saiku.min.js

# Enable CDA and CDE

RUN sed -i.bak 's/<!--//g;s/-->//g' $BISERVER_HOME/pentaho-solutions/system/pentaho-cdf-dd/plugin.xml && \
    sed -i.bak 's/<!--//g;s/-->//g' $BISERVER_HOME/pentaho-solutions/system/cda/plugin.xml

# Add the solutions
# - Anything in the zip file get's extracted in the servers internal repository on first run.
#   There is an exportManifest.xml file that can describe things like database connections and mondrian schema with settings.

# - Could be added via Bind Mount
#COPY ./solutions/solution.zip /pentaho
#RUN mv /pentaho/solution.zip $BISERVER_HOME/pentaho-solutions/system/default-content/

# Add entry point, tempaltes and cron jobs

COPY docker-entrypoint.sh $BISERVER_HOME/docker-entrypoint.sh
COPY repository.xml.template $BISERVER_HOME/pentaho-solutions/system/jackrabbit/repository.xml.template
COPY purge-old-files.sh /etc/cron.hourly/purge-old-files

# Post configuration
#   1. Make jmx-exporter.jar available to Tomcat
#   2. Enable hourly schedules (for running cache clearing scripts etc.)
RUN echo "Post configuration..." \
	&& chmod 0700 /etc/cron.hourly/* \
	&& chmod +x $BISERVER_HOME/*.sh \
	&& ln -s $JMX_EXPORTER_FILE tomcat/bin/jmx-exporter.jar

ENTRYPOINT ["/sbin/my_init", "--", "./docker-entrypoint.sh"]

#VOLUME ["$BISERVER_HOME/.pentaho", "$BISERVER_HOME/data/hsqldb", "$BISERVER_HOME/tomcat/logs", "$BISERVER_HOME/pentaho-solutions/system/jackrabbit/repository", "$BISERVER_HOME/tmp"]

#  8080 - HTTP
#  8009 - AJP
# 11098 - JMX RMI Registry
# 44444 - RMI Server
#EXPOSE 8080 8009 11098 44444

#CMD ["biserver"]
