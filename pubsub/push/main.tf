provider "google" {
}

resource "google_storage_bucket" "bucket" {
  name     = format("%s-%s", var.project_id, "cloud-functions-bucket")
  location = "eu"
}

resource "google_storage_bucket_object" "archive" {
  #######################################################################
  ## this is the code to be deployed
  #######################################################################
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  #######################################################################
  ## change this path to your own path:
  #######################################################################
  source = "/home/jzburns/MSc-public/pubsub/push/gcf/index.zip"
}

resource "google_cloudfunctions_function" "pubsub-function" {
  name        = "pubsub-push"
  description = "PubSub Function"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "helloPubSub"
  region                = var.region

  #######################################################################
  ## push notification - notice we don't "pull" messages here
  #######################################################################
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource = "projects/mscitqa/topics/msc-topic-1"
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}