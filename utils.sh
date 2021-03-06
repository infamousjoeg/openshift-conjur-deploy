#!/bin/bash

announce() {
  echo "++++++++++++++++++++++++++++++++++++++"
  echo ""
  echo "$@"
  echo ""
  echo "++++++++++++++++++++++++++++++++++++++"
}

environment_url() {
  oc status | head -1 | egrep -o 'https?://[^ ]+' | awk -F: '{print $1":"$2}'
}

environment_domain() {
  env_url=$(environment_url)
  protocol="$(echo $env_url | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  echo ${env_url/$protocol/}
}

has_project() {
  if oc projects | awk 'n>=1 { print a[n%1] } { a[n%1]=$0; n=n+1 }' | sed 's/^ *//g' | grep -x "$1" > /dev/null ; then
    true
  else
    false
  fi
}

docker_tag_and_push() {
  docker_tag="${DOCKER_REGISTRY_PATH}/$1/$2:$CONJUR_PROJECT_NAME"
  docker tag $2:$CONJUR_PROJECT_NAME $docker_tag
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

get_master_pod_name() {
  pod_list=$(oc get pods -l app=conjur-node --no-headers | awk '{ print $1 }')
  echo $pod_list | awk '{print $1}'
}

mastercmd() {
  local current_project=$(oc projects | grep \* | awk '{ print $2 }')

  set_project $CONJUR_PROJECT_NAME

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
  wait_for_it -1 "oc describe pod $1 | grep Status: | grep -q Running"
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

rotate_api_key() {
  set_project $CONJUR_PROJECT_NAME

  master_pod_name=$(get_master_pod_name)
    
  oc exec $master_pod_name -- conjur authn login -u admin -p $CONJUR_ADMIN_PASSWORD > /dev/null
  api_key=$(oc exec $master_pod_name -- conjur user rotate_api_key)
  oc exec $master_pod_name -- conjur authn logout > /dev/null

  echo $api_key
}
