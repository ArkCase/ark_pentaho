#!/bin/bash
here=$(realpath "$0")
here=$(dirname "$here")
cd "$here"
Pentaho_Version="8.1.0.0-365"
Mysql_Connector_Version="8.0.25"
Mariadb_Connector_Version="2.2.6"
Arkcase_Pre_Auth_Version="4-1.1.1"

# note: these files should not be checked into git, they should not be in the git path, and they also should not be in the build folder for the image
rm -rf ../artifacts
mkdir ../artifacts
echo "Downloading  Pentaho-ce artifacts version  $Pentaho_Version"
aws s3 cp "s3://arkcase-container-artifacts/ark_pentaho_ce/pentaho-server-ce-${Pentaho_Version}.zip"  ../artifacts_ark_pentaho/ --profile FedRAMP-SSO
aws s3 cp "s3://arkcase-container-artifacts/ark_pentaho_ce/mysql-connector-java-${Mysql_Connector_Version}.jar"  ../artifacts_ark_pentaho/ --profile FedRAMP-SSO
aws s3 cp "s3://arkcase-container-artifacts/ark_pentaho_ce/mariadb-java-client-${Mariadb_Connector_Version}.jar"  ../artifacts_ark_pentaho/ --profile FedRAMP-SSO
aws s3 cp "s3://arkcase-container-artifacts/ark_pentaho_ce/arkcase-preauth-springsec-v${Arkcase_Pre_Auth_Version}-bundled.jar"  ../artifacts_ark_pentaho/ --profile FedRAMP-SSO
