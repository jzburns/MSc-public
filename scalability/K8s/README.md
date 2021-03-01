# Lab Part 1
First you should clone the lab resources:


## Create the cluster - static size of 3 nodes

```
gcloud beta container clusters create gohttpk8s --zone us-central1-a
```
This will generate some warning messages (see below) but these can be ignored

```
WARNING: Your Pod address range (`--cluster-ipv4-cidr`) can accommodate at most 1008 node(s). 
This will enable the autorepair feature for nodes. Please see https://cloud.google.com/kubernetes-engine/docs/node-auto-repair for more information on node autorepairs.
```

Lets look at the deployment file which you can get on the moodle page, its called ``deployment.yaml``:
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

Next, we use the ``kubeapply`` command:
```
kubectl apply -f deployment.yaml
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

## Teardown
```
gcloud beta container clusters delete gohttpk8s
```


# Lab Part 4
## A dynamic cluster ``min=3`` and ``max=6`` nodes

```
gcloud beta container clusters create gohttpk8s --zone us-central1-a --enable-autoscaling --max-nodes=6 --min-nodes=3
```

To take advantage of 
