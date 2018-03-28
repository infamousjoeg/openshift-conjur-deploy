#!/bin/bash 
set -eou pipefail

. utils.sh

set_project $CONJUR_PROJECT_NAME

external_port=$(oc describe svc conjur-master | awk '/NodePort:/ {print $2 " " $3}' | awk '/https/ {print $2}' | awk -F "/" '{ print $1 }')

api_key=$(rotate_api_key)

announce "
Conjur cluster is ready.

Addresses for the Conjur Master service:

  Inside the cluster:
    conjur-master.$CONJUR_PROJECT_NAME.svc.cluster.local

  Outside the cluster:
    $(environment_url):$external_port

Conjur login credentials:
  admin / $api_key
"
