#!/bin/bash
here=$(realpath "$0")
here=$(dirname "$here")
cd "$here"
Pentaho_Version="8.1.0.0-365"
Mysql_Connector_Version="8.0.24"
Mariadb_Connector_Version="2.2.6"
Arkcase_Pre_Auth_Version="4-1.1.1"
rm -rf artifacts
mkdir artifacts
echo "Downloading  Pentaho artifacts version  $Pentaho_Version"
aws s3 cp pentaho-server-ce-${Pentaho_Version}.zip artifacts/
aws s3 cp mysql-connector-java-${Mysql_Connector_Version}.jar artifacts/
aws s3 cp mariadb-java-client-${Mariadb_Connector_Version}.jar artifacts/
aws s3 cp arkcase-preauth-springsec-v${Arkcase_Pre_Auth_Version}-bundled.jar artifacts/