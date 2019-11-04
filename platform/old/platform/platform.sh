#!/bin/sh

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/tmp/null 2>&1 && pwd )"
parent_folder=$(dirname $this_folder)
base_folder=$(dirname $parent_folder)

FUNCTION_NAME="store-loader"
SRC_DIR=${base_folder}/src
AWS_SDK_MODULE_PATH=$SRC_DIR/node_modules/aws-sdk
TF_DIR="${this_folder}"

usage()
{
  cat <<EOM
  usage:
  $(basename $0) [development|production] [deploy|undeploy]
EOM
  exit 1
}

[ -z $2 ] && { usage; }
[ ! "$1" == "development" ] && [ ! "$1" == "production" ] && { usage; }
[ ! "$2" == "deploy" ] && [ ! "$2" == "undeploy" ] && { usage; }

echo "setting up..."
_pwd=`pwd`
cd ${this_folder}

if [ "$2" == "deploy" ]; then

  echo "...wrapping up the function: $FUNCTION_NAME ..."
  cd $SRC_DIR

  npm install
  if [[ -d "${AWS_SDK_MODULE_PATH}" ]]; then
      rm -rf "$AWS_SDK_MODULE_PATH"
  fi
  rm -f "${this_folder}/${FUNCTION_NAME}.zip"

  zip -9 -r "${this_folder}/${FUNCTION_NAME}.zip" index.js node_modules
  __r=$?
  if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
  # reinstall aws
  npm install

  cd ${this_folder}
  echo "...function $FUNCTION_NAME wrapping up done..."

  echo "...doing terraform scripts apply with env: $1"
  cd ${TF_DIR}

  terraform init
  terraform plan
  terraform apply -auto-approve -lock=true -lock-timeout=300s -var "environment=$1"

  rm -f "${this_folder}/${FUNCTION_NAME}.zip"

  cd ${this_folder}
  echo "...terraform scripts done..."

fi

if [ "$2" == "undeploy" ]; then

  echo "...doing terraform scripts destroy with env: $1"
  cd ${this_folder}

  terraform destroy -auto-approve -lock=true -lock-timeout=300s -var "environment=$1"

  echo "...terraform scripts done..."

fi

cd "$_pwd"
echo "...setup done."
