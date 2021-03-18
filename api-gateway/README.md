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

This simply serves as the holdOn successful completion, you can use the following command to view details about the new APIing area for the API - the configuration of the API comes later.

On successful completion, you can use the following command to view details about the new API:

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

### 2.2 Anatomy of an OpenAPI config

First, lets look at an OpenAPI config that uses a cloud function we have seen previously:

```
# openapi2-functions.yaml
swagger: '2.0'
info:
  title: API_ID optional-string
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
### 2.3 Deploy the backend

Do you remember this?

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
#### Exercise - 5 minutes

Take 5 minutes to locate and deploy ``helloGET`` - we did this already in a previous lab

### 2.3 Save and Configure

1. To upload this OpenAPI spec and create an API config using the gcloud command line tool:
1. From the command line, create a new file named ``openapi2-functions.yaml``
1. Copy and paste the contents of the OpenAPI spec shown above into the newly created file.

Edit the file as follows:

1. In the title field, replace API_ID with the name of your API and replace optional-string with a brief description of your choosing. 
1. In the address field, replace ``GCP_REGION`` with the ``GCP`` region of the deployed function and ``PROJECT_ID`` with the name of your Google Cloud project.

### 2.4 Upload this file

Now that we have deployed our cloud function and configured our API gateway config file, we need to submit it to the management service. To do this correctly we need some additional parameters. In particular, we need to know the ``service account`` email address that is used to create the API.

```
gcloud api-gateway api-configs create gcloud api-gateway api-configs create CONFIG_ID \
  --api=API_ID --openapi-spec=API_DEFINITION \
  --project=PROJECT_ID --backend-auth-service-account=SERVICE_ACCOUNT_EMAILCONFIG_ID \
```
Typically, the ``SERVICE_ACCOUNT_EMAILCONFIG_ID`` field [can be found by visiting the GCP IAM page](https://console.cloud.google.com/iam-admin) 

![image](https://user-images.githubusercontent.com/3818964/111679672-52399f00-8819-11eb-9e13-4457b4d8ea71.png)

You can see in the above screenshot that my ID is based on the ``Compute Engine default service account`` column: ``749635659654-compute@developer.gserviceaccount.com``

The field ``API_DEFINITION`` specifies the name of the OpenAPI spec containing the API definition. So choose whatever name you like (I will use ``helloapi-config``). So now, my gateway config command looks like this:

```
gcloud api-gateway api-configs create gcloud api-gateway api-configs create openapi2-functions.yaml \
  --api=helloapi --openapi-spec=helloapi-config \
  --project=it-quality-attributes-302610 --backend-auth-service-account=749635659654-compute@developer.gserviceaccount.com \
```




