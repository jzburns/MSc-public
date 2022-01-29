provider "google" {
}

locals {
  instance_name = format("%s-%s", var.instance_name, substr(md5(module.gce-container.container.image), 0, 8))
}

module "gce-container" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image = "eu.gcr.io/epa-flite-2021/unreliablebanking:latest"
   }
   
  restart_policy = "Always"
}

resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = local.instance_name
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    subnetwork         = var.subnetwork
    access_config {}
  }

  tags = ["http-server", "https-server"]

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
