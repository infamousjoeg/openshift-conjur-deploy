#!/bin/bash
set -eou pipefail

. ../config.sh
. ../utils.sh

check_docker_registry_path

docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH

pushd build
  ./build.sh
popd

docker_tag_and_push $APP_PROJECT "webapp"

echo "Done."
