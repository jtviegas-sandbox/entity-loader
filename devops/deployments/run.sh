#!/bin/sh

TERRAFORM_ZIP=https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip
MODULES_DIR=modules
MODULES_URL=https://github.com/jtviegas/terraform-modules/trunk/modules

this_folder=$(dirname $(readlink -f $0))
if [ -z  $this_folder ]; then
  this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
parent_folder=$(dirname $this_folder)
BUILD_SCRIPT="$parent_folder/build.sh"
echo "this_folder: $this_folder | parent_folder: $parent_folder"

usage()
{
  cat <<EOM
  usage:
  $(basename $0) [dev|pro] [deploy|undeploy]
EOM
  exit 1
}

[ -z $2 ] && { usage; }
[ "$2" != "deploy" ] && [ "$2" != "undeploy" ] && { usage; }
[ "$1" != "dev" ] && [ "$1" != "pro" ] && { usage; }

echo "starting [ $0 $1 $2 ]..."
_pwd=$(pwd)
echo "...leaving $_pwd to $this_folder/$1..."
cd "$this_folder/$1"
wget $TERRAFORM_ZIP -O terraform.zip
unzip terraform.zip
svn export "$MODULES_URL" "$MODULES_DIR"

if [ "$2" == "deploy" ]; then
    $BUILD_SCRIPT
    ls -altr ../artifacts/
    ls -altr
    ./terraform init
    ./terraform plan
    ./terraform apply -auto-approve -lock=true -lock-timeout=5m
else
    ./terraform destroy -auto-approve -lock=true -lock-timeout=5m
fi
__r=$?
rm -rf "$MODULES_DIR"
rm -rf terraform*
echo "...returning to $_pwd..."
cd "$_pwd"
echo "...[ $0 $1 $2 ] done."
exit $__r