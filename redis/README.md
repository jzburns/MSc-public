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

### 2.2 Hash values in the cache

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

### 2.3 Using redis for PubSub

Remeber the gcp pubsub we studied earlier? Redis can also be used, just like kafka, as a fast pubsub infrastructure. For this section we will connect to our VM using two ssh clients (so, start another one running)

As you know, we need one publisher and one or more subscribers.

In our first (original) ssh session, lets send a message on the ``msgs`` topic

```
 PUBLISH msgs "Please log off now the system is shutting down..."
 ```
 
 now, on our second ssh session, we will connect to redis and consume the topic message:
 
 ```
 subscribe msgs
 ```
 
 Does it work now?
 
 Do you notice anything here? ... any comments?
 
 Lets send another message:
 
   ```
 PUBLISH msgs "Please log off now the system is shutting down..."
 ```
 
### 2.4 Pattern-matching subscriptions
 
The Redis Pub/Sub implementation supports pattern matching. Clients may subscribe to glob-style patterns in order to receive all the messages sent to channel names matching a given pattern.

For instance:

```
PSUBSCRIBE news.*
```

How does this compare to google cloud pubsub?

### 3.1 Lab Exercise 1 (10 mins)

This exercise is in two parts - a 2:1 pubsub and a 1:2 pubsub
Add one more ssh session now and implement a 2:1 topology then a 1:2 topology [following the image shown here](https://cloud.google.com/pubsub/images/many-to-many.svg) 
Does it work?

### 3.2 Lab Exercise 2 (10 mins)

Of course, the command line interface to redis is very inconvenient. It is quite useful for prototyping but in reality we would never deploy a solution using it. We need to use a client library in python or javascript for example.

So lets look at a more realistic example using python3 bindings to implement pub/sub:

First we do a little bit of setup:

```
sudo apt install python3-pip
```

This will run general updates so will take a minute or two

```
pip3 install redis
```

so now we have the redis python3 bindings. Let's check out this simple python3 script:

```
import redis
import time

## this the redis host IP address here
redis_ip = "10.54.116.12"
r = redis.Redis(host=redis_ip, port=6379, db=0)

## lets see how to pub/sub
## lets sub first:
redis_news_subscriber = r.pubsub()

msg = False

## call back to process the message
def redis_news_handler(message):
        print ('REDIS news handler: ', message['data'])
        global msg
        msg = True

## now we register a call back to 
# subscribe to the redis news channel
redis_news_subscriber.subscribe(**{'redis_news': redis_news_handler} )

## now we sync - wait
## for the news message
while not msg:
        ## this is our sync point
        print("No news Yet")
        redis_news_subscriber.get_message()
        time.sleep(1)

print("News just in...")
```












