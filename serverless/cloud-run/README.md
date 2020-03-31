# Cloud Containers as Functions
Run stateless containers in a managed environment

One of the problems with cloud functions (in general) is the limiting
nature of the available tools, frameworks, languages etc.

Containers as Functions is a way to overcome this. Simply
build your stateless container as usual and deploy to the runtime.

Lets try this with Careless Banking:

Frist, you should already have a careless Banking container in your
google storage registry from last week:

[Follow these steps from here](https://cloud.google.com/run/docs/quickstarts/prebuilt-deploy)

Make sure to:
1. Authentication * Allow unauthenticated invocations
1. Select Google Container Registry image - select ``go-http-sre-crash`` latest
1. Click Create

You should now be able to acces the container using the google generated ``URL`` and
append ``/getbalance``

