#!/bin/bash -x
set -eu -o pipefail

# Build nightly version of OpenVidu Server
# and upload the jar to builds.openvidu.io

echo "##################### EXECUTE: openvidu_build_nightly #####################"
DATESTAMP=$(date +%Y%m%d)
MAVEN_OPTIONS='--batch-mode --settings /opt/openvidu-settings.xml -DskipTests=true'

# OpenVidu Java Client
pushd openvidu-java-client
mvn $MAVEN_OPTIONS versions:set -DnewVersion=1.0.0-TEST || exit 1
popd

# OpenVidu Parent
mvn $MAVEN_OPTIONS versions:set-property -Dproperty=version.openvidu.java.client -DnewVersion=1.0.0-TEST || exit 1
mvn $MAVEN_OPTIONS clean || exit 1
mvn $MAVEN_OPTIONS install || exit 1

# OpenVidu Browser
pushd openvidu-browser 
npm install --unsafe-perm || exit 1
npm run build || exit 1
npm link || exit 1
popd 

# OpenVidu Node Client
pushd openvidu-node-client
npm install --unsafe-perm || exit 1
npm run build || exit 1
npm link || exit 1
popd

# OpenVidu Server Dashboard
pushd openvidu-server/src/dashboard 
npm install --unsafe-perm || exit 1
npm link openvidu-browser || exit 1
./node_modules/\@angular/cli/bin/ng build --prod --output-path ../main/resources/static || exit 1
popd

# OpenVidu Server
pushd openvidu-server
mvn $MAVEN_OPTIONS clean compile package || exit 1
OV_VERSION=$(get_version_from_pom-xml.py)
cp target/openvidu-server-${OV_VERSION}.jar target/openvidu-server-latest.jar
popd

# Pushing file to server
pushd openvidu-server/target
FILES="openvidu-server-${OV_VERSION}.jar:upload/openvidu/nightly/${DATESTAMP}/openvidu-server-${OV_VERSION}.jar"
FILES="$FILES openvidu-server-latest.jar:upload/openvidu/nightly/latest/openvidu-server-latest.jar"
FILES=$FILES openvidu_http_publish.sh
popd

# Tell me the versions we've used
mvn --version
pushd openvidu-server/src/dashboard 
./node_modules/\@angular/cli/bin/ng version
