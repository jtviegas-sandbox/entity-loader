#!/bin/sh

__r=0

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
fi
echo "this_folder: $this_folder"
base_folder=$(dirname "$this_folder")

AWS_REGION=eu-west-1
AWS_CLI_OUTPUT_FORMAT=text
CONTAINER=localaws
APP="app"
ENVIRONMENT="dev"
BUCKET="$APP-$ENVIRONMENT-entities"
FOLDER="$this_folder/resources"
FILE_EXCLUDE="**/trigger"
AWS_S3_URL="http://localhost:5000"
AWS_DB_CONTAINER="http://localhost:8000"
ENTITIES="entity1 entity2"
RESOURCES_FOLDER="/tmp/resources"

export DYNDBSTORE_TEST_ENDPOINT=$AWS_DB_CONTAINER
export BUCKETWRAPPER_TEST_ENDPOINT=$AWS_S3_URL

echo "starting entity loader tests..."

_pwd=`pwd`
cd $this_folder

curl -XGET https://raw.githubusercontent.com/jtviegas/script-utils/master/bash/aws.sh -o "${this_folder}"/aws.sh
. "${this_folder}"/aws.sh

aws_init $AWS_REGION $AWS_CLI_OUTPUT_FORMAT

echo "...starting aws mock container..."
docker run --name $CONTAINER -d -e SERVICES="s3:5000,dynamodb:8000" -e DEFAULT_REGION=$AWS_REGION -p 5000:5000 -p 8000:8000 localstack/localstack

for e in ${ENTITIES}; do

  resources_folder="$RESOURCES_FOLDER/$e"
  mkdir -p $resources_folder
  cp -r $FOLDER/* $resources_folder/
  echo "content of $resources_folder:"
  ls $resources_folder

  table="${APP}-${ENVIRONMENT}-${e}"
  echo "...creating entity table $table..."
  createTable "${table}" ${DYNDBSTORE_TEST_ENDPOINT}
  __r=$?
  if [[ ! "$__r" -eq "0" ]] ; then cd "${_pwd}" && exit 1; fi
  info "...created entity table $table."
done

echo "...creating test bucket..."
createBucket ${BUCKET} ${AWS_S3_URL}
__r=$?
if [ "$__r" -eq "0" ] ; then
  debug "...synch folder $RESOURCES_FOLDER with bucket ${BUCKET} ..."
  copyLocalFolderContentsToBucket "${RESOURCES_FOLDER}" ${BUCKET} "${FILE_EXCLUDE}" ${AWS_S3_URL}
  __r=$?
fi

rm -rf ${RESOURCES_FOLDER}/*
debug "...cleaned content in folder $RESOURCES_FOLDER..."

if [ "$__r" -eq "0" ] ; then
  "$base_folder"/node_modules/istanbul/lib/cli.js cover "$base_folder"/node_modules/mocha/bin/_mocha -- -R spec "$this_folder"/test.js
  __r=$?
fi

echo "...stopping aws mock container..."
docker stop $CONTAINER && docker rm $CONTAINER
rm "${this_folder}"/aws.sh
cd "$_pwd"
echo "...entity loader test done. [$__r]"
exit $__r

${${grep -w "version" package.json| cut -d':' -f2}
