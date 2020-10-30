variable "domain_name" {}
variable "mypreview_name" { description = "Not used in terraform config" }
variable "acme_email" { description = "Not used in terraform config" }
variable "acme_issuer" { description = "Not used in terraform config" }

terraform {
  required_version = "0.14.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.0.2"
    }
  }
}

provider "digitalocean" {
  // DIGITALOCEAN_TOKEN
}

resource "digitalocean_kubernetes_cluster" "default" {
  name = "external-dns-test"
  # doctl compute region list
  region = "fra1"
  # doctl kubernetes options versions`
  version      = "1.19.3-do.0"
  auto_upgrade = true

  node_pool {
    name = "default-pool"
    # doctl compute size list
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

output "kubeconfig" {
  value = "Download kubeconfig:    doctl kubernetes cluster kubeconfig save ${digitalocean_kubernetes_cluster.default.id}    "
}

// Will register domain in
resource "digitalocean_domain" "default" {
  name = var.domain_name
}
