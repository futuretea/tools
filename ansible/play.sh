#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    new HOSTS ROLE
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

HOSTS=$1
ROLE=$2
cat >playbooks/tmp.yaml <<EOF
- hosts: ${HOSTS}
  gather_facts: false
  roles:
    - role: ${ROLE}
EOF
shift 2
ansible-playbook -i hosts.ini playbooks/tmp.yaml "$@"
