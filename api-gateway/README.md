# API Gateways

## Learning outcomes

1. To create an API project
2. To deploy a set of cloud functions that act as the members of the API
3. To design and deploy an OpenAPI config into the API project
4. To test and validate the API gateway behaviour

## Part 1

### 1.1 Creating an API

In this example we will use the a set of HTTP cloud functions to provide an API that a mbiled client can call. Obviouslly, the purpose is to avoid the mobile client havingn to navigate and co-ordinate these functions itself.   

To begin, we create an API (called ``helloapi`` attached to our project)

```
 gcloud api-gateway apis create helloapi --project=PROJECT_ID
```

You will need to confirm this and enable the API. 

``
 Would you like to enable and retry (this will take a few minutes)? 
 (y/N)?  y
 ``
This can take a few minutes.

On successful completion, we can go on to describe the API:

### 1.2 Describing the API
```
gcloud api-gateway apis describe helloapi --project=PROJECT_ID
```
This command returns something the following:

```
createTime: '2021-03-18T10:20:02.620875731Z'
displayName: helloapi
managedService: weatherapi-12k4oabzjy9ze.apigateway.it-quality-attributes-302610.cloud.goog
name: projects/it-quality-attributes-302610/locations/global/apis/helloapi
state: ACTIVE
updateTime: '2021-03-18T10:21:40.272559300Z'
```

The gcloud command-line tool takes many options, including those described in the gcloud Reference. In addition, for API Gateway, you can set the following options when creating an API:

``--async:`` Return control to the terminal immediately, without waiting for the operation to complete.

But obviously we did not use ``--async`` so we would expect the client to block waiting for the results of the API call.

## Part 2

### 2.1 API config ID requirements

Many of the ``gcloud`` commands shown below require you to specify the ID of the API config, in the form: ``CONFIG_ID``. API Gateway enforces the following requirements for the API config ID:

1. Must have a maximum length of 63 characters.
1. Must contain only lowercase letters, numbers, or dashes.
1. Must not start with a dash.
1. Must not contain an underscore.

### 2.2 Deploy the backend

The cloud function is probably not still deployed...but this is the one we want:

```
/**
 * HTTP Cloud Function.
 * This function is exported by index.js, and is executed when
 * you make an HTTP request to the deployed function's endpoint.
 *
 * @param {Object} req Cloud Function request context.
 *                     More info: https://expressjs.com/en/api.html#req
 * @param {Object} res Cloud Function response context.
 *                     More info: https://expressjs.com/en/api.html#res
 */

exports.helloGET = (req, res) => {
  res.send('Hello World!');
};
```
Do you remember this?

#### Exercise - 5 minutes

Take 5 minutes to locate and deploy ``helloGET`` - we did this already in a previous lab

### 2.3 Anatomy of an OpenAPI config

Lets look at an OpenAPI config that uses the ``helloGET`` cloud function we have seen previously:

```
# openapi2-functions.yaml
swagger: '2.0'
info:
  title: helloapi a simple API test
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Greet a user
      operationId: hello
      x-google-backend:
        address: https://GCP_REGION-PROJECT_ID.cloudfunctions.net/helloGET
      responses:
        '200':
          description: A successful response
          schema:
            type: string
```

1. To upload this OpenAPI spec and create an API config using the gcloud command line tool:
1. From the command line, create a new file named ``openapi2-functions.yaml``
1. Copy and paste the contents of the OpenAPI spec shown above into the newly created file.

Edit the file as follows:

1. In the address field, replace ``GCP_REGION`` with the ``GCP`` region of the deployed function and ``PROJECT_ID`` with the name of your Google Cloud project. You can get this information from the cloud function deploy return message.

### 2.4 Upload this file

Now that we have deployed our cloud function and configured our API gateway config file, we need to submit it to the management service. To do this correctly we need some additional parameters. In particular, we need to know the ``service account`` email address that is used to create the API.

```
gcloud api-gateway api-configs create gcloud api-gateway api-configs create CONFIG_ID \
  --api=API_ID 
  --openapi-spec=API_DEFINITION \
  --project=PROJECT_ID 
  --backend-auth-service-account=SERVICE_ACCOUNT_EMAILCONFIG_ID \
```
1. ``API_ID``: the name for your API config to be attached to (=``helloapi``)
2. ``API_DEFINITION``: the name of the yaml file (=``openapi2-functions.yaml``)
3. ``SERVICE_ACCOUNT_EMAILCONFIG_ID``: this field [can be found by visiting the GCP IAM page](https://console.cloud.google.com/iam-admin) )(see image below)
4. ``CONFIG_ID``: the new name for the configuration (=``helloapiconfig``)

![image](https://user-images.githubusercontent.com/3818964/111679672-52399f00-8819-11eb-9e13-4457b4d8ea71.png)

You can see in the above screenshot that my ID is based on the ``Compute Engine default service account`` column: ``749635659654-compute@developer.gserviceaccount.com``

So now, my gateway config command looks like this:

```
gcloud api-gateway api-configs create helloapiconfig \
  --api=helloapi \
  --openapi-spec=openapi2-functions.yaml \
  --project=it-quality-attributes-302610 \
  --backend-auth-service-account=749635659654-compute@developer.gserviceaccount.com
```
This takes a few minutes...

### 2.5 Describe the Service

We can now describe the API gateway:

```
gcloud api-gateway api-configs describe helloapiconfig 
--api=helloapi \
--project=it-quality-attributes-302610 
```
(be sure to replace ``it-quality-attributes-302610`` with your project ID).

this should yield the following information

```
createTime: '2021-03-18T19:18:34.254304912Z'
displayName: helloapiconfig
gatewayServiceAccount: projects/-/serviceAccounts/749635659654-compute@developer.gserviceaccount.com
name: projects/749635659654/locations/global/apis/helloapi/configs/helloapiconfig
serviceConfigId: helloapiconfig-12giv0bogvdnu
state: ACTIVE
updateTime: '2021-03-18T19:21:30.750688883Z
```
### 2.6 Creating a gateway

Now deploy the API config on a gateway. Deploying an API config on a gateway defines an external URL that API clients can use to access your API.

Run the following command to deploy the API config you just created to API Gateway:

```
gcloud api-gateway gateways create GATEWAY_ID \
  --api=API_ID --api-config=CONFIG_ID \
  --location=GCP_REGION --project=PROJECT_ID
  ```
1. ``GATEWAY_ID`` specifies the name of the gateway.
1. ``API_ID`` specifies the name of the API Gateway API associated with this gateway.
1. ``CONFIG_ID`` specifies the name of the API config deployed to the gateway.
1. ``GCP_REGION`` is the Google Cloud region for the deployed gateway.
  
For me:

```
gcloud api-gateway gateways create hello-gateway \
  --api=helloapi \
  --api-config=helloapiconfig \
  --location=us-central1 \
  --project=it-quality-attributes-302610
  ```
(be sure to replace ``it-quality-attributes-302610`` with your project ID).

This usually takes a few minutes...

### 2.7 Describe the gateway

```
gcloud api-gateway gateways describe hello-gateway \
  --location=us-central1 \
  --project=it-quality-attributes-302610
  ```
(be sure to replace ``it-quality-attributes-302610`` with your project ID).

This produces output like this:

```
apiConfig: projects/749635659654/locations/global/apis/helloapi/configs/helloapiconfig
createTime: '2021-03-18T20:00:43.518978544Z'
defaultHostname: hello-gateway-9kdlpsw6.uc.gateway.dev
displayName: hello-gateway
name: projects/it-quality-attributes-302610/locations/us-central1/gateways/hello-gateway
state: ACTIVE
updateTime: '2021-03-18T20:06:25.825862743Z'
```

### 2.8 Test

We can use curl and ``defaultHostname`` to test our API gateway:

```
curl https://hello-gateway-9kdlpsw6.uc.gateway.dev/hello
```

and you should see:
```
Your IP address is: 35.195.80.208,107
```

or whatever was in the original ``helloGET`` function (may it is just "Hello World")

## Part 3

Now we want multiple paths in our API gateway: For example, we want to export the cloud function ``helloHttp``.

### 3.1 Lab Exercise (10 mins)

1. deploy the nodejs function ``helloHttp`` from the ``index.js`` file from  2.2
2. make a copy of ``openapi2-functions.yaml`` - call it ``openapi2-functions-multi.yaml``
3. add a new path (call it ``hellohttp``)
4. map this path to the ``helloHttp`` cloud function (use the exact same structure as before)
5. now deploy using this syntax:
```
gcloud api-gateway api-configs create helloapiconfig-multi \
  --api=helloapi \
  --openapi-spec=openapi2-functions-multi.yaml \
  --project=it-quality-attributes-302610 \
  --backend-auth-service-account=749635659654-compute@developer.gserviceaccount.com
```
6. Test this and see if you can now call two paths of your API gateway.

## Part 4

### 4.1 Secure Changes
Now we want to protect our API by using an API key. To do this we specify the use of an API key in our yaml under ``paths/hello``

```
security:
- api_key: []

```

and then we add a new section

```
    securityDefinitions:
      # This section configures basic authentication with an API key.
      api_key:
        type: "apiKey"
        name: "key"
        in: "query"
```        
note that the key is to be passed in using  the ``query`` and the name is ``key``

```
# openapi2-functions.yaml
swagger: '2.0'
info:
  title: helloapi a simple API test
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Greet a user
      operationId: hello
      x-google-backend:
        address: https://us-central1-itqa-tester.cloudfunctions.net/helloGET
      security:
      - api_key: []  
      responses:
        '200':
          description: A successful response
          schema:
            type: string
securityDefinitions:
# This section configures basic authentication with an API key.
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"
```

### 4.2 Download and configure

Download and save this file as ``openapi2-functions-secure.yaml``. Then we create a new configuration:

```
gcloud api-gateway api-configs create helloapiconfig-secure \
  --api=helloapi \
  --openapi-spec=openapi2-functions-secure.yaml \
  --project=it-quality-attributes-302610 \
  --backend-auth-service-account=749635659654-compute@developer.gserviceaccount.com
```
### 4.3 Create a new secure gateway
```
gcloud api-gateway gateways create hello-gateway-secure \
  --api=helloapi \
  --api-config=helloapiconfig-secure \
  --location=us-central1 \
  --project=it-quality-attributes-302610
  ```
 
 ### 4.4 Describe the gateway and call it

```
gcloud api-gateway gateways describe hello-gateway-secure \
  --location=us-central1 \
  --project=it-quality-attributes-302610
  ```
 
 and we see our security error:
 
 ```
curl https://hello-gateway-secure-8xsgpja5.uc.gateway.dev/hello
{"message":"UNAUTHENTICATED:Method doesn't allow unregistered callers (callers without established identity). 
Please use API Key or other form of API consumer identity to call this API.","code":401}
```

### 4.5 Get your API key and call again

```
https://console.cloud.google.com/apis/credentials
```

click create credentials and use them for your function, eg:

```
curl https://hello-gateway-secure-8xsgpja5.uc.gateway.dev/hello?key="rbKN8AmrbKN8AkTdn948"
```

