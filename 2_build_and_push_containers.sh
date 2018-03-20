#!/bin/bash
set -eou pipefail

. config.sh
. utils.sh

if [[ "$(docker images -q $CONJUR_DOCKER_IMAGE 2> /dev/null)" == "" ]]; then
  echo "Must have image tagged $CONJUR_DOCKER_IMAGE available in Docker engine to run this script."
  exit
fi

docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH

pushd build/conjur_server
  ./build.sh
popd

docker_tag_and_push $CONJUR_PROJECT "conjur-appliance"

pushd build/haproxy
  ./build.sh
popd    

docker_tag_and_push $CONJUR_PROJECT "haproxy"
