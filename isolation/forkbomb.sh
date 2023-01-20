#!/bin/sh

# this is a classic fork bomb
# it will create 100 instances
# of the sleep 30 function in background mode
for j in $( seq 1 100 ); do
	sleep 30 &
done
