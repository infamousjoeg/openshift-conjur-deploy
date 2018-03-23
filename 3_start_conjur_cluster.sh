#!/bin/bash 
set -eou pipefail

. utils.sh

set_project $CONJUR_PROJECT_NAME

# Set credentials for OpenShift Docker registry
oc secrets new-dockercfg dockerpullsecret \
   --docker-server=${DOCKER_REGISTRY_PATH} --docker-username=_ \
   --docker-password=$(oc whoami -t) --docker-email=_
oc secrets add serviceaccount/default secrets/dockerpullsecret --for=pull

docker_image=$DOCKER_REGISTRY_PATH/$CONJUR_PROJECT_NAME/conjur-appliance:$CONJUR_DEPLOY_TAG

sed -e "s#{{ DOCKER_IMAGE }}#$docker_image#g" ./manifests/conjur-cluster.yaml | oc create -f -

sed -e "s#{{ DOCKER_IMAGE }}#$docker_image#g" ./manifests/conjur-follower.yaml |
  sed -e "s#{{ SERVICE_ID }}#$AUTHENTICATOR_SERVICE_ID#g" |
  oc create -f -

sleep 10

echo "Waiting for Conjur pods to launch..."
wait_for_node $(get_master_pod_name)
