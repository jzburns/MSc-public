variable "project_id" {
  description = "The project ID to deploy resources into"
}

variable "subnetwork" {
  description = "The name of the subnetwork to deploy instances into"
  default = "default"
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
  default     = "container-vm-terraform"
}

variable "zone" {
  description = "The GCP zone to deploy instances into"
  type        = string
  default     = "europe-west1-c"
}

variable "region" {
  description = "The GCP region for the functions"
  type        = string
  default     = "europe-west1"
}


variable "client_email" {
  description = "Service account email address"
  type        = string
  default     = ""
}
