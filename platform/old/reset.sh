#!/bin/sh

this_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/platform/null 2>&1 && pwd )"
parent_folder=$(dirname $this_folder)

curl -XGET https://raw.githubusercontent.com/jtviegas/script-utils/master/bash/aws.sh -o "${this_folder}"/aws.sh

. "${this_folder}"/aws.sh
. ${this_folder}/include

. "${this_folder}"/tenant.include

if [[ -z $TENANT ]] ; then err "no TENANT defined" && exit 1; fi

_pwd=`pwd`
cd ${this_folder}

GROUP_SYS="${TENANT}_system_group"
ROLE_STORE_UPDATE="${TENANT}_store_update_role"
POLICY_LOGS="${TENANT}_logs_policy"
BUCKET_ENTITIES="${TENANT}-${ENTITY}"
POLICY_BUCKETS_USER="${TENANT}_policy_for_buckets_user"
POLICY_BUCKETS_GENERAL_USER="${TENANT}_policy_for_buckets_general_user"
POLICY_BUCKETS_FUNCTION="${TENANT}_policy_for_buckets_function"
POLICY_TABLES="${TENANT}_policy_for_tables_update"
TABLE_PROD="${TENANT}_${ENTITY}_${ENV_PROD}"
TABLE_DEV="${TENANT}_${ENTITY}_${ENV_DEV}"
TABLES="$TABLE_PROD $TABLE_DEV"
FUNCTION_STORE_LOADER="${TENANT}_function_store_loader"
FUNCTION_PERMISSION_ID="${TENANT}_001"

info "resetting $PROJ..."

removePermissionFromFunction ${FUNCTION_STORE_LOADER} ${FUNCTION_PERMISSION_ID}
deleteFunction ${FUNCTION_STORE_LOADER}
detachRoleFromPolicy ${ROLE_STORE_UPDATE}  ${POLICY_TABLES}
detachRoleFromPolicy ${ROLE_STORE_UPDATE}  ${POLICY_BUCKETS_FUNCTION}
detachRoleFromPolicy ${ROLE_STORE_UPDATE} ${POLICY_LOGS}
dettachPolicyFromGroup ${POLICY_BUCKETS_GENERAL_USER} ${GROUP_SYS}
dettachPolicyFromGroup ${POLICY_BUCKETS_USER} ${GROUP_SYS}
dettachPolicyFromGroup ${POLICY_LOGS} ${GROUP_SYS}
deletePolicy ${POLICY_TABLES}
deletePolicy ${POLICY_BUCKETS_FUNCTION}
deletePolicy ${POLICY_BUCKETS_GENERAL_USER}
deletePolicy ${POLICY_BUCKETS_USER}
deletePolicy ${POLICY_LOGS}
for u in ${SYS_USERS}; do
    removeUserFromGroup ${u} ${GROUP_SYS}
    deleteUser ${u}
done
deleteRole ${ROLE_STORE_UPDATE}
deleteGroup ${GROUP_SYS}

for t in ${TABLES}; do
    info "deleting table $t"
    deleteTable ${t}
done

deleteBucket ${BUCKET_ENTITIES}

cd ${_pwd}

info "...$PROJ reset done."