# Autoscale groups with GCP

### 1. Instance Template

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

You should now see:

```
NAME              MACHINE_TYPE   PREEMPTIBLE  CREATION_TIMESTAMP
go-http-template  n1-standard-1               2021-02-03T07:26:41.022-08:00
```
As you can see, we have our instance template ready.

### 2. Instance Group

next we need an instance group that  uses the template place it in ``us-central1-a`` called ``go-http-ig``

```
gcloud compute instance-groups managed create go-http-ig \
  --zone us-central1-a \
  --template go-http-template \
  --size 0
```
and you should see the following output:

```
NAME        LOCATION       SCOPE  BASE_INSTANCE_NAME  SIZE  TARGET_SIZE  INSTANCE_TEMPLATE  AUTOSCALED
go-http-ig  us-central1-a  zone   go-http-ig          0     0            go-http-template   no
```

now the ASG autoscale for ``go-http-ig``

```
gcloud compute instance-groups managed set-autoscaling go-http-ig \
  --zone us-central1-a \
  --max-num-replicas=4 \
  --min-num-replicas=1 \
  --cool-down-period=60 \
  --scale-based-on-cpu \
  --target-cpu-utilization=0.8
```

You should see this output (or something similar)

```
autoscalingPolicy:
  coolDownPeriodSec: 60
  cpuUtilization:
    utilizationTarget: 0.4
  maxNumReplicas: 4
  minNumReplicas: 1
  mode: ON
creationTimestamp: '2021-02-04T02:24:50.785-08:00'
id: '3467127724583581085'
kind: compute#autoscaler
name: go-http-ig-l9jb
selfLink: https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/zones/us-central1-a/autoscalers/go-http-ig-l9jb
status: ACTIVE
target: https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/zones/us-central1-a/instanceGroupManagers/go-http-ig
zone: https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/zones/us-central1-a
```

### 3. 8080 firewall rule

We need to allow 8080 traffic in, set lets 
create a rule ``default-allow-8080``

```
gcloud compute firewall-rules create default-allow-8080 \
    --network=default \
    --action=allow \
    --direction=ingress \
    --rules=tcp:8080
```

We should see the following output:

```
NAME                NETWORK  DIRECTION  PRIORITY  ALLOW     DENY  DISABLED
default-allow-8080  default  INGRESS    1000      tcp:8080        False
```

### 4. Load Balancer IPV4 Address and Named Ports

Now create the IPV4 adress called ``lb-ipv4-1`` for the load balancer

```
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global
```
Again, the output should resemble this:
```
Created [https://www.googleapis.com/compute/v1/projects/msc-architecture/global/addresses/lb-ipv4-1].
```

Named ports can be assigned to an instance group, which indicates 
that the service is available on all instances in the group. 
This information is used by the HTTP Load Balancing service.

```
gcloud compute instance-groups unmanaged set-named-ports go-http-ig \
    --named-ports http:8080 \
    --zone us-central1-a
```

We should see this output:

```
Updated [https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/zones/us-central1-a/instanceGroups/go-http-ig].
```

### 5. The Load Balancer Health Checks

next we configure health checks ``http-basic-check``
```
gcloud compute health-checks create http http-basic-check \
    --port 8080
```

and the following output should be observed:

```
Created [https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/global/healthChecks/http-basic-check].
NAME              PROTOCOL
http-basic-check  HTTP
```

### 6. Backend Service

Now we create a backend service called ``go-http-backend-service``
```
gcloud compute backend-services create go-http-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global
```

output: 
```
Created [https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/global/backendServices/go-http-backend-service].
NAME                     BACKENDS  PROTOCOL
go-http-backend-service            HTTP
```

### 7. Load Balancer Policy

Attach the load-balancer policy ``CPU UTILIZATION = 80%``

```
gcloud compute backend-services add-backend go-http-backend-service \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --capacity-scaler=1 \
    --instance-group=go-http-ig \
    --instance-group-zone=us-central1-a \
    --global
```
Output:
```
Updated [https://www.googleapis.com/compute/v1/projects/it-quality-attributes-302610/global/backendServices/go-http-backend-service].
```

### 8. Frontend Service

These next two steps configure the frontend service 
(``web-map``) and attach the front end to the backend

#### part A.
```
gcloud compute url-maps create web-map \
    --default-service go-http-backend-service
```
This is the proxy (we don't see a proxy when using the UI)

```
NAME     DEFAULT_SERVICE
web-map  backendServices/go-http-backend-service
```
#### part B.
```
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map
```

```
NAME           URL_MAP
http-lb-proxy  web-map
```

### 9. Frontend Service Port

Finally, we complete the frontend service by specifying
the port to listen adn the proxy to route traffic to
We are now done and you should have a load balancer
called ``web-map``
```
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
```
### Testing our ASG

It can take around 5 minutes for the load balancer to start serving traffic. Lets look at the web page for the ``Golang Load Tester``

# Teardown:
Teardown components in reverse order
```
gcloud compute forwarding-rules delete -q --global http-content-rule 
gcloud compute target-http-proxies delete -q http-lb-proxy
gcloud compute url-maps delete -q web-map
gcloud compute backend-services delete -q --global go-http-backend-service 
gcloud compute health-checks delete -q http-basic-check
gcloud compute addresses delete -q --global lb-ipv4-1
gcloud compute firewall-rules delete -q default-allow-8080
gcloud compute instance-groups managed delete -q --zone us-central1-a go-http-ig
gcloud compute instance-templates delete -q go-http-template
```
