#!/bin/bash
 
###########################################
# the number of messages to send
###########################################
message_count=25
 
###########################################
# for loop in bash
###########################################
for (( c=0; c<$message_count; c++ ))
do
		echo "================================="
		echo ""
		echo "Reading message ID: $c"
		gcloud pubsub subscriptions pull msc-subs-2 --auto-ack
    echo ""
done

