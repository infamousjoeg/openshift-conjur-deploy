#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

set_project $CONJUR_PROJECT

environment_url=$(oc status | head -1 | egrep -o 'https?://[^ ]+' | awk -F: '{print $1":"$2}')
external_port=$(oc describe svc conjur-master | awk '/NodePort:/ {print $2 " " $3}' | awk '/https/ {print $2}' | awk -F "/" '{ print $1 }')

announce "
Conjur cluster is ready. Addresses for the Conjur Master service:

Inside the cluster:
  conjur-master.$CONJUR_PROJECT.svc.cluster.local

Outside the cluster:
  $environment_url:$master_external_port
"
