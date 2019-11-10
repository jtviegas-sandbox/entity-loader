#!/bin/sh

this_folder=$(dirname $(readlink -f $0))
if [ -z  $this_folder ]; then
  this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
base_folder=$(dirname $this_folder)
echo "this_folder: $this_folder | base_folder: $base_folder"

FUNCTION_NAME="store-loader"
SRC_DIR=${base_folder}
AWS_SDK_MODULE_PATH=$SRC_DIR/node_modules/aws-sdk
ARTIFACTS_DIR=${this_folder}/artifacts

echo "starting [ $0 ]..."
_pwd=`pwd`
echo "...leaving $_pwd to $SRC_DIR..."
cd "$SRC_DIR"
echo "...wrapping up the function: $FUNCTION_NAME ..."

npm install &>/dev/null
if [ -d "${AWS_SDK_MODULE_PATH}" ]; then
    rm -rf "$AWS_SDK_MODULE_PATH"
fi
if [ ! -d $ARTIFACTS_DIR ]; then
  mkdir -p $ARTIFACTS_DIR
fi

rm -f "${ARTIFACTS_DIR}/${FUNCTION_NAME}.zip"
zip -9 -q -r "${ARTIFACTS_DIR}/${FUNCTION_NAME}.zip" index.js node_modules &>/dev/null
__r=$?
if [ ! "$__r" -eq "0" ] ; then cd "${_pwd}" && exit 1; fi
echo "packaged in: ${ARTIFACTS_DIR}/${FUNCTION_NAME}.zip"
# reinstall aws
npm install &>/dev/null

echo "...function $FUNCTION_NAME wrapping up done..."
echo "...returning to $_pwd..."
cd "$_pwd"
echo "...[ $0 ] done."