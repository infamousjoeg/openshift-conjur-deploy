#!/bin/bash 
set -eou pipefail

. utils.sh

announce "Creating load balancer for master and standbys."

set_project $CONJUR_PROJECT_NAME

docker_image=$DOCKER_REGISTRY_PATH/$CONJUR_PROJECT_NAME/haproxy:$CONJUR_PROJECT_NAME

sed -e "s#{{ DOCKER_IMAGE }}#$docker_image#g" ./manifests/haproxy-conjur-master.yaml |
  oc create -f -

sleep 5

echo "Configuring load balancer..."

# Update HAProxy config to reflect Conjur cluster and restart daemon.
./haproxy/update_haproxy.sh haproxy-conjur-master

echo "Load balancer created and configured."
