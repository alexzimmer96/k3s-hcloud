#!/bin/bash

if [ "$1" == "" ]; then
    echo "You need to specifiy a host!"
    return
fi

ssh -t -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile /dev/null" root@$1 'cloud-init status --wait'
scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile /dev/null" root@$1:/etc/rancher/k3s/k3s.yaml ./kube_config.yaml
sed -i 's/127.0.0.1/'$1'/g' ./kube_config.yaml