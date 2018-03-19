#!/bin/bash 
set -eou pipefail

. ../config.sh
. ../utils.sh

set_project $CONJUR_PROJECT

echo "Retrieving Conjur certificate."

ssl_cert=$(oc exec $(get_master_pod_name) -- cat /opt/conjur/etc/ssl/conjur.pem)

set_project $APP_PROJECT

echo "Storing non-secret conjur cert as configuration data"

# Write Conjur SSL cert in ConfigMap.
oc delete --ignore-not-found=true configmap webapp
oc create configmap webapp --from-file=ssl-certificate=<(echo "$ssl_cert")
