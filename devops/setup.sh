#!/bin/sh

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
parent_folder=$(dirname $this_folder)


curl -XGET https://raw.githubusercontent.com/jtviegas/script-utils/master/bash/aws.sh -o "${this_folder}"/aws.sh

. "${this_folder}"/aws.sh
# shellcheck disable=SC1090
. "${this_folder}"/include
# shellcheck disable=SC1090
. "${this_folder}"/tenant.include

if [[ -z $TENANT ]] ; then err "no TENANT defined" && exit 1; fi

_pwd=`pwd`
cd ${this_folder}

__r=0

GROUP_SYS="${TENANT}_system_group"
ROLE_STORE_UPDATE="${TENANT}_store_update_role"
POLICY_LOGS="${TENANT}_logs_policy"
BUCKET_ENTITIES="${TENANT}-ENTITIES"
POLICY_BUCKETS_USER="${TENANT}_policy_for_buckets_user"
POLICY_BUCKETS_GENERAL_USER="${TENANT}_policy_for_buckets_general_user"
BUCKETS_ARN="arn:aws:s3:::${BUCKET_ENTITIES},arn:aws:s3:::${BUCKET_ENTITIES}/*"
POLICY_BUCKETS_FUNCTION="${TENANT}_policy_for_buckets_function"
POLICY_TABLES="${TENANT}_policy_for_tables_update"

TABLE_PROD="${TENANT}_${ENTITY}_${ENV_PROD}"
TABLE_DEV="${TENANT}_${ENTITY}_${ENV_DEV}"
TABLES="${TABLE_PROD} ${TABLE_DEV}"
TABLES_ARN="arn:aws:dynamodb:::table/${TABLE_PROD},arn:aws:dynamodb:::table/${TABLE_DEV}"

FUNCTION_STORE_LOADER="${TENANT}_function_store_loader"
FUNCTION_PERMISSION_ID="${TENANT}_001"
DEV_FUNCTION_EVENT_ID="${TENANT}_store_loader_event_dev"
PROD_FUNCTION_EVENT_ID="${TENANT}_store_loader_event_prod"

info "setting up $PROJ..."

isBucket ${BUCKET_ENTITIES}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then
  createBucket ${BUCKET_ENTITIES}
  __r=$?
  if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

  debug "...adding folders to bucket ${BUCKET_ENTITIES} ..."
  for f in ${BUCKET_ENTITIES_FOLDERS}; do
      aws s3api put-object --bucket ${BUCKET_ENTITIES} --key ${f}
      __r=$?
      if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
      info "...added folder $f to bucket $BUCKET_ENTITIES..."
  done

fi





debug "...creating tables ..."
for t in ${TABLES}; do
    createTable "${t}"
    __r=$?
    if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
    info "...created table $t..."
done

debug "...creating group for sys maintenance users ($GROUP_SYS)..."
createGroup ${GROUP_SYS}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi


debug "...creating role for store update: $ROLE_STORE_UPDATE ..."
createRole ${ROLE_STORE_UPDATE} ${this_folder}/${ROLE_ASSUMING_POLICY_FILENAME}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...creating users and adding them to sys maintenance users ($GROUP_SYS) ..."
for u in ${SYS_USERS}; do
    createUser ${u}
    __r=$?
    if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
    addUserToGroup ${u} ${GROUP_SYS}
    __r=$?
    if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
done


debug "...creating policies... logs: $POLICY_LOGS..."
policy=$(buildPolicy "Allow" "$POLICY_LOGS_ACTIONS" "$LOGS_ARN")
createPolicy ${POLICY_LOGS} "$policy"
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi


debug "...creating policies... buckets user: $POLICY_BUCKETS_USER..."
policy=$(buildPolicy "Allow" "$BUCKETS_USER_ACTIONS" "$BUCKETS_ARN")
createPolicy "${POLICY_BUCKETS_USER}" "$policy"
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...creating policies... buckets user: $POLICY_BUCKETS_GENERAL_USER..."
policy=$(buildPolicy "Allow" "$BUCKETS_USER_GENERAL_ACTIONS")
createPolicy "${POLICY_BUCKETS_GENERAL_USER}" "$policy"
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...creating policies... buckets function: $POLICY_BUCKETS_FUNCTION..."
policy=$(buildPolicy "Allow" "$BUCKETS_FUNCTION_ACTIONS" "${BUCKETS_ARN}")
info "...creating policy: $POLICY_BUCKETS_FUNCTION..."
createPolicy "${POLICY_BUCKETS_FUNCTION}" "$policy"
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

#table_arn=`aws dynamodb describe-table --output text --table-name "${TABLE}" | grep "arn.*${TABLE}" | awk '{print $4}' | sed "s/\//\\//g"`
policy=$(buildPolicy "Allow" "$POLICY_TABLES_ACTIONS" "$TABLES_ARN")
info "...creating policy: $POLICY_TABLES..."
createPolicy ${POLICY_TABLES} "$policy"
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...attaching policies to groups: $POLICY_LOGS -> $GROUP_SYS..."
attachPolicyToGroup ${POLICY_LOGS} ${GROUP_SYS}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...attaching policies to groups: $POLICY_BUCKETS_USER -> $GROUP_SYS..."
attachPolicyToGroup ${POLICY_BUCKETS_USER} ${GROUP_SYS}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...attaching policies to groups: $POLICY_BUCKETS_GENERAL_USER -> $GROUP_SYS..."
attachPolicyToGroup ${POLICY_BUCKETS_GENERAL_USER} ${GROUP_SYS}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

# debug "...attaching policy $POLICY_STORE_UPDATE to $GROUP_SYS..."
# attachPolicyToGroup ${POLICY_STORE_UPDATE} ${GROUP_SYS}
# __r=$?
# if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...attaching policies to roles: $POLICY_LOGS -> ${ROLE_STORE_UPDATE} ..."
attachRoleToPolicy ${ROLE_STORE_UPDATE} ${POLICY_LOGS}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...attaching policies to roles: $POLICY_BUCKETS_FUNCTION -> $ROLE_STORE_UPDATE ..."
attachRoleToPolicy ${ROLE_STORE_UPDATE} ${POLICY_BUCKETS_FUNCTION}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

info "...attaching role ${ROLE_STORE_UPDATE} to policy ${POLICY_TABLES} ..."
attachRoleToPolicy ${ROLE_STORE_UPDATE} ${POLICY_TABLES}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi

debug "...wrapping up the function: $FUNCTION_STORE_LOADER ..."
cd ${parent_folder}/src
npm install
if [[ -d "${AWS_SDK_MODULE_PATH}" ]]; then
    rm -rf "$AWS_SDK_MODULE_PATH"
fi
rm -f "$this_folder/$FUNCTION_STORE_LOADER".zip
cp "$this_folder/$TENANT".js "${parent_folder}/src/tenant.js"
zip -9 -r "$this_folder/$FUNCTION_STORE_LOADER".zip index.js config.js tenant.js node_modules
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
# reinstall aws
npm install
debug "...function wrapping done..."

cd ${this_folder}

debug "...creating the function: $FUNCTION_STORE_LOADER ..."
createFunction ${FUNCTION_STORE_LOADER} ${ROLE_STORE_UPDATE} "${this_folder}/${FUNCTION_STORE_LOADER}".zip \
    ${FUNCTION_HANDLER} ${FUNCTION_RUNTIME} ${FUNCTION_TIMEOUT} ${FUNCTION_MEMORY}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
sleep 3

owner=`aws s3api get-bucket-acl --bucket ${BUCKET_ENTITIES} --output=text | grep OWNER | awk '{print $3}'`
debug "...adding function permissions to owner: $owner ..."
addPermissionToFunction ${FUNCTION_STORE_LOADER} ${FUNCTION_PRINCIPAL} ${FUNCTION_PERMISSION_ID} ${FUNCTION_LOADER_ACTIONS} "arn:aws:s3:::${BUCKET_ENTITIES}" ${owner}
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then cd ${_pwd} && exit 1; fi
sleep 3

function_arn=`aws lambda list-functions | grep ${FUNCTION_STORE_LOADER} | awk '{print $4}'`
sed  "s/.*\"LambdaFunctionArn\": \"FUNCTION_ARN\".*/      \"LambdaFunctionArn\": \"$function_arn\"/g" ${this_folder}/_notification.json | \
    sed  "s/.*\"Id\": \"DEV_FUNCTION_EVENT_ID\",.*/      \"Id\": \"$DEV_FUNCTION_EVENT_ID\",/g"  | \
    sed  "s/.*\"Id\": \"PROD_FUNCTION_EVENT_ID\",.*/      \"Id\": \"$PROD_FUNCTION_EVENT_ID\",/g"  > ${this_folder}/notification.json
aws s3api put-bucket-notification-configuration --bucket ${BUCKET_ENTITIES} --notification-configuration file://${this_folder}/notification.json
__r=$?
if [[ ! "$__r" -eq "0" ]] ; then warn "could not configure bucket events" && cd ${_pwd} && exit 1; else info "configured bucket events" ; fi


cd ${_pwd}

info "...$PROJ setup done."

#aws lambda list-functions | grep split4ever_function_store_loader_prod | awk '{print $4}'
#arn:aws:lambda:eu-west-1:692391178777:function:split4ever_function_store_loader_prod
#"${TENANT}-${ENTITY}"
#split4ever-items
#aws s3api put-bucket-notification-configuration --bucket split4ever-items --notification-configuration file://./notification.json
