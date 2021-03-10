# REDIS lab

## Part 1: Set up VM and redis

### 1.1 The VM
First we set up a VM client:

```
gcloud compute instances create redis-instance --zone=us-central1-a
```

once the VM comes up we ssh to it and install the redi-cli:

```
sudo apt-get install redis
```

### 1.2 Create the redis managed instance

redis can run locally on the VM or we can start a new managed instance of redis within google cloud (calling this ``redis-test``):

```
gcloud redis instances create redis-test \
--size=1 \
--region=us-central1 \
--tier=standard
```

(This takes a few minutes)
Now we have a redis VM client and a redis managed service. Take a note of the IP address, we will use this below

### 1.3 Describe the redis instance

```
gcloud redis instances describe redis-test --region=us-central1
```

should result in something similar to this output:

```
alternativeLocationId: us-central1-c
authorizedNetwork: projects/msc-devops/global/networks/default
connectMode: DIRECT_PEERING
createTime: '2021-03-10T14:20:16.524415392Z'
currentLocationId: us-central1-c
host: 10.190.84.108
locationId: us-central1-f
memorySizeGb: 1
name: projects/msc-devops/locations/us-central1/instances/redis-test
persistenceIamIdentity: serviceAccount:921790364851-compute@developer.gserviceaccount.com
port: 6379
redisVersion: REDIS_4_0
reservedIpRange: 10.190.84.104/29
state: READY
tier: STANDARD_HA
transitEncryptionMode: DISABLE
```

### 1.4 Connect to redis from our VM

From the VM SSH session, lets have a look at a simple connection to redis

```
redis-cli -h <IP-addr> -p 6379
```

and you should see the redis command line interface:

```
redis-cli -h 10.190.84.108 -p 6379
10.190.84.108:6379>
```

## Part 2: Basic interaction with the cache

Connect to redis on the command line and try out these commands:

```
redis> EXISTS mykey
```
- what do we note?

These caches are key-value pairs. Lets see a simple operation on the cache - appending data to a key

```
redis> APPEND mykey "Hello"
(integer) 5
redis> APPEND mykey " World"
(integer) 11
redis> GET mykey
"Hello World"
```



