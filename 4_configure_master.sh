#!/bin/bash 
set -eou pipefail

. utils.sh

announce "Configuring master pod."

set_project $CONJUR_PROJECT_NAME

master_pod_name=$(get_master_pod_name)

oc label --overwrite pod $master_pod_name role=master

# Configure Conjur master server using evoke.
oc exec $master_pod_name -- evoke configure master \
   -j /etc/conjur.json \
   -h conjur-master \
   --master-altnames localhost,conjur-master.$CONJUR_PROJECT_NAME.svc.cluster.local,$(environment_domain) \
   --follower-altnames conjur-follower,conjur-follower.$CONJUR_PROJECT_NAME.svc.cluster.local \
   -p $CONJUR_ADMIN_PASSWORD \
   $CONJUR_ACCOUNT

echo "Master pod configured."
