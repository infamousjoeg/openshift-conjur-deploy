#!/bin/bash
set -eo pipefail

. utils.sh

# Confirm logged into OpenShift.
if ! oc whoami 2 > /dev/null; then
  echo "You must login to OpenShift before running this demo."
  exit 1
fi

check_env_var "CONJUR_PROJECT_NAME"
check_env_var "DOCKER_REGISTRY_PATH"
check_env_var "CONJUR_ACCOUNT"
check_env_var "CONJUR_ADMIN_PASSWORD"
check_env_var "AUTHENTICATOR_SERVICE_ID"

conjur_appliance_image=conjur-appliance:4.9-stable

# Confirms Conjur image is present.
if [[ "$(docker images -q $conjur_appliance_image 2> /dev/null)" == "" ]]; then
  echo "You must have the Conjur v4 Appliance tagged as $conjur_appliance_image in your Docker engine to run this script."
  exit 1
fi
