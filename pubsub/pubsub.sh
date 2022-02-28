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
## the code for the subscriber (consumer)
#######################################################
# replicating an exception in the consumer thread
gcloud pubsub subscriptions pull msc-subs-1

# within the message timeout window - so this will fail
gcloud pubsub subscriptions pull msc-subs-1 --auto-ack

#######################################################
## the code for the subscriber-2 (consumer-2)
#######################################################
gcloud pubsub subscriptions pull msc-subs-2 --auto-ack
