#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

check_docker_registry_path

set_project $CONJUR_PROJECT

docker_image=$DOCKER_REGISTRY_PATH/$CONJUR_PROJECT/haproxy:$CONJUR_DEPLOY_TAG

sed -e "s#{{ DOCKER_IMAGE }}#$docker_image#g" ./manifests/haproxy-conjur-master.yaml | oc create -f -

sleep 5

echo "Configuring load balancer..."

# Update HAProxy config to reflect Conjur cluster and restart daemon.
./etc/update_haproxy.sh haproxy-conjur-master

echo "Done."
