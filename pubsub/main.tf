provider "google" {
}

resource "google_pubsub_topic" "pubsub-topic" {
  name = "msc-topic-1"

  # A label is a key-value pair that helps you organize your Google Cloud resources. 
  # You can attach a label to each resource, then filter the resources based on their labels. 
  # Information about labels is forwarded to the billing system, so you can break down your billed charges by label.
  labels = {
    activity = "msc-labs"
  }
  # By default, a message that cannot be delivered within the maximum retention 
  # time of 7 days is deleted and is no longer accessible.
  # this is a shorter time period of 1 day 3 min 20 sec
  message_retention_duration = "86600s"
}

resource "google_pubsub_subscription" "pubsub-subs" {
  name = "msc-subs-1"
  # notice that here we use the topic name from
  # google_pubsub_topic.pubsub-topic declared above
  topic = google_pubsub_topic.pubsub-topic.name

  ack_deadline_seconds = 20
   
  labels = {
    activity = "msc-labs"
  }
}

resource "google_pubsub_subscription" "pubsub-subs-2" {
  name = "msc-subs-2"
  # notice that here we use the topic name from
  # google_pubsub_topic.pubsub-topic declared above
  topic = google_pubsub_topic.pubsub-topic.name

  ack_deadline_seconds = 20

  # in order subscriber
  enable_message_ordering = true

  labels = {
    activity = "msc-labs"
  }
}
