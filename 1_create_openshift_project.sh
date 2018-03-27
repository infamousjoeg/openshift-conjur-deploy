#!/bin/bash
set -eou pipefail

. utils.sh

announce "Creating Conjur project."

if has_project "$CONJUR_PROJECT_NAME"; then
  echo "Project '$CONJUR_PROJECT_NAME' exists, not going to create it."
else
  echo "Creating '$CONJUR_PROJECT_NAME' project."
  oc new-project $CONJUR_PROJECT_NAME

  # Must run as root to unpack Conjur seed files on standbys for high availability.
  oc adm policy add-scc-to-user anyuid -z default

  # Grant authn-k8s the permissions it needs to:
  # 1) get + list pods - to verify pod names
  # 2) create + get pods/exec - to inject cert to the sidecar
  oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:$CONJUR_PROJECT_NAME:default
fi
