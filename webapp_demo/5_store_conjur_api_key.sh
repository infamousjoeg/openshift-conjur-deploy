#!/bin/bash 
set -eou pipefail

. ../config.sh
. ../utils.sh

set_project $APP_PROJECT

oc delete --ignore-not-found=true secret conjur-webapp-api-key

set_project $CONJUR_PROJECT

# Rotate the test app's Conjur API key to get a new one.
api_key=$(oc exec $(get_master_pod_name) -- conjur host rotate_api_key -h 'conjur/openshift-12345/apps/webapp')

set_project $APP_PROJECT

# Store the API key in a Secret.
oc create secret generic conjur-webapp-api-key --from-literal "api-key=$api_key"
