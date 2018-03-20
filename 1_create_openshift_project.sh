#!/bin/bash
set -eou pipefail

. config.sh
. utils.sh

if has_project "$CONJUR_PROJECT"; then
  echo "Project '$CONJUR_PROJECT' exists, not going to create it."
else
  echo "Creating '$CONJUR_PROJECT' project."
  oc new-project $CONJUR_PROJECT

  # Must run as root to unpack Conjur seed files on standbys for high availability.
  oc adm policy add-scc-to-user anyuid -z default

  # Must be able to list master/standby pods to update its haproxy config.
  oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:$CONJUR_PROJECT:default

  # ???
  oc policy add-role-to-user edit developer
fi
