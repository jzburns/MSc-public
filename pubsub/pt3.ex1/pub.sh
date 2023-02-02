#!/bin/bash
 
###########################################
# the number of messages to send
###########################################
message_count=25
 
###########################################
# the topic to send the messages to
###########################################
topic_name="msc-topic-1"
 
###########################################
# for loop in bash
###########################################
for (( c=0; c<$message_count; c++ ))
do
	echo "sending message ID: $c"
	gcloud pubsub topics publish $topic_name --attribute="KEY=$c" --ordering-key="KEY" --message="Message number: $c"
done

