
### Lab Learning Objectives
1. To develop a basic Kubernetes liveness probe to assess cluster health
2. To develop a timeout liveness probe
3. To develop a shell-script probe

### Part 1: Set up steps

The following instructions are to be issued from your ``gcp`` shell

### 1.1 Obtain the repo for this class
```
$ git clone https://github.com/jzburns/MSc-public.git
$ cd MSc-public/sre
```

### 1.2 Compiling the Code - Pushing to the Registry

The docker code needs to be built and pushed to **your own private google image registry**, as follows:

```
docker build . -t eu.gcr.io/<YOUR PROJECT ID HERE>/go-http-sre-crash
```
then push the image to the registry:

```
docker push eu.gcr.io/<YOUR PROJECT ID HERE>/go-http-sre-crash
```

**do not proceed until you have this build and push working**

In this directory you will find all the code and ``yaml`` files required.
### 1.3 Create the Kubernetes cluster

```
$ gcloud beta container clusters create gohttpk8s --zone europe-west3-c
```
This step takes a few minutes. **You may be prompted to enable this service**

You may see some warnings like:

```
WARNING: Currently VPC-native is not the default mode during cluster creation. 
WARNING: Newly created clusters and node-pools will have node auto-upgrade enabled by default. This can be disabled using the `--no-enable-autoupgrade` flag.
WARNING: Starting with version 1.18, clusters will have shielded GKE nodes by default.
WARNING: Your Pod address range (`--cluster-ipv4-cidr`) can accommodate at most 1008 node(s). 
```
but these can be ignored

Edit the ``deployment-crash.yaml`` and replace ``<YOUR PROJECT ID HERE>`` with your google project ID:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gohttpk8s
spec:
  replicas: 3
  selector:
    matchLabels:
      run: sre-tester
  template:
    metadata:
      labels:
        run: sre-tester
    spec:
      containers:
      - name: gohttpserver
        image: eu.gcr.io/<YOUR PROJECT ID HERE>/go-http-sre-crash
        imagePullPolicy: Always
```

### 1.4 Cluster yaml files

Now we apply the ``yaml`` files

```
$ kubectl apply -f deployment-crash.yaml
$ kubectl apply -f service.yaml 
```
Once these have taken effect (maybe 1 minute or so) we can find the load balancer IP

```
$ kubectl get services
```
and it should tell you something like this:
```
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
go-http-nlb-service   LoadBalancer   10.51.243.102   35.225.47.50   80:30682/TCP   61s
kubernetes            ClusterIP      10.51.240.1     <none>         443/TCP        2m2s
```
Make a note of the ``EXTERNAL-IP`` address of your load balancer. We will use this IP address along with the page name (getbalance).
EG:
```
http://<EXTERNAL-IP>/getbalance
http://<EXTERNAL-IP>/getlogs
```
We are now ready to start using Careless Banking!

