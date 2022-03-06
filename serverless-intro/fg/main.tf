provider "google" {
}

resource "google_storage_bucket" "bucket" {
  name     = format("%s-%s", var.project_id, "cloud-functions-bucket")
  location = "eu"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  #############################################################
  ## TODO: change 'YOUR-HOME-DIR' to your home directory
  #############################################################
  source = "/home/YOUR-HOME-DIR/MSc-public/serverless-intro/fg/gcf/index.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "hello-world"
  description = "Hello World Function"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "helloGET"
  region                = var.region
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}