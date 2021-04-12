## Part 3 - Assignment

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

