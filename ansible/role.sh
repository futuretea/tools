#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

useage(){
  cat <<HELP
USAGE:
    new HOSTS ROLE
HELP
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

if [ $# -lt 2 ];then
    useage
    exit 1
fi

HOSTS=$1
ROLE=$2
PLAYBOOK=${3:-"/dev/stdin"}
shift 3
export ANSIBLE_ROLES_PATH="$(pwd)/roles"
export ANSIBLE_RETRY_FILES_ENABLED="false"
ansible-playbook "$@" "${PLAYBOOK}"<<END
- hosts: ${HOSTS}
  roles:
    - ${ROLE}
END
