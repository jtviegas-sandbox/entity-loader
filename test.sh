#!/bin/sh

__r=0

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -z "$this_folder" ]; then
    this_folder=$(dirname $(readlink -f $0))
fi
echo "this_folder: $this_folder"
parent_folder=$(dirname $this_folder)

AWS_REGION=eu-west-1
AWS_CLI_OUTPUT_FORMAT=text
CONTAINER=localaws
APP="app"
ENVIRONMENT="dev"
BUCKET="$APP-$ENVIRONMENT-entities"
FOLDER="$this_folder/test/resources"
FILE_EXCLUDE="**/trigger"
AWS_S3_URL="http://localhost:5000"
AWS_DB_CONTAINER="http://localhost:8000"
ENTITIES="entity1 entity2"

RESOURCES_FOLDER="/tmp/resources"

if [ -z $STORELOADER_AWS_REGION ]; then
  export STORELOADER_AWS_REGION="eu-west-1"
fi
echo "STORELOADER_AWS_REGION: $STORELOADER_AWS_REGION"
if [ -z $STORELOADER_AWS_ACCESS_KEY_ID ]; then
  export STORELOADER_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID__SPLIT4EVER_DEV
fi
echo "STORELOADER_AWS_ACCESS_KEY_ID: $STORELOADER_AWS_ACCESS_KEY_ID"
if [ -z $STORELOADER_AWS_ACCESS_KEY ]; then
  export STORELOADER_AWS_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY__SPLIT4EVER_DEV
fi
echo "STORELOADER_AWS_ACCESS_KEY: $STORELOADER_AWS_ACCESS_KEY"

export AWS_SECRET_ACCESS_KEY=$STORELOADER_AWS_ACCESS_KEY
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
export AWS_ACCESS_KEY_ID=$STORELOADER_AWS_ACCESS_KEY_ID
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"

export STORELOADER_APP=store
export STORELOADER_TEST_bucket_endpoint="$AWS_S3_URL"
export STORELOADER_TEST_store_endpoint="$AWS_DB_CONTAINER"

echo "starting store loader tests..."

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
  echo "...creating store table $table..."
  createTable "${table}" ${STORELOADER_TEST_store_endpoint}
  __r=$?
  if [[ ! "$__r" -eq "0" ]] ; then cd "${_pwd}" && exit 1; fi
  info "...created store table $table."
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
  node_modules/istanbul/lib/cli.js cover node_modules/mocha/bin/_mocha -- -R spec test/test.js
  __r=$?
fi

cd $_pwd

echo "...stopping aws mock container..."
docker stop $CONTAINER && docker rm $CONTAINER
rm "${this_folder}"/aws.sh

echo "...store loader test done. [$__r]"
exit $__r
