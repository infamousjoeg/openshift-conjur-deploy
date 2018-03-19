#!/bin/bash

. config.sh

announce() {
  echo "++++++++++++++++++++++++++++++++++++++"
  echo ""
  echo "$@"
  echo ""
  echo "++++++++++++++++++++++++++++++++++++++"
}

check_login() {
  if ! logged_in; then
    echo "You must login to OpenShift before running this script."
    exit
  fi
}

check_docker_registry_path() {
  if [ "$DOCKER_REGISTRY_PATH" = "" ]; then
    echo "You must set DOCKER_REGISTRY_PATH before running this script."
    exit
  fi
}

logged_in() {
  if oc whoami 2 > /dev/null; then
    true
  else
    false
  fi
}

has_project() {
  if oc projects | awk 'n>=1 { print a[n%1] } { a[n%1]=$0; n=n+1 }' | grep -w "$1" > /dev/null ; then
    true
  else
    false
  fi
}

docker_tag_and_push() {
  docker_tag="${DOCKER_REGISTRY_PATH}/${1}/$2:$CONJUR_DEPLOY_TAG"
  docker tag $2:local $docker_tag
  docker push $docker_tag
}

copy_file_to_container() {
  local from=$1
  local to=$2
  local pod_name=$3

  local source_file_path=$from
  local source_file_name="$(basename "$source_file_path")"
  local parent_path="$(dirname "$source_file_path")"
  local parent_name="$(basename "$parent_path")"

  local container_temp_path="/tmp"

  oc rsync "$parent_path" "$pod_name:$container_temp_path"
  oc exec "$pod_name" mv "$container_temp_path/$parent_name/$source_file_name" "$to"
  oc exec "$pod_name" rm -- -rf "$container_temp_path/$parent_name"
}

load_policy() {
  local POLICY_FILE=$1

  run_conjur_cmd_as_admin <<CMD
conjur policy load --as-group security_admin "policy/$POLICY_FILE"
CMD
}

# select first pod in list to be master
get_master_pod_name() {
  pod_list=$(oc get pods -l app=conjur-node --no-headers | awk '{ print $1 }')
  echo $pod_list | awk '{print $1}'
}

mastercmd() {
  local current_project=$(oc projects | grep \* | awk '{ print $2 }')

  set_project $CONJUR_PROJECT

  local master_pod=$(oc get pod -l role=master --no-headers | awk '{ print $1 }')
  local interactive=$1

  if [ $interactive = '-i' ]; then
    shift
    oc exec -i $master_pod -- $@
  else
    oc exec $master_pod -- $@
  fi

  set_project "$current_project"
}

rotate_host_api_key() {
  local host=$1

  run_conjur_cmd_as_admin <<CMD
conjur host rotate_api_key -h $host
CMD
}

run_conjur_cmd_as_admin() {
   if [[ "$CONJURRC" = "" ]] ; then
    echo "Set CONJURRC to point to your .conjurrc file."
    echo "This is created by 'conjur init' in your home directory by default."
    exit 1
  fi

  local command=$(cat $@)

  if [[ -z "$command" ]] ; then
    echo "Usage: %s <conjur-command>" $0
    exit 1
  fi
  conjur authn logout > /dev/null
  conjur authn login -u admin -p "$CONJUR_ADMIN_PASSWORD" > /dev/null

  local output=$(eval "$command")

  conjur authn logout > /dev/null
  echo "$output"
}

set_project() {
  # general utility for switching projects/namespaces/contexts in openshift
  # expects exactly 1 argument, a project name.
  if [[ $# != 1 ]]; then
    printf "Error in %s/%s - expecting 1 arg.\n" $(pwd) $0
    exit -1
  fi

  oc project $1 > /dev/null
}

wait_for_node() {
  wait_for_it -1 "kubectl describe pod $1 | grep Status: | grep -q Running"
}

function wait_for_it() {
  local timeout=$1
  local spacer=2
  shift

  if ! [ $timeout = '-1' ]; then
    local times_to_run=$((timeout / spacer))

    echo "Waiting for $@ up to $timeout s"
    for i in $(seq $times_to_run); do
      eval $@ && echo 'Success!' && break
      echo -n .
      sleep $spacer
    done

    eval $@
  else
    echo "Waiting for $@ forever"

    while ! eval $@; do
      echo -n .
      sleep $spacer
    done
    echo 'Success!'
  fi
}

announce_openshift_version() {
  MAJOR_VERSION=$(oc version | grep openshift | awk '{print $2}' | awk -F "." '{ print $1}')
  MINOR_VERSION=$(oc version | grep openshift | awk -F "." '{ print $2}')
  printf "Running Openshift %s.%s\n" $MAJOR_VERSION $MINOR_VERSION
}

check_login