#!/bin/bash


#######################################################
## the code for the producer (publisher)
#######################################################
gcloud pubsub topics publish msc-topic-1 --message="This is a great message"

#######################################################
## sleep for 3 seconds to wait for the message to 
## get processed by the pubsub engine
#######################################################
sleep 3

#######################################################
## the code for the first subscriber (consumer)
#######################################################
gcloud pubsub subscriptions pull msc-subs-1 --auto-ack

#######################################################
## the code for the second subscriber (consumer)
#######################################################
gcloud pubsub subscriptions pull msc-subs-2 --auto-ack
