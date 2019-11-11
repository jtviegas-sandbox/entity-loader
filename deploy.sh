#!/bin/sh

TERRAFORM_ZIP=https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip
MODULES_DIR=modules
MODULES_URL=https://github.com/jtviegas/terraform-modules/trunk/modules

this_folder=$(dirname $(readlink -f $0))
if [ -z  $this_folder ]; then
  this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

build_script="$this_folder/build.sh"
deployments_dir="$this_folder/devops/deployments"
terraform_command=terraform

usage()
{
  cat <<EOM
  usage:
  $(basename $0) [dev|pro] [yes|no]
EOM
  exit 1
}

[ -z $2 ] && { usage; }
[ "$2" != "yes" ] && [ "$2" != "no" ] && { usage; }
[ "$1" != "dev" ] && [ "$1" != "pro" ] && { usage; }

echo "starting [ $0 $1 $2 ]..."
_pwd=$(pwd)
echo "...leaving $_pwd to $deployments_dir/$1..."
cd "$deployments_dir/$1"

which terraform
if [ ! "$?" -eq "0" ] ; then
  echo "...have to install terraform..."
  terraform_command=./terraform
  wget $TERRAFORM_ZIP -O terraform.zip --quiet
  unzip terraform.zip
fi

svn export "$MODULES_URL" "$MODULES_DIR"

if [ "$2" == "yes" ]; then
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