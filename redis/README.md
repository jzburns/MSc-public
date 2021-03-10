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

### 2.1 Basic key value 

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

### 2.2 Hash values in the cachje

We can store a hash of values using the ``HMSET`` 

```
redis> HSET myhash field1 "Hello" field2 "World"
"OK"
redis> HGET myhash field1
"Hello"
redis> HGET myhash field2
"World"
redis> 
```
Does this seem familiar? Yes - it resembles JSON k-v data.

A slightly more ambitious hash uses the command ``HGETALL``:

```
10.0.178.107:6379> HSET tutorialspoint name "redis tutorial"  description "redis basic commands for caching" likes 20 visitors 23000
OK
10.0.178.107:6379> HGETALL tutorialspoint
1) "name"
2) "redis tutorial"
3) "description"
4) "redis basic commands for caching"
5) "likes"
6) "20"
7) "visitors"
8) "23000"
```

