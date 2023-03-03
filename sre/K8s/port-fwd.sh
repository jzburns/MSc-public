#!/bin/bash

while :
do
	echo "Running port forward"
	kubectl port-forward service/goldpinger 8080:8080
	echo "Port forward crashed !! ... restarting"
done

