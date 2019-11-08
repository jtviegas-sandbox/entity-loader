#!/bin/sh

MODULES_DIR=modules
MODULES_URL=https://github.com/jtviegas/terraform-modules/trunk/modules
this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
parent_folder=$(dirname $this_folder)
BUILD_SCRIPT=${parent_folder}/build.sh

usage()
{
  cat <<EOM
  usage:
  $(basename $0) [dev|pro] [deploy|undeploy]
EOM
  exit 1
}

[ -z $2 ] && { usage; }
[ ! "$2" == "deploy" ] && [ ! "$2" == "undeploy" ] && { usage; }
[ ! "$1" == "dev" ] && [ ! "$1" == "pro" ] && { usage; }

echo "starting [ $0 $1 $2 ]..."
_pwd=$(pwd)

cd "$1"
svn export "$MODULES_URL" "$MODULES_DIR"

if [ "$2" == "deploy" ]; then
    $BUILD_SCRIPT
    terraform init
    terraform plan
    terraform apply -auto-approve -lock=true -lock-timeout=5m
else
    terraform destroy -auto-approve -lock=true -lock-timeout=5m
fi

rm -rf "$MODULES_DIR"
cd "$_pwd"
echo "...[ $0 $1 $2 ] done."