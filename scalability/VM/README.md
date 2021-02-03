# Autoscale groups with GCP

## configure the instance template first

First we create the instance template ``go-http-template``
```
gcloud compute instance-templates create-with-container go-http-template \
    --machine-type n1-standard-1 \
    --image-family cos-stable \
    --image-project cos-cloud \
    --container-image docker.io/tudjburns/go-http:latest \
    --boot-disk-size 250GB
```

You may see this message:

```
API [compute.googleapis.com] not enabled on project [749635659654]. 
Would you like to enable and retry (this will take a few minutes)? 
(y/N)? 

```
You can enter ``Y`` here and wait (a bit...)

next we need an instance group that 
uses the template
place it in ``us-central1-a`` called ``go-http-ig``
```
gcloud compute instance-groups managed create go-http-ig \
  --zone us-central1-a \
  --template go-http-template \
  --size 0
```

now the ASG autoscale for ``go-http-ig``

```
gcloud compute instance-groups managed set-autoscaling go-http-ig \
  --zone us-central1-a \
  --max-num-replicas=4 \
  --min-num-replicas=1 \
  --cool-down-period=60 \
  --scale-based-on-cpu \
  --target-cpu-utilization=0.4
```

finally, the load balancer
load balancer
backend services drop %age to 60, port 8080, attach to  go-http-ig
frontend port 80, everything else default

We need to allow 8080 traffic in, set lets 
create a rule ``default-allow-8080``

```
gcloud compute firewall-rules create default-allow-8080 \
    --network=default \
    --action=allow \
    --direction=ingress \
    --rules=tcp:8080
```
Now create the IPV4 adress called ``lb-ipv4-1`` for the load 
balancer

```
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global
```
Named ports can be assigned to an instance group, which indicates 
that the service is available on all instances in the group. 
This information is used by the HTTP Load Balancing service.
```
gcloud compute instance-groups unmanaged set-named-ports go-http-ig \
    --named-ports http:8080 \
    --zone us-central1-a
```

next we configure health checks ``http-basic-check``
```
gcloud compute health-checks create http http-basic-check \
    --port 8080
```

Now we create a backend service called ``go-http-backend-service``
```
gcloud compute backend-services create go-http-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global
```
so we can attach the load-balancer policy 
``CPU UTILIZATION = 40%``
```
gcloud compute backend-services add-backend go-http-backend-service \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.4 \
    --capacity-scaler=1 \
    --instance-group=go-http-ig \
    --instance-group-zone=us-central1-a \
    --global
```

These next two steps configure the frontend service 
(``web-map``) and attach the front end to the backend
```
gcloud compute url-maps create web-map \
    --default-service go-http-backend-service
```
This is the proxy (we don't see a proxy when using the UI)
```
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map
```

Finally, we complete the frontend service by specifying
the port to listen adn the proxy to route traffic to
We are now done and you should have a load balancer
called ``web-map`'
```
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
```

# Teardown:
Teardown components in reverse order
```
gcloud compute forwarding-rules delete --global http-content-rule 
gcloud compute target-http-proxies delete http-lb-proxy
gcloud compute url-maps delete web-map
gcloud compute backend-services delete --global go-http-backend-service 
gcloud compute health-checks delete http-basic-check
gcloud compute addresses delete --global lb-ipv4-1
gcloud compute firewall-rules delete default-allow-8080
gcloud compute instance-groups managed delete --zone us-central1-a go-http-ig
gcloud compute instance-templates delete go-http-template
```
