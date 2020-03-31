# Hello World Samples

## System Tests

### Storage
1. `export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT/gs-test`
1. `gsutil mb gs://$BUCKET_NAME`
1. `gcloud  functions deploy HelloGCS --runtime=go111 --entry-point=HelloGCS --trigger-resource=$BUCKET_NAME --trigger-event=providers/cloud.storage/eventTypes/object.change`


### HTTP

1. `gcloud  functions deploy HelloHTTP --region=us-central1 --runtime=go111 --trigger-http`

### Pub/Sub

first we create the topic:
```
export FUNCTIONS_TOPIC=functions-topic
gcloud pubsub topics create $FUNCTIONS_TOPIC

```
then we export the our project ID:
(don't forget to change this to your project ID)
```
export GCP_PROJECT=lunar-clone-235320
```
Now run these steps:

1. `gcloud functions deploy HelloPubSub --runtime=go111 --trigger-topic=$FUNCTIONS_TOPIC`

1. `gcloud pubsub topics publish $FUNCTIONS_TOPIC --message "This is a Test Message!!"`

You should now see the message stored in the log files for the cloud function.
