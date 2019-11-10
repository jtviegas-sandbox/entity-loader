#!/bin/sh

TERRAFORM_ZIP=https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip
MODULES_DIR=modules
MODULES_URL=https://github.com/jtviegas/terraform-modules/trunk/modules

this_folder=$(dirname $(readlink -f $0))
if [ -z  $this_folder ]; then
  this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
parent_folder=$(dirname $this_folder)
echo "this_folder: $this_folder | parent_folder: $parent_folder"
build_script="$parent_folder/build.sh"
terraform_command=terraform

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

which terraform
if [ ! "$?" -eq "0" ] ; then
  echo "...have to install terraform..."
  terraform_command=./terraform
  wget $TERRAFORM_ZIP -O terraform.zip
  unzip terraform.zip
fi


svn export "$MODULES_URL" "$MODULES_DIR"

if [ "$2" == "deploy" ]; then
    $build_script
    ls -altr
    $terraform_command init
    $terraform_command plan
    $terraform_command apply -auto-approve -lock=true -lock-timeout=5m
else
    $terraform_command destroy -auto-approve -lock=true -lock-timeout=5m
fi
__r=$?
rm -rf "$MODULES_DIR"
rm -rf terraform*
echo "...returning to $_pwd..."
cd "$_pwd"
echo "...[ $0 $1 $2 ] done."
exit $__r