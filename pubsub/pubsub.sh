#!/bin/bash

#######################################################
## the code for the producer (publisher)
#######################################################
gcloud pubsub topics publish epa-topic-1 --message="This is a great message"

#######################################################
## sleep for 3 seconds to wait for the message to 
## get processed by the pubsub engine
#######################################################
sleep 3

#######################################################
## the code for the subscriber (consumer)
#######################################################
gcloud pubsub subscriptions pull epa-subs-1 --auto-ack

#######################################################
## the code for the subscriber-2 (consumer-2)
#######################################################
gcloud pubsub subscriptions pull epa-subs-2 --auto-ack
