## Create the container to host the cluster
Before you start, you may need to set your project
ID from the cloud shell using the command:

```
gcloud config set project PROJECT_ID
```
where ``PROJECT_ID`` is your project ID
```
gcloud beta container clusters create gohttpk8s --zone us-central1-a
```
This will generate some warning messages (see below) but these can be ignored

```
WARNING: Currently VPC-native is not the default mode during cluster creation. In the future, this will become the default mode and can be disabled using `--no-enable-ip-alias` flag. Use `--[no-]enable-ip-alias` flag to suppress this warning.
WARNING: Newly created clusters and node-pools will have node auto-upgrade enabled by default. This can be disabled using the `--no-enable-autoupgrade` flag.
WARNING: Starting in 1.12, default node pools in new clusters will have their legacy Compute Engine instance metadata endpoints disabled by default. To create a cluster with legacy instance metadata endpoints disabled in the default node pool, run `clusters create` with the flag `--metadata disable-legacy-endpoints=true`.
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

