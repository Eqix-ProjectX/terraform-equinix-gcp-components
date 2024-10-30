terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  cloud { 
    
    organization = "EQIX_projectX" 

    workspaces { 
      name = "terraform-equinix-gcp-components" 
    } 
  } 
}

provider "google" {
  project = var.project_gcp
  region  = var.region_gcp
  zone    = var.zone_gcp
}

data "terraform_remote_state" "gcp_outputs" {
  backend = "remote"

  config = {
    organization = "EQIX_projectX"
    workspaces = {
      name = "network-builder-apac"
    }
  }
}

resource "google_compute_instance" "vm_instance" {
  name                      = var.gcp_vm_name
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = var.label_gcp_vm
      }
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = data.terraform_remote_state.gcp_outputs.outputs.vpc_gcp
  }
}

resource "google_compute_firewall" "icmp" {
  name    = "allow-icmp"
  network = data.terraform_remote_state.gcp_outputs.outputs.vpc_gcp

  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}