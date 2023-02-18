provider "google" {
}

module "gce-container" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
    image = "eu.gcr.io/epa-flite-2021/unreliablebanking:latest"
   }
   
  restart_policy = "Always"
}

resource "google_compute_instance" "ha-instance-1" {
  project      = var.project_id
  name         = "ha-instance-1"
  machine_type = "n1-standard-1"
  zone         = var.ha-zone-1

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {}
  }

  ## we will add this in later
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

resource "google_compute_instance" "ha-instance-2" {
  project      = var.project_id
  name         = "ha-instance-2"
  machine_type = "n1-standard-2"
  zone         = var.ha-zone-2

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {}
  }

  ## we will add this in later
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

