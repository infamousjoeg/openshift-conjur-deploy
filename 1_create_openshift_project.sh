#!/bin/bash
set -eou pipefail

. utils.sh

if has_project "$CONJUR_PROJECT_NAME"; then
  echo "Project '$CONJUR_PROJECT_NAME' exists, not going to create it."
else
  echo "Creating '$CONJUR_PROJECT_NAME' project."
  oc new-project $CONJUR_PROJECT_NAME

  # TODO: advise customer to create a specific service account instead of using Conjur here.
  # Must run as root to unpack Conjur seed files on standbys for high availability.
  oc adm policy add-scc-to-user anyuid -z default

  # TODO: replace this grant with more find-grained roles / rolebindings.
  # This grants the following permissions to the default service-account to do the following:
  # - get + list on pods
  # - create + get on pods/exec
  oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:$CONJUR_PROJECT_NAME:default
fi
