###########################################################################################################
#
# How to build:
#
# ./get-artifacts.sh
# cd ../artifacts_ark_pentaho_ce
# python3 -m http.server 8000
# note: modify BUILD_SERVER below to match ip address where artifacts are being hosted
#
# docker build -t 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest .
# docker push 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest
#
# How to run: (Helm)
#
# helm repo add arkcase https://arkcase.github.io/ark_helm_charts/
# helm install ark-pentaho-ce arkcase/ark-pentaho-ce
# helm uninstall ark-pentaho-ce
#
# How to run: (Kubernetes)
#
# kubectl create -f pod_ark_pentaho.yaml
#
# Look around shell
# kubectl exec -it pod/ark-pentaho -- bash
#
# Web browser to http://server:8080/
# kubectl --namespace default port-forward pod/ark-pentaho 2002 8080:8080 --address='0.0.0.0'
# kubectl delete -f pod_ark_pentaho.yaml
#
# How to run: (Docker)
# 
# docker run --name ark_pentaho -d 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_pentaho:latest 
# docker exec -it ark_pentaho /bin/bash
# docker stop ark_pentaho
# docker rm ark_pentaho
#
###########################################################################################################

FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base:latest

RUN yum -y install java-1.8.0-openjdk
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk

ENV BUILD_SERVER=iad032-1san01.appdev.armedia.com

#FROM 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_base_java8:latest
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
RUN env
RUN curl ${BUILD_SERVER}:8000/pentaho-server-ce-${PENTAHO_CE_VERSION}.zip -o /home/pentaho/app/pentaho/pentaho-server-ce-${PENTAHO_CE_VERSION}.zip
#COPY ${RESOURCE_PATH}/pentaho-server-ce-${PENTAHO_CE_VERSION}.zip /home/pentaho/app/pentaho
#Installing unzip in centos
RUN yum install -y unzip curl && \
    yum clean -y all && \
    cd /home/pentaho/app/pentaho && \
    unzip pentaho-server-ce-${PENTAHO_CE_VERSION}.zip && \
    rm /home/pentaho/app/pentaho/pentaho-server/tomcat/lib/mysql-connector-java-5.1.17.jar

#Database connectors
RUN curl ${BUILD_SERVER}:8000/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar -o ${BASE_PATH}/tomcat/lib/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar
RUN curl ${BUILD_SERVER}:8000/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar -o ${BASE_PATH}/tomcat/lib/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar
#COPY ${RESOURCE_PATH}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar  ${RESOURCE_PATH}/mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar ${BASE_PATH}/tomcat/lib/

#---------preauthentication setup----------------------------------------------
RUN curl ${BUILD_SERVER}:8000/arkcase-preauth-springsec-v${ARKCASE_PRE_AUTH_VERSION}-bundled.jar -o ${BASE_PATH}/tomcat/webapps/pentaho/WEB-INF/lib/arkcase-preauth-springsec-v${ARKCASE_PRE_AUTH_VERSION}-bundled.jar
#COPY ${RESOURCE_PATH}/arkcase-preauth-springsec-v${ARKCASE_PRE_AUTH_VERSION}-bundled.jar ${BASE_PATH}/tomcat/webapps/pentaho/WEB-INF/lib/
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
    chmod -R 777  /home/pentaho/ && \
    rm -f /home/pentaho/app/pentaho/pentaho-server/promptuser.sh && \
    echo 'sleep infinity' >> /home/pentaho/app/pentaho/pentaho-server/start-pentaho.sh
USER pentaho
EXPOSE ${PENTAHO_PORT}
WORKDIR ${BASE_PATH}
CMD ["/home/pentaho/app/pentaho/pentaho-server/start-pentaho.sh"] 
