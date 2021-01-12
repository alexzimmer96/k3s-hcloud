# K3S on Hetzner Cloud

This repository contains a Terraform template to spin up a k3s cluster on Rancher.
It also provides a Helm-Chart which contains two Subcharts for installing the [hcloud-cloud-controller-manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager) and the [hcloud-csi-driver](https://github.com/hetznercloud/csi-driver). 
Thanks to [Matthias Lohr](https://gitlab.com/MatthiasLohr) for providing the Helm Charts.

## Usage

### Cluster Provisioning

1. Copy the `terraform.tfvars.example` to `terraform.tfvars` and hand in the information
2. Take a look at the `variables.tf` to check, if you want to add more config 
3. Run `terraform init` and `terraform plan`. Check if everything seems ok
4. Run `terraform apply` and let Terraform do the deployments
5. Get your kubeconfig by running `chmod +x ./cp-kubeconf.sh` followed by `./cp-kubeconf.sh <IP Adress to your Management Node>`

### Add Hetzner Cloud Integrations

The attached Helm Chart can install all necessary components to provide a tight integration with Hetzner Cloud.

1. Copy the `controller-values.example.yaml` to `controller-values.example.yaml`
2. Fill in the API-Token and the Network ID
3. Install the Helm-Chart, using e.g. `helm --kubeconfig ./kube_config.yaml upgrade --namespace kube-system --install -f ./controller-values.yaml setup ./controller`
   * If you choose another command for helm installation, please name your Helm deployment `setup` or change the variable `hcloud-csi-driver.csiDriver.secret.name`
4. Check if all components get up
