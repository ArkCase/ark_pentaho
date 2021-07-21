FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/centos/base-image:java8
ENV PENTAHO_CE_VERSION=8.1.0.0-365
ENV Mysql_Connector_Version=8.0.24
ENV Mariadb_Connector_Version=2.2.6
ENV Arkcase_Pre_Auth_Version=4-1.1.1
ARG RESOURCE_PATH="artifacts"

LABEL ORG="Armedia LLC" \
      VERSION="1.0" \
      IMAGE_SOURCE=https://github.com/ArkCase/ark_pentaho \
      MAINTAINER="Armedia LLC"

#-----------PENTAHO SETUP-------------------------------------
RUN mkdir -p /home/pentaho/data/pentaho &&\
    mkdir -p /home/pentaho/app/pentaho && \
    mkdir -p /home/pentaho/tmp/pentaho && \
    useradd --system --user-group pentaho

#------------PENTAHO CE------------------------------------------

#Copying pentaho ce 
COPY ${RESOURCE_PATH}/pentaho-server-ce-${PENTAHO_CE_VERSION}.zip /home/pentaho/app/pentaho
#Installing unzip in centos
RUN yum install -y unzip && \
    yum install -y mysql && \
   cd /home/pentaho/app/pentaho && \
    unzip pentaho-server-ce-${PENTAHO_CE_VERSION}.zip

#Database connectors
COPY ${RESOURCE_PATH}/mysql-connector-java-${Mysql_Connector_Version}.jar  ${RESOURCE_PATH}/mariadb-java-client-${Mariadb_Connector_Version}.jar /home/pentaho/app/pentaho/pentaho-server/tomcat/lib/

#Removing old mysql jar version 5.1.17
RUN rm /home/pentaho/app/pentaho/pentaho-server/tomcat/lib/mysql-connector-java-5.1.17.jar

#---------preauthentication setup----------------------------------------------
COPY ${RESOURCE_PATH}/arkcase-preauth-springsec-v${Arkcase_Pre_Auth_Version}-bundled.jar /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/WEB-INF/lib/
#---------Update Pentaho to support report designer within ArkCase iframe---------
RUN cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/home/properties/ /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/ && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/home/content /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/home/css /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/home/js /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/home/images/ /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/images && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/browser/lib /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/browser/css/browser.css /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/css && \
    cp -rf  /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle/browser/* /home/pentaho/app/pentaho/pentaho-server/tomcat/webapps/pentaho/mantle && \
    chown -R pentaho: /home/pentaho/

EXPOSE 6092 2002

WORKDIR /home/pentaho/app/pentaho/pentaho-server
CMD ["start-pentaho.sh"] 
