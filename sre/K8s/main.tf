#############################################################
## TODO:, we need to enable Kubernetes Engine API in the console
## or via gcloud services enable container.googleapis.com
#############################################################
provider "google" {
}

resource "google_container_cluster" "primary" {
  name     = "msc-sre-gke-cluster"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count = 1
  }

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "msc-sre-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  
  node_count = 1

## we will use this later
#   autoscaling {
#     max_node_count = 6
#     min_node_count = 3
#   }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    #############################################################
    ## Google recommends custom service accounts that have 
    ## cloud-platform scope and permissions granted via IAM Roles.
    ## TODO: change this to your own service account email
    #############################################################
    service_account = "54306319895-compute@developer.gserviceaccount.com"

    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
