#!/bin/bash 
set -eou pipefail

. config.sh
. utils.sh

set_project $CONJUR_PROJECT

master_pod_name=$(get_master_pod_name)

echo "Preparing standby seed files..."

mkdir -p tmp
oc exec $master_pod_name evoke seed standby > ./tmp/standby-seed.tar

master_pod_ip=$(oc describe pod $master_pod_name | awk '/IP:/ { print $2 }')
pod_list=$(oc get pods -l role=unset --no-headers | awk '{ print $1 }')

for pod_name in $pod_list; do
  printf "Configuring standby %s...\n" $pod_name

  oc label --overwrite pod $pod_name role=standby
    
  copy_file_to_container "./tmp/standby-seed.tar" "/tmp/standby-seed.tar" "$pod_name"
    
  oc exec $pod_name evoke unpack seed /tmp/standby-seed.tar
  oc exec $pod_name -- evoke configure standby -j /etc/conjur.json -i $master_pod_ip
done

echo "Starting synchronous replication..."
mastercmd evoke replication sync

echo "Done."
