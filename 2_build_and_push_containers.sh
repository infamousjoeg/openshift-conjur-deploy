#!/bin/bash
set -eou pipefail

. utils.sh

announce "Building and pushing conjur-appliance image."

docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH

pushd build/conjur_server
  ./build.sh
popd

docker_tag_and_push $CONJUR_PROJECT_NAME "conjur-appliance"

announce "Building and pushing haproxy image."

pushd build/haproxy
  ./build.sh
popd    

docker_tag_and_push $CONJUR_PROJECT_NAME "haproxy"

echo "Docker images pushed."
