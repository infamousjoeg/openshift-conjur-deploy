#!/bin/bash
set -eou pipefail

. utils.sh

# Confirm logged into OpenShift.
if ! oc whoami 2 > /dev/null; then
  echo "You must login to OpenShift before running this demo."
  exit 1
fi

# Confirm Conjur OpenShift project name is configured.
if [ "$CONJUR_PROJECT_NAME" = "" ]; then
  echo "You must set CONJUR_PROJECT_NAME before running this script."
  exit 1
fi

# Confirm docker registry is configured.
if [ "$DOCKER_REGISTRY_PATH" = "" ]; then
  echo "You must set DOCKER_REGISTRY_PATH before running this script."
  exit 1
fi

# Confirm Conjur account is configured.
if [ "$CONJUR_ACCOUNT" = "" ]; then
  echo "You must set CONJUR_ACCOUNT before running this script."
  exit 1
fi

# Confirm Conjur admin password is configured.
if [ "$CONJUR_ADMIN_PASSWORD" = "" ]; then
  echo "You must set CONJUR_ADMIN_PASSWORD before running this script."
  exit 1
fi

# Confirms Conjur image is present.
if [[ "$(docker images -q conjur-appliance:4.9-stable 2> /dev/null)" == "" ]]; then
  echo "You must have the Conjur v4 Appliance tagged as $CONJUR_DOCKER_IMAGE in your Docker engine to run this script."
  exit 1
fi
