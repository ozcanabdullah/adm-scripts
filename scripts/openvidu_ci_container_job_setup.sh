#!/bin/bash -x

echo "##################### EXECUTE: openvidu_ci_container_job_setup #####################"

[ -z "$OPENVIDU_GIT_REPOSITORY" ] && OPENVIDU_GIT_REPOSITORY=$GIT_URL
[ -z "$BUILD_COMMAND" ] && exit 1
[ -z "$CONTAINER_IMAGE" ] && exit 1

WORKSPACE=/opt
MAVEN_OPTIONS="--batch-mode --settings /opt/openvidu-settings.xml -DskipTests=false"
CONTAINER_MAVEN_SETTINGS=/opt/openvidu-settings.xml
CONTAINER_ADM_SCRIPTS=/opt/adm-scripts
CONTAINER_PRIVATE_RSA_KEY=/opt/git_id_rsa
CONTAINER_NPM_CONFIG=/root/.npmrc
CONTAINER_GPG_PRIVATE_BLOCK=/root/.gpgpriv
CONTAINER_GIT_CONFIG=/root/.gitconfig
CONTAINER_AWS_CONFIG=/root/.aws/config
CONTAINER_HTTP_CERT=/opt/http.crt
CONTAINER_HTTP_KEY=/opt/http.key
CONTAINER_EXTRA_RSA_KEY=/opt/id_rsa.key

docker run \
  --name $BUILD_TAG-JOB_SETUP-$(date +"%s") \
  --rm \
  -e "MAVEN_OPTIONS=$MAVEN_OPTIONS" \
  -e OPENVIDU_GIT_REPOSITORY=$OPENVIDU_GIT_REPOSITORY \
  -v $OPENVIDU_ADM_SCRIPTS_HOME:$CONTAINER_ADM_SCRIPTS \
  $([ -f "$GITHUB_PRIVATE_RSA_KEY" ] && echo "-v $GITHUB_PRIVATE_RSA_KEY:$CONTAINER_PRIVATE_RSA_KEY" ) \
  $([ "${OPENVIDU_GITHUB_TOKEN}x" != "x" ] && echo "-e GITHUB_KEY=$OPENVIDU_GITHUB_TOKEN" ) \
  $([ -f "$MAVEN_SETTINGS" ] && echo "-v $MAVEN_SETTINGS:$CONTAINER_MAVEN_SETTINGS") \
  $([ -f "$NPM_CONFIG" ] && echo "-v $NPM_CONFIG:$CONTAINER_NPM_CONFIG") \
  $([ -f "$GPG_PRIVATE_BLOCK" ] && echo "-v $GPG_PRIVATE_BLOCK:$CONTAINER_GPG_PRIVATE_BLOCK") \
  $([ -f "$GIT_CONFIG" ] && echo "-v $GIT_CONFIG:$CONTAINER_GIT_CONFIG") \
  $([ -f "$AWS_CONFIG" ] && echo "-v $AWS_CONFIG:$CONTAINER_AWS_CONFIG") \
  $([ -f "$HTTP_CERT" ] && echo "-v $HTTP_CERT:$CONTAINER_HTTP_CERT") \
  $([ -f "$HTTP_KEY" ] && echo "-v $HTTP_KEY:$CONTAINER_HTTP_KEY") \
  $([ -f "$KEY_PUB" ] && echo "-v $KEY_PUB:$CONTAINER_EXTRA_RSA_KEY") \
  -e "AWS_ACCESS_KEY_ID=$OPENVIDU_AWS_ACCESS_KEY" \
  -e "AWS_SECRET_ACCESS_KEY=$OPENVIDU_AWS_SECRET_KEY" \
  $([ "${NAEVA_AWS_ACCESS_KEY_ID}x" != "x" ] && echo "-e NAEVA_AWS_ACCESS_KEY_ID=$NAEVA_AWS_ACCESS_KEY_ID" ) \
  $([ "${NAEVA_AWS_SECRET_ACCESS_KEY}x" != "x" ] && echo "-e NAEVA_AWS_SECRET_ACCESS_KEY=$NAEVA_AWS_SECRET_ACCESS_KEY" ) \
  $([ "${KMS_AMI_NAME}x" != "x" ] && echo "-e KMS_AMI_NAME=$KMS_AMI_NAME") \
  $([ "${KMS_AMI_ID}x" != "x" ] && echo "-e KMS_AMI_ID=$KMS_AMI_ID") \
  $([ "${OV_AMI_NAME}x" != "x" ] && echo "-e OV_AMI_NAME=$OV_AMI_NAME") \
  $([ "${OV_AMI_ID}x" != "x" ] && echo "-e OV_AMI_ID=$OV_AMI_ID") \
  $([ "${CF_OVP_TARGET}x" != "x" ] && echo "-e CF_OVP_TARGET=$CF_OVP_TARGET") \
  -e "GITHUB_PRIVATE_RSA_KEY=$CONTAINER_PRIVATE_RSA_KEY" \
  -e "OPENVIDU_PROJECT=$OV_PROJECT" \
  -e "GITHUB_TOKEN=$OPENVIDU_GITHUB_TOKEN" \
  -e "GIT_BRANCH=$GIT_BRANCH" \
  -e "ADM_SCRIPTS=$CONTAINER_ADM_SCRIPTS" \
  -e "OPENVIDU_VERSION=$OV_VERSION" \
  -e "OPENVIDU_PRO_VERSION=$OVP_VERSION" \
  $([ "${KMS_VERSION}x" != "x" ] && echo "-e KMS_VERSION=$KMS_VERSION") \
  -e "OPENVIDU_PRO_IS_SNAPSHOT=$OPENVIDU_PRO_IS_SNAPSHOT" \
  -e "OPENVIDU_PRO_USERNAME=$OPENVIDU_PRO_USERNAME" \
  -e "OPENVIDU_PRO_PASSWORD=$OPENVIDU_PRO_PASSWORD" \
  -e "OPENVIDU_WHERE_PUBLISH_INSPECTOR=$OPENVIDU_WHERE_PUBLISH_INSPECTOR" \
  -e "OVP_TARGET=$OVP_TARGET" \
  -e "OV_AMI=$OV_AMI" \
  -e "KMS_AMI=$KMS_AMI" \
  -e "OPENVIDU_CALL_VERSION=$OVC_VERSION" \
  -e "OPENVIDU_REACT_VERSION=$OVR_VERSION" \
  -e "MAVEN_SETTINGS=$CONTAINER_MAVEN_SETTINGS" \
  -e "GPG_PRIVATE_BLOCK=$CONTAINER_GPG_PRIVATE_BLOCK" \
  -e "GNUPG_KEY_ID=$OPENVIDU_GPG_KEY" \
  -e "GPG_PASSKEY=$OPENVIDU_GPG_PASSKEY" \
  -e "MAVEN_STAGE_ID=$MAVEN_STAGE_ID" \
  -e "BUILDS_HOST=$OPENVIDU_BUILDS_HOST" \
  -e "HTTP_CERT=$CONTAINER_HTTP_CERT" \
  -e "HTTP_KEY=$CONTAINER_HTTP_KEY" \
  -e "MODE=$CF_MODE" \
  -e "TYPE=$CF_TYPE" \
  -e "KURENTO_JAVA_SNAPSHOT=${KURENTO_JAVA_SNAPSHOT}" \
  -v "${PWD}:$WORKSPACE" \
  -w $WORKSPACE \
  $CONTAINER_IMAGE \
  /opt/adm-scripts/openvidu_ci_container_entrypoint.sh $BUILD_COMMAND
status=$?

# Change worspace ownership to avoid permission errors caused by docker usage of root
[ -n "$WORKSPACE" ] && sudo chown -R $(whoami) $WORKSPACE

exit $status

