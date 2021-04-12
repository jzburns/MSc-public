## Part 2

### 2.1 Probing the cluster

If you start using Careless Banking you will note a number of issues:

1. Core Dumps - the container exits
2. Error 500 - some kind of internal error
3. Accumulating poor response time 
4. Database Not Reachable Error

Luckily for us, if item 1. happens, K8s will restart the container automatically (so long as the core dump is not too frequent).

Unfortunately, 2-4 are more difficult to resolve. To solve item 2. we need to use a liveness probe:

```
        livenessProbe:
          httpGet:
            path: /getbalamce
            port: 8080
            httpHeaders:
            - name: Web-Service-Up
              value: Test
          initialDelaySeconds: 3
          periodSeconds: 3
```
This code is taken from the file ``deployment-crash-probe.yaml``

The ``periodSeconds`` field specifies that the kubelet should perform a liveness probe every 3 seconds. The ``initialDelaySeconds`` field tells the kubelet that it should wait 3 second before performing the first probe.

Any pod that fails a liveness probe is restarted. Lets apply this and see if it fixes problem 2. the error 500 issues.

```
$ kubectl apply -f deployment-crash-probe.yaml
```
Now, after a short while, any  pods registering an HTTP error 500 will be restarted and it should become somewhat less obvious


### 2.2 Probing the cluster for cumulative latency problem

Finally, we can address the cumulative latency problem by adjusting our probe for timeouts:

```
        livenessProbe:
          httpGet:
            path: /getbalance
            port: 8080
            httpHeaders:
            - name: Web-Service-Up
              value: Test
          initialDelaySeconds: 3
          periodSeconds: 3
          timeoutSeconds: 1
```
we now attach a timeout condition (1 second). If the pod fails this test, it is restarted. 

### 2.3 Frequent Restarts
A note on frequent restarts: GKE will block traffic to pods that are failing liveness probes very frequently. Care must be taken not to trigger pod restarts too often as this signals a problem with the pod/container and traffic will be blocked.

### 2.4 Database Not Reachable Error

Finally, this error is a difficult one to deal with as restarting the container does not alleviate the problem. What can we do? 

We should instrument all systems using something like [Prometheus](https://cloud.google.com/monitoring/kubernetes-engine/prometheus). But a little bit of black-box testing and alerts is also possible.

Now, on to the last part of the lab

## Part 3

# Monitoring Careless Banking

As we have seen - the Careless Banking Server suffers from a number of intermittent problems:

1. Core Dumps - the container exits
2. Error 500 - some kind of internal error
3. Poor response time - high latency
4. Database Connection Pool Empty Error

Problems 1-3 can be detected by Kubernetes. It always restarts containers that exit (1) and liveness probes can be used to resolve 2-3 as in the previous lab sheet.

How can we track problems of type 4?

Lets look again at careless banking - it can report the state of the go-lang container logfile:
```
http://IP/getlogs
```
This page reports the state of the log files for each pod. These logs are read from the container filesystem :
```
/app/golang.log
```
### Design a restart rule for log files

Let's design a restart rule for detecting ``ERROR Database Connection Pool Empty`` in the log files. If this string appears in the logfile more than once, then restart the pod.

Here are the steps
1. If you have not already done so, clone the project repo
```
https://github.com/jzburns/MSc-public.git
```
2. Change directory into ``MSc-public/sre``
3. Make a copy of the deployment file ``deployment-crash.yaml`` to ``deployment-crash-pool.yaml``
4. Make sure ``deployment-crash-pool.yaml`` points to **your** registry for the container ID otherwise it wont work:
```
      containers:
      - name: gohttpserver
        image: eu.gcr.io/<MY-PROJECT-ID>/go-http-sre-crash
        imagePullPolicy: Always
```
add the following liveness probe:

```
        livenessProbe:
          exec:
            command: 
            - /bin/sh
            - -c
            - <YOUR SCRIPT PATH + NAME GOES HERE>
```

2. create a script called ``restart.sh`` with the following logic:
```
#!/bin/sh

if [ <DO YOUR GREP AND COUNT HERE> ]; then
  exit 1
else
  exit 0
fi
```

3. finally, make sure the Dockerfile copies in the ``restart.sh``  to the correct place, then tag and build the docker file
```
docker build . -t eu.gcr.io/<PROJECT-ID>/go-http-sre-crash
```
then push to your own private registry:

```
docker push eu.gcr.io/<PROJECT-ID>//go-http-sre-crash
```
