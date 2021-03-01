# Kubernetes Scalability and Rolling Updates Lab

## Learning Objectives
1. To create and analyze a static K8s cluster
2. To understand and deploy workload and service ``yaml`` files
3. To apply a rolling update to the cluster
4. To create dynamic cluster with autoscaling and appropriately parameterized deployment ``yaml`` files
5. To analyze dynamic cluster dynamics
6. To teardown K8s cluster

## Lab Part 1 Deploying and Starting Workload

### 1.1 Clone the repo

First you should clone the lab resources:

```
git clone https://github.com/jzburns/MSc-public.git
```

### 1.2 View the files

Lets look at the deployment file which you can get on the moodle page, its called ``deployment.yaml``:

```
$ cd MSc-public/scalability/K8s
$ more deployment.yaml

```
and you should see this
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gohttpk8s
spec:
  replicas: 3
  selector:
    matchLabels:
      run: load-tester
  template:
    metadata:
      labels:
        run: load-tester
    spec:
      containers:
      - name: gohttpserver
        image: docker.io/tudjburns/go-http:latest
```

Now lets look at the Service we need to create, 
which in this case is a load balancer, and can
be found in the file ``service.yaml``:

```
apiVersion: v1
kind: Service
metadata:
  name: go-http-nlb-service
spec:
  selector:
    run: load-tester
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

### 1.3 Create the cluster - static size of 3 nodes
Let's go ahead now and create a defaul cluster with 3 nodes

```
gcloud beta container clusters create gohttpk8s --zone us-central1-a
```
This will generate some warning messages (see below) but these can be ignored

```
WARNING: Starting in January 2021, clusters will use the Regular release channel by default when ...
...
```

### 1.4 Cluster state without workload

Before we provision our ``deployment`` and ``service`` let's take a look at the cluster (without any workload), by visiting the console:

```
https://console.cloud.google.com/kubernetes/list
```
Let's check out all the additional services that a K8s cluster runs


Now lets look at the Service we need to create, 
which in this case is a load balancer, and can
be found in the file ``service.yaml``:

```
apiVersion: v1
kind: Service
metadata:
  name: go-http-nlb-service
spec:
  selector:
    run: load-tester
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Before we provision our ``service`` let's take a look at the cluster (without any workload), by visiting the console:

```
https://console.cloud.google.com/kubernetes/list
```
Let's check out all the additional services that a K8s cluster runs

## 1.4 Provision the workload

Next, we use the ``kubeapply`` command in order to provision our workload:
```
kubectl apply -f deployment.yaml
```

and let's check to make sure our Pods started correctly:

``$ kubectl get pods``

Should yield:

```
NAME                         READY   STATUS    RESTARTS   AGE
gohttpk8s-7df4b95775-2h94g   1/1     Running   0          115s
gohttpk8s-7df4b95775-lthz9   1/1     Running   0          115s
gohttpk8s-7df4b95775-ntcdh   1/1     Running   0          115s
```


## 1.5 Provision the workload service

Again, we use ``kubeapply`` to effect this service:
```
kubectl apply -f service.yaml
```
This make take a few minutes to take effect. 

Once it does, go to your browser and simply enter
the IP address for the load balancer. You can
get this information using the kubernetes command

```
kubectl get services
```

you will see output similar to this:

```
NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
go-http-nlb-service   LoadBalancer   10.51.251.79   34.70.245.131   80:32572/TCP   3m34s
kubernetes            ClusterIP      10.51.240.1    <none>          443/TCP        8m37s
```
use the ``EXTERNAL-IP`` field and put this into 
your browser.You now have a kubernetes cluster up and running

Here is a useful [kubernetes command list](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-finding-resources)


## Lab Part 2 Rollling Update to Cluster Nodes

### 2.1 Version 2 of our deployment

Let's suppose we want to make a rolling update to our cluster nodes: we want to run a new version of our container service:

```
$ more deployment-v2.yaml
```

and we can see this:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gohttpk8s
spec:
  replicas: 3
  selector:
    matchLabels:
      run: load-tester
  template:
    metadata:
      labels:
        run: load-tester
    spec:
      containers:
      - name: gohttpserver
        image: docker.io/tudjburns/go-http:v2
```

so we have a new container to roll out: ``docker.io/tudjburns/go-http:v2``

### 2.2 Deploy v2

This is easy in Kubernetes, we simply apply the ``yaml`` file and sit back.

```
kubectl apply -f deployment-v2.yaml
```

### 2.3 Teardown

We are now finished with the static cluster - so let's teardown

```
gcloud beta container clusters delete gohttpk8s  --zone us-central1-a
```

## Lab Part 3 Dynamic clusters

Static clusters do not scale in our out. In order dynamically resize our cluster we need two additional steps:

1. Create a new cluster with ``min`` and ``max`` node sizes declared
2. Use a deployment the declares the CPU resources required

### 3.1 The new deployment file

Let's take a look at the deployment that declares CPU requirements:

```
$ more deployment-cpu.yaml
```

and we can see the new components:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gohttpk8s
spec:
  replicas: 3
  selector:
    matchLabels:
      run: load-tester
  template:
    metadata:
      labels:
        run: load-tester
    spec:
      containers:
      - name: gohttpserver
        image: docker.io/tudjburns/go-http:v2
        resources:
          limits:
            cpu: 300m
```

As you can see, we are declaring that each container in this Pod definition requires 30% of the CPU of the node. This is what K8s uses to determine the scale out event for the cluster (ie, to add more VMs). 

### 3.2 The new cluster definition

Now we create a dynamic cluster ``min=3`` and ``max=6`` nodes:

```
gcloud beta container clusters create gohttpk8s --zone us-central1-a --enable-autoscaling --max-nodes=6 --min-nodes=3
```


### 3.3 Provision the workload and service now

```
kubectl apply -f deployment-cpu.yaml
```
Let's check if the Pods deployed:


``$ kubectl get pods``

Should yield:

```
NAME                         READY   STATUS    RESTARTS   AGE
gohttpk8s-7df4b95775-2h94g   1/1     Running   0          115s
gohttpk8s-7df4b95775-lthz9   1/1     Running   0          115s
gohttpk8s-7df4b95775-ntcdh   1/1     Running   0          115s
```

so it looks like our Pods are running, and the nodes were able to support the ``400ms`` requirements

Again, we use ``kubeapply`` to effect this service:
```
kubectl apply -f service.yaml
```
This make take a few minutes to take effect. 

We also need to apply HPA (Horizontal Pod Autoscaler). Let's have a look at it ``$ more hpa.yaml``

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: gohpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: gohttpk8s
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```  

```
kubectl apply -f hpa.yaml 
```
We can now use this to monitor the pod state

### 3.4 Starting the load test

We have 3 Pods running our workload, so we can bring up the browser, start one load test

***It is important that when we start a load test that we get a confirmation message on the web page***

### 3.5 Cluster expands

After starting the load test running on each Pod, we would expect to see the cluster size increase from 3 to 4 nodes...does it?

If you get the pods using ``kubectl get pods``

We get

```
NAME                        READY   STATUS    RESTARTS   AGE
gohttpk8s-84d54c5f8-2jwgf   1/1     Running   0          2m57s
gohttpk8s-84d54c5f8-594nd   1/1     Running   0          2m57s
gohttpk8s-84d54c5f8-jcx44   1/1     Running   0          8m49s
gohttpk8s-84d54c5f8-ljxz6   1/1     Running   0          2m56s
gohttpk8s-84d54c5f8-lxws8   1/1     Running   0          8m49s
gohttpk8s-84d54c5f8-tm89t   1/1     Running   0          8m49s
gohttpk8s-84d54c5f8-w2kcj   1/1     Running   0          2m57s
```
Let's see how the HPA is doing by using the command ``kubectl get hpa``

```
kubectl get hpakubectl get hpa
NAME    REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
gohpa   Deployment/gohttpk8s   23%/50%   1         10        7          8m53s
```

We can see that after some fluctuations, it has met the requirement by running 7 out of a maximum of 10 pods.

We have now demonstrated Pod autoscaling, so we can tear down now.

### 3.6 HPA changes the Pod count

It is quite interesting to see how the HPA service changes the Pod count over time:

```
NAME    REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
gohpa   Deployment/gohttpk8s   41%/50%   1         10        4          11m
```
This is to be expected as it adjusts the number of Pods as a function of time.

### 3.7 Teardown

We are now finished with the static cluster - so let's teardown

```
gcloud beta container clusters delete gohttpk8s  --zone us-central1-a
```


