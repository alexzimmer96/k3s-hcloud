variable "cluster_secret" {
    type = string
    description = "Secret that's shared between all Nodes and is used to connect to the Cluster."
}

variable "hcloud_token" {
    type = string
    description = "The token that is used to interact with the Hetzner Cloud API."
}

variable "hcloud_ssh_key_path" {
    type = string
    default = "~/.ssh/k3s_management"
    description = "Path to the key you want to use register on your Hetzner Cloud machines. The public key must have the same location and a .pub ending."
}

variable "hcloud_zone" {
    type = string
    default = "nbg1"
    description = "Zone you want your Cluster to get deployed in."
}

variable "hcloud_network_zone" {
    type = string
    default = "eu-central"
    description = "Network-Zone you want your Cluster to get deployed in."
}

variable "instance_prefix" {
    type = string
    default = "k3s"
    description = "The prefix that comes before the index-value to form the name of the machine."
}

variable "additional_management_nodes" {
    type = number
    default = 2
    description = "Number of additional management Nodes. Must be a always a even number, so the total amount of Management nodes is odd (1+2=3, 1+4=5, etc.)"
}

variable "management_instance_type" {
    type = string
    default = "cx11"
    description = "Hetzner instance type that is used for the machines. You can use the Hetzner Cloud CLI or browse their website to get a list of valid instance types."
}

variable "worker_nodes" {
    type = number
    default = 2
    description = "Number of additional management Nodes. Must be a always a even number, so the total amount of Management nodes is odd (1+2=3, 1+4=5, etc.)"
}

variable "worker_instance_type" {
    type = string
    default = "cx21"
    description = "Hetzner instance type that is used for the machines. You can use the Hetzner Cloud CLI or browse their website to get a list of valid instance types."
}
