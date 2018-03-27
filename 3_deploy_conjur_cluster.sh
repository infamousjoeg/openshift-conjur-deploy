#!/bin/bash 
set -eou pipefail

. utils.sh

announce "Creating Conjur cluster."

set_project $CONJUR_PROJECT_NAME

oc delete --ignore-not-found secrets dockerpullsecret

# Set credentials for Docker registry.
oc secrets new-dockercfg dockerpullsecret \
   --docker-server=${DOCKER_REGISTRY_PATH} --docker-username=_ \
   --docker-password=$(oc whoami -t) --docker-email=_
oc secrets add serviceaccount/default secrets/dockerpullsecret --for=pull

conjur_appliance_image=$DOCKER_REGISTRY_PATH/$CONJUR_PROJECT_NAME/conjur-appliance:$CONJUR_PROJECT_NAME

sed -e "s#{{ CONJUR_APPLIANCE_IMAGE }}#$conjur_appliance_image#g" ./manifests/conjur-cluster.yaml |
  oc create -f -

sed -e "s#{{ CONJUR_APPLIANCE_IMAGE }}#$conjur_appliance_image#g" ./manifests/conjur-follower.yaml |
  sed -e "s#{{ AUTHENTICATOR_SERVICE_ID }}#$AUTHENTICATOR_SERVICE_ID#g" |
  oc create -f -

sleep 10

echo "Waiting for Conjur pods to launch..."
wait_for_node $(get_master_pod_name)

echo "Cluster created."
