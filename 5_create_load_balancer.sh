#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

set_project $CONJUR_PROJECT_NAME

docker_image=$DOCKER_REGISTRY_PATH/$CONJUR_PROJECT_NAME/haproxy:$CONJUR_DEPLOY_TAG

sed -e "s#{{ DOCKER_IMAGE }}#$docker_image#g" ./manifests/haproxy-conjur-master.yaml | oc create -f -

sleep 5

echo "Configuring load balancer..."

# Update HAProxy config to reflect Conjur cluster and restart daemon.
./etc/update_haproxy.sh haproxy-conjur-master

echo "Done."
