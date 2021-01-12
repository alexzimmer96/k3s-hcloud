#!/bin/bash

sudo apt-get update && apt-get upgrade -y

# Installing and enabling fail2ban
sudo apt-get install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Initializing Master
curl -sfL https://get.k3s.io | K3S_TOKEN=${secret} \
    sh -s - server --token=${secret} --server https://${leader_ip}:6443 --disable=traefik,local-storage,servicelb --kubelet-arg="--cloud-provider=external" --disable-cloud-controller