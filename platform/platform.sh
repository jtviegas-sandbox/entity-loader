#!/bin/sh

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
base_folder=$(dirname $this_folder)

FUNCTION_NAME="store-loader"
SRC_DIR=${base_folder}/src
AWS_SDK_MODULE_PATH=$SRC_DIR/node_modules/aws-sdk

usage()
{
  cat <<EOM
  usage:
  $(basename $0) [dev|pro] [deploy|undeploy]
EOM
  exit 1
}

[ -z $2 ] && { usage; }
[ ! "$1" == "dev" ] && [ ! "$1" == "pro" ] && { usage; }
[ ! "$2" == "deploy" ] && [ ! "$2" == "undeploy" ] && { usage; }

echo "setting up..."

_pwd=$(pwd)

run_folder="${this_folder}/deployments/$1"

if [ "$2" == "deploy" ]; then

  echo "...wrapping up the function: $FUNCTION_NAME ..."
  cd "$SRC_DIR"

  npm install &>/dev/null
  if [[ -d "${AWS_SDK_MODULE_PATH}" ]]; then
      rm -rf "$AWS_SDK_MODULE_PATH"
  fi

  rm -f "${SRC_DIR}/${FUNCTION_NAME}.zip"
  zip -9 -r "${SRC_DIR}/${FUNCTION_NAME}.zip" index.js node_modules &>/dev/null
  __r=$?
  if [[ ! "$__r" -eq "0" ]] ; then cd "${_pwd}" && exit 1; fi
  # reinstall aws
  npm install &>/dev/null

  echo "...function $FUNCTION_NAME wrapping up done..."

  echo "...doing terraform scripts apply with env: $1"
  cd "${run_folder}"

  terraform init
  terraform plan
  terraform apply -auto-approve -lock=true -lock-timeout=300s

  rm -f "${SRC_DIR}/${FUNCTION_NAME}.zip"

  echo "...terraform scripts done..."
fi

if [ "$2" == "undeploy" ]; then

  echo "...doing terraform scripts destroy with env: $1"
  cd "${run_folder}"
  terraform destroy -auto-approve -lock=true -lock-timeout=300s
  echo "...terraform scripts done..."

fi

cd "$_pwd"
echo "...setup done."
