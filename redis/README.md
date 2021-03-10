### REDIS lab

First we set up a VM client:

```
gcloud compute instances create redis-instance --zone=us-central1-a
```

once the VM comes up we ssh to it and install the redi-cli:

```
sudo apt-get install redis
```

redis can run locally on the VM or we can start a new managed instance of redis within google cloud (calling this ``redis-test``):

```
gcloud redis instances create redis-test \
--size=1 \
--region=us-central1 \
--tier=standard
```

Now we have a redis VM client and a redis managed service.


