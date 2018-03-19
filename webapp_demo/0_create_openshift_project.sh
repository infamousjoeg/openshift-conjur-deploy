#!/bin/bash 
set -eou pipefail

. ../config.sh
. ../utils.sh

if has_project "$APP_PROJECT"; then
  echo "Project '$APP_PROJECT' exists, not going to create it."
else
  echo "Creating '$APP_PROJECT' project."
  oc new-project $APP_PROJECT --display-name="Conjur Webapp Demo" --description="For demonstration of Conjur container authentication and secrets retrieval."

  # Permissions
  oc policy add-role-to-user edit developer
fi
