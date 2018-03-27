#!/bin/bash
set -eou pipefail

. utils.sh

announce "Creating Conjur project."

set_project default

if has_project "$CONJUR_PROJECT_NAME"; then
  echo "Project '$CONJUR_PROJECT_NAME' exists, not going to create it."
  set_project $CONJUR_PROJECT_NAME
else
  echo "Creating '$CONJUR_PROJECT_NAME' project."
  oc new-project $CONJUR_PROJECT_NAME
fi

# Must run as root to unpack Conjur seed files on standbys for high availability.
# TODO: replace this overprivileging with a service account + role + role binding
oc adm policy add-scc-to-user anyuid -z default

oc delete --ignore-not-found clusterrole conjur-authenticator-role

# Grant default service account permissions it needs for authn-k8s to:
# 1) get + list pods (to verify pod names)
# 2) create + get pods/exec (to inject cert into app sidecar)
oc create -f ./manifests/conjur-authenticator-role.yaml
