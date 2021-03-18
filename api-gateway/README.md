# API Gateways

## Learning outcomes

1. To create an API project
2. To deploy a set of cloud functions that act as the members of the API
3. To design and deploy an OpenAPI config into the API project
4. To test and validate the API gateway behaviour

### 1.1 Creating an API

In this example we will use the a set of HTTP cloud functions to provide an API that a mbiled client can call. Obviouslly, the purpose is to avoid the mobile client havingn to navigate and co-ordinate these functions itself.   

To begin, we create an API (called ``WeatherAPI`` attached to our project)

```
 gcloud api-gateway apis create weatherapi --project=PROJECT_ID
```

This simply serves as the holdOn successful completion, you can use the following command to view details about the new APIing area for the API - the configuration of the API comes later.

On successful completion, you can use the following command to view details about the new API:

### 1.2 Describing the API
```
gcloud api-gateway apis describe weatherapi --project=PROJECT_ID
```
This command returns something the following:

```
createTime: '2021-03-18T10:20:02.620875731Z'
displayName: weatherapi
managedService: weatherapi-12k4oabzjy9ze.apigateway.it-quality-attributes-302610.cloud.goog
name: projects/it-quality-attributes-302610/locations/global/apis/weatherapi
state: ACTIVE
updateTime: '2021-03-18T10:21:40.272559300Z'
```

The gcloud command-line tool takes many options, including those described in the gcloud Reference. In addition, for API Gateway, you can set the following options when creating an API:

``--async:`` Return control to the terminal immediately, without waiting for the operation to complete.

But obviously we did not use ``--async`` so we would expect the client to block waiting for the results of the API call.

## 2.1 Creating an API config

### API config ID requirements
Many of the ``gcloud`` commands shown below require you to specify the ID of the API config, in the form: ``CONFIG_ID``. API Gateway enforces the following requirements for the API config ID:

1. Must have a maximum length of 63 characters.
1. Must contain only lowercase letters, numbers, or dashes.
1. Must not start with a dash.
1. Must not contain an underscore.

### Anatomy of an OpenAPI config

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
