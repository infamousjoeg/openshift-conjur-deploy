#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

set_project $CONJUR_PROJECT

external_port=$(oc describe svc conjur-master | awk '/NodePort:/ {print $2 " " $3}' | awk '/https/ {print $2}' | awk -F "/" '{ print $1 }')

# inform user of service ingresses
announce "
Conjur cluster is ready. Addresses for the Conjur Master service:

Inside the cluster:
  conjur-master.$CONJUR_PROJECT.svc.cluster.local

Outside the cluster:
  DNS hostname: conjur-master, IP:127.0.0.1, Port:$external_port
"
