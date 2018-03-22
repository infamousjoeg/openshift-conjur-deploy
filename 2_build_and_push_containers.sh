#!/bin/bash
set -eou pipefail

. config.sh
. utils.sh

docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH

pushd build/conjur_server
  ./build.sh
popd

docker_tag_and_push $CONJUR_PROJECT_NAME "conjur-appliance"

pushd build/haproxy
  ./build.sh
popd    

docker_tag_and_push $CONJUR_PROJECT_NAME "haproxy"
