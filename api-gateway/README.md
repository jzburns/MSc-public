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
createTime: '2022-03-12T12:40:37.828374233Z'
displayName: helloapi
managedService: helloapi-0cjkm7osti9z9.apigateway.mscitqa.cloud.goog
name: projects/mscitqa/locations/global/apis/helloapi
state: ACTIVE
updateTime: '2022-03-12T12:42:14.518710937Z'
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

Lets look at an OpenAPI config that uses the ``helloGET`` cloud function we have seen previously, contained in the file ``openapi-function.yml``

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
      ##TODO: Change this address to yous cloud function full path
        address: https://GCP_REGION-PROJECT_ID.cloudfunctions.net/helloGET
      responses:
        '200':
          description: A successful response
          schema:
            type: string
```
**TODO**
1. Replace ``https://GCP_REGION-PROJECT_ID.cloudfunctions.net/helloGET`` with your cloud function full path


### 2.4 Upload this file

Now that we have deployed our cloud function and configured our API gateway config file, we need to submit it to the management service. To do this correctly we need some additional parameters. In particular, we need to know the ``service account`` email address that is used to create the API.

```
gcloud api-gateway api-configs create helloapicfg \
  --api=helloapi \
  --openapi-spec=openapi-function.yml \
  --project=PROJECT_ID
```
**TODO**
1. Replace ``PROJECT_ID`` with your project ID


### 2.5 Describe the Service

We can now describe the API gateway:

```
gcloud api-gateway api-configs describe helloapicfg \
--api=helloapi \
--project=PROJECT_ID 
```
**TODO**
1. Replace ``PROJECT_ID`` with your project ID

this should yield the following information

```
createTime: '2022-03-12T13:40:22.641318676Z'
displayName: helloapicfg
gatewayServiceAccount: projects/-/serviceAccounts/743501085081-compute@developer.gserviceaccount.com
name: projects/743501085081/locations/global/apis/helloapi/configs/helloapicfg
serviceConfigId: helloapicfg-1jda9uuercbuc
state: ACTIVE
updateTime: '2022-03-12T13:43:05.759767020Z
```

### 2.6 Creating a gateway

We now want to deploy the config on an API gateway. Deploying an API config on a gateway defines an external URL that API clients can use to access your API.

Run the following command to deploy the API config you just created to API Gateway:

```
gcloud api-gateway gateways create helloapigateway \
  --api=helloapi \
  --api-config=helloapicfg \
  --location=europe-west1 \
  --project=PROJECT_ID
  ```
**TODO**  
1. Replace ``PROJECT_ID`` with your project ID
  
This usually takes a few minutes...

### 2.7 Describe the gateway

```
gcloud api-gateway gateways describe hello-gateway \
  --location=us-central1 \
  --project=PROJECT_ID
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

### 3.1 Secure Changes
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

### 3.2 Download and configure

Download and save this file as ``openapi2-functions-secure.yaml``. Then we create a new configuration:

```
gcloud api-gateway api-configs create helloapiconfig-secure \
  --api=helloapi \
  --openapi-spec=openapi2-functions-secure.yaml \
  --project=it-quality-attributes-302610 \
  --backend-auth-service-account=749635659654-compute@developer.gserviceaccount.com
```
### 3.3 Create a new secure gateway
```
gcloud api-gateway gateways create hello-gateway-secure \
  --api=helloapi \
  --api-config=helloapiconfig-secure \
  --location=europe-west1 \
  --project=it-quality-attributes-302610
  ```
 
 ### 3.4 Describe the gateway and call it

```
gcloud api-gateway gateways describe hello-gateway-secure \
  --location=us-central1 \
  --project=PROJECT_ID
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

