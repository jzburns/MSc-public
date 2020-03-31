# Some Simple Cloud Functions

In the following examples GCP will ask you to approve unauthenticated access to your functions. Just enter Y.

```
Allow unauthenticated invocations of new function [<some name here>]? (y/N)?
```
### Step 1: Storage
This is an example of a file watcher function that observes a bucker ($BUCKET_NAME) and writes a message to the cloud function
log if there is an create/delete event on the bucket

1. `export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT-gs-test`
1. `gsutil mb gs://$BUCKET_NAME`
1. `gcloud  functions deploy HelloGCS --runtime=go111 --entry-point=HelloGCS --trigger-resource=$BUCKET_NAME --trigger-event=providers/cloud.storage/eventTypes/object.change`

Now we can test the watcher to see if it fires when we copy (ie, create) a file in the bucket:
```
gsutil cp README.md gs://$BUCKET_NAME
```

You should see a message in the log like:

```
[--something here--] 2020/03/31 11:12:01 File README.md created.
```
BTW, functions always record their start and stop time in the log (why is that?)

```
Function execution started
2020/03/31 11:12:01 File README.md created.
Function execution took 95 ms, finished with status: 'ok'

```

### Step 2: HTTP

Lets deploy simple ``HelloWorld`` HTTP function, that simply echoes ``Hello, World!`` when invoked 
in the browser or from a command line client like ``wget``

```
gcloud functions deploy HelloHTTP --region=us-central1 --runtime=go111 --trigger-http
```
This deployment generates a URL, something like:

```
  url: https://<REGION-ID-PROJECT-ID>.cloudfunctions.net/HelloHTTP
```

So take this and put it into your browser...or just to a wget on it:

```
wget https://<REGION-ID-PROJECT-ID>.cloudfunctions.net/HelloHTTP
more HTTP
```
Again, you should see a message in the log for the function like:

```
Function execution started
Function execution took 85 ms, finished with status code: 200
```

### Step 3: Pub/Sub

Lets install a pub/sub client that subscribes to a topic and when
a message arrives to the topic it writes it to the function log

first we create the topic:
```
export FUNCTIONS_TOPIC=functions-topic
gcloud pubsub topics create $FUNCTIONS_TOPIC

```
Now run these steps:

1. `gcloud functions deploy HelloPubSub --runtime=go111 --trigger-topic=$FUNCTIONS_TOPIC`
1. `gcloud pubsub topics publish $FUNCTIONS_TOPIC --message "This is a Test Message --- really --- it is!!"`

You should now see the message stored in the log files for the cloud function.

```
Function execution started
2020/03/31 11:35:42 Hello, This is a Test Message --- really --- it is!!
Function execution took 31 ms, finished with status: 'ok'
```