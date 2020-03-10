#!/bin/bash

## configure the instance template first

template() {
gcloud compute instance-templates create-with-container go-http-template \
    --machine-type n1-standard-1 \
    --image-family cos-stable \
    --image-project cos-cloud \
    --container-image docker.io/tudjburns/go-http:latest \
    --boot-disk-size 100GB
}


## next we need an instance group that 
## uses the template
## place it in us-central1-a
ig() {
gcloud compute instance-groups managed create go-http-ig \
  --zone us-central1-a \
  --template go-http-template \
  --size 0
}

## now the asg autoscale
## for go-http-ig
autoscale() {
gcloud compute instance-groups managed set-autoscaling go-http-ig \
  --zone us-central1-a \
  --max-num-replicas=4 \
  --min-num-replicas=1 \
  --cool-down-period=60 \
  --scale-based-on-cpu \
  --target-cpu-utilization=0.6
}

## finally, the load balancer
## load balancer
## backend services drop %age to 60, port 8080, attach to  go-http-ig
## frontend port 80, everything else default
lb() {
gcloud compute firewall-rules create default-allow-8080 \
    --network=default \
    --action=allow \
    --direction=ingress \
    --rules=tcp:8080

## allow the firewall healthchecking
## gcloud compute firewall-rules create allow-health-check \
##    --network=default \
##    --action=allow \
##    --direction=ingress \
##    --source-ranges=0.0.0.0/0 \
##    --rules=tcp:8080

gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global

gcloud compute instance-groups unmanaged set-named-ports go-http-ig \
    --named-ports http:8080 \
    --zone us-central1-a

gcloud compute health-checks create http http-basic-check \
    --port 8080

gcloud compute target-pools create www-pool \
    --region us-central1 --http-health-check basic-check

gcloud compute backend-services create go-http-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global

gcloud compute backend-services add-backend go-http-backend-service \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.4 \
    --capacity-scaler=1 \
    --instance-group=go-http-ig \
    --instance-group-zone=us-central1-a \
    --port 8080 \
    --global

gcloud compute url-maps create web-map \
    --default-service go-http-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
}

## Finally, tear down
## 
teardown() {
	gcloud compute instance-groups managed delete-instances go-http-ig
	gcloud compute instance-templates delete go-http-template
}

if [ $1 == "teardown" ] ;
then
	teardown
elif [ $1 == "template" ] ;
then
	template
elif [ $1 == "ig" ] ;
then
	ig
elif [ $1 == "autoscale" ] ;
then
	autoscale
elif [ $1 == "lb" ] ;
then
	lb
elif [ $1 == "all" ] ;
then
	template
	ig
	autoscale
	lb
fi
