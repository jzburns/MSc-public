# Pull ``go-http`` latest

```
docker pull tudjburns/go-http:latest
```

For VM situations, we need the container to always start on boot, so we do this:
```
sudo docker run -dit --restart=always -p 8080:8080 tudjburns/go-http:latest

```

and we are ready to begin loadtesting this server


# GKS

Before we can begin to administer our cluster, first we must configure ``.kube/config``. For a cluster
created with the project ``lunar-clone-235320`` in zone ``us-central1-a`` with name ``k8s-demo``
simply run:

```
gcloud container clusters get-credentials k8s-demo --zone us-central1-a --project lunar-clone-235320
```

Now test the configuration:

```
kubectl get svc

```

Successful outcome should print the following information:

```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   6m25s
```
