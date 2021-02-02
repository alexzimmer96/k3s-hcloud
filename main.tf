terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.24.0"
    }
    template = {
      version = "~> 2.2.0"
    }
    local = {
      version = "~> 2.0.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

#======================================================================================================
# Creating Networks

resource "hcloud_ssh_key" "k3s_management_ssh_key" {
  name       = "k3s-management-key"
  public_key = file("${var.hcloud_ssh_key_path}.pub")
}

resource "hcloud_network" "k3s_internal_network" {
  name     = "k3s-internal"
  ip_range = "172.16.0.0/12"
}

resource "hcloud_network_subnet" "k3s_default_subnet" {
  network_id   = hcloud_network.k3s_internal_network.id
  type         = "cloud"
  network_zone = var.hcloud_network_zone
  ip_range     = "172.16.0.0/24"
}

#======================================================================================================
# Creating the master node

resource "hcloud_server" "k3s_management_node" {
  name        = "${var.instance_prefix}-management-1"
  image       = "ubuntu-20.04"
  server_type = var.management_instance_type
  location    = var.hcloud_zone

  user_data   = templatefile("${path.module}/scripts/k3s-management.sh", {
    secret     = var.cluster_secret
  })

  ssh_keys = [
    hcloud_ssh_key.k3s_management_ssh_key.id
  ]
}

resource "hcloud_server_network" "k3s_management_node_subnet" {
  server_id  = hcloud_server.k3s_management_node.id
  subnet_id  = hcloud_network_subnet.k3s_default_subnet.id
}

#======================================================================================================
# Creating additional management nodes

resource "hcloud_server" "k3s_management_additional_nodes" {
  count       = var.additional_management_nodes
  name        = "${var.instance_prefix}-management-${count.index + 2}"
  image       = "ubuntu-20.04"
  server_type = var.management_instance_type
  location    = var.hcloud_zone

  user_data   = templatefile("${path.module}/scripts/k3s-management-additional.sh", {
    secret    = var.cluster_secret
    leader_ip = hcloud_server_network.k3s_management_node_subnet.ip
  })

  ssh_keys = [
    hcloud_ssh_key.k3s_management_ssh_key.id
  ]
}

resource "hcloud_server_network" "k3s_management_additional_nodes_subnets" {
  count      = var.additional_management_nodes
  server_id  = hcloud_server.k3s_management_additional_nodes[count.index].id
  subnet_id  = hcloud_network_subnet.k3s_default_subnet.id
}

#======================================================================================================
# Creating the Worker Nodes

resource "hcloud_server" "k3s_worker_nodes" {
  count       = var.worker_nodes
  name        = "${var.instance_prefix}-worker-${count.index + 1}"
  image       = "ubuntu-20.04"
  server_type = var.worker_instance_type
  location    = var.hcloud_zone

  user_data   = templatefile("${path.module}/scripts/k3s-worker.sh", {
    secret    = var.cluster_secret
    leader_ip = hcloud_server_network.k3s_management_node_subnet.ip
  })

  ssh_keys = [
    hcloud_ssh_key.k3s_management_ssh_key.id
  ]
}

resource "hcloud_server_network" "k3s_worker_nodes_subnets" {
  count      = var.worker_nodes
  server_id  = hcloud_server.k3s_worker_nodes[count.index].id
  subnet_id  = hcloud_network_subnet.k3s_default_subnet.id
}

#======================================================================================================
# Creating the controller-values.yaml file from its template

resource "local_file" "controller_values_output" {
  filename = "${path.module}/controller-values.yaml"
  content  = templatefile("${path.module}/controller-values.yaml.template", {
    api_token          = var.hcloud_token
    private_network_id = hcloud_network.k3s_internal_network.id
  })
}

#======================================================================================================
# Creating the LoadBalancer and add the services

# resource "hcloud_load_balancer" "k3s_management_lb" {
#   name               = "k3s-management"
#   load_balancer_type = "lb11"
#   location           = var.hcloud_zone
# }

# resource "hcloud_load_balancer_network" "k3s_management_lb_subnet" {
#   load_balancer_id = hcloud_load_balancer.k3s_management_lb.id
#   subnet_id        = hcloud_network_subnet.k3s_default_subnet.id
# }

# resource "hcloud_load_balancer_target" "k3s_management_lb_target" {
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.k3s_management_lb.id
#   server_id        = hcloud_server.k3s_management_node.id
#   use_private_ip   = true
#   depends_on         = [hcloud_server_network.k3s_management_node_subnet]
# }

# resource "hcloud_load_balancer_target" "k3s_management_lb_additional_targets" {
#   count            = var.additional_management_nodes
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.k3s_management_lb.id
#   server_id        = hcloud_server.k3s_management_additional_nodes[count.index].id
#   use_private_ip   = true
#   depends_on         = [hcloud_server_network.k3s_management_additional_nodes_subnets]
# }

# resource "hcloud_load_balancer_service" "k3s_management_lb_k8s_service" {
#   load_balancer_id = hcloud_load_balancer.k3s_management_lb.id
#   protocol         = "tcp"
#   listen_port      = 6443
#   destination_port = 6443
# }
