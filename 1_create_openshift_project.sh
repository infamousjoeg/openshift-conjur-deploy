#!/bin/bash
set -eou pipefail

. utils.sh

if has_project "$CONJUR_PROJECT_NAME"; then
  echo "Project '$CONJUR_PROJECT_NAME' exists, not going to create it."
else
  echo "Creating '$CONJUR_PROJECT_NAME' project."
  oc new-project $CONJUR_PROJECT_NAME

  # Must run as root to unpack Conjur seed files on standbys for high availability.
  oc adm policy add-scc-to-user anyuid -z default

  # Must be able to list master/standby pods to update its haproxy config.
  oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:$CONJUR_PROJECT_NAME:default

  # ???
  oc policy add-role-to-user edit developer
fi
