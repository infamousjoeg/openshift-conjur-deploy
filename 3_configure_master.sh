#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

set_project $CONJUR_PROJECT

master_pod_name=$(get_master_pod_name)

oc label --overwrite pod $master_pod_name role=master

# Configure Conjur master server using evoke.
oc exec $master_pod_name -- evoke configure master \
   -j /etc/conjur.json \
   -h localhost \
   --master-altnames "conjur-master,conjur-master.$CONJUR_PROJECT.svc.cluster.local" \
   --follower-altnames "conjur-follower" \
   -p $CONJUR_ADMIN_PASSWORD \
   $CONJUR_CLUSTER_ACCOUNT
