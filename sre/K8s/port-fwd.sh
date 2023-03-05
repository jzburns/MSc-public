#!/bin/bash

while :
do
	echo "Running port forward"
	kubectl port-forward service/goldpinger 8080:8080 1>/dev/null
	echo "Port forward crashed !! ... restarting"
done

