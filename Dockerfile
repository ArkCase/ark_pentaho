FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base_java8:latest
ENV PENTAHO_CE_VERSION=8.1.0.0-365 \
    MYSQL_CONNECTOR_VERSION=8.0.25 \
    MARIADB_CONNECTOR_VERSION=2.2.6 \
    ARKCASE_PRE_AUTH_VERSION=4-1.1.1 \
    BASE_PATH=/home/pentaho/app/pentaho/pentaho-server \
	PENTAHO_USER=pentaho \
	PENTAHO_PORT=2002
ARG RESOURCE_PATH="artifacts"

LABEL ORG="Armedia LLC" \
      VERSION="1.0" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_pentaho \
      MAINTAINER="Armedia LLC"

#-----------PENTAHO SETUP-------------------------------------
RUN mkdir -p /home/pentaho/app/data/pentaho &&\
    mkdir -p /home/pentaho/app/pentaho && \
    mkdir -p /home/pentaho/app/tmp/pentaho && \
    useradd --system --user-group ${PENTAHO_USER}

#------------PENTAHO CE------------------------------------------

#Copying pentaho ce 
COPY ${RESOURCE_PATH}/pentaho-server-ce-${PENTAHO_CE_VERSION}.zip /home/pentaho/app/pentaho
#Installing unzip in centos
RUN yum install -y unzip && \
    yum clean -y all && \
   cd /home/pentaho/app/pentaho && \
    unzip pentaho-server-ce-${PENTAHO_CE_VERSION}.zip && \
    rm /home/pentaho/app/pentaho/pentaho-server/tomcat/lib/mysql-connector-java-5.1.17.jar

#Database connectors
COPY ${RESOURCE_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar  ${RESOURCE_PATH}/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar ${BASE_PATH}/tomcat/lib/

#---------preauthentication setup----------------------------------------------
COPY ${RESOURCE_PATH}/arkcase-preauth-springsec-v${ARKCASE_PRE_AUTH_VERSION}-bundled.jar ${BASE_PATH}/tomcat/webapps/pentaho/WEB-INF/lib/
#---------Update Pentaho to support report designer within ArkCase iframe---------
RUN cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/home/properties/ ${BASE_PATH}/tomcat/webapps/pentaho/mantle/ && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/home/content ${BASE_PATH}/tomcat/webapps/pentaho/mantle && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/home/css ${BASE_PATH}/tomcat/webapps/pentaho/mantle && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/home/js ${BASE_PATH}/tomcat/webapps/pentaho/mantle && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/home/images/ ${BASE_PATH}/tomcat/webapps/pentaho/mantle/images && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/browser/lib ${BASE_PATH}/tomcat/webapps/pentaho/mantle && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/browser/css/browser.css ${BASE_PATH}/tomcat/webapps/pentaho/mantle/css && \
    cp -rf  ${BASE_PATH}/tomcat/webapps/pentaho/mantle/browser/* ${BASE_PATH}/tomcat/webapps/pentaho/mantle && \
    chown -R pentaho:pentaho /home/pentaho/* && \
    chmod -R 777  /home/pentaho/* && \
    chmod -R 777  /home/pentaho/	
USER pentaho
EXPOSE ${PENTAHO_PORT}
WORKDIR ${BASE_PATH}
CMD ["start-pentaho.sh"] 
