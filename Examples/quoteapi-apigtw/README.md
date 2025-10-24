# QuoteAPI

This application illustrates how to deploy a Server-Side Swift workload on AWS using the [AWS Serverless Application Model (SAM)](https://aws.amazon.com/serverless/sam/) toolkit. The workload is a simple REST API that returns a string from an Amazon API Gateway. Requests to the API Gateway endpoint are handled by an AWS Lambda Function written in Swift.

## Prerequisites

To build this sample application, you need:

- [AWS Account](https://console.aws.amazon.com/)
- [AWS Command Line Interface (AWS CLI)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) - install the CLI and [configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) it with credentials to your AWS account
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) - a command-line tool used to create serverless workloads on AWS
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) - to compile your Swift code for Linux deployment to AWS Lambda

## Build the application

The **sam build** command uses Docker to compile your Swift Lambda function and package it for deployment to AWS.

```bash
sam build
```

On macOS, you might need to run this command if `sam` doesn't see `docker`:
```bash
export DOCKER_HOST=unix://$HOME/.docker/run/docker.sock
```

## Deploy the application

The **sam deploy** command creates the Lambda function and API Gateway in your AWS account.

```bash
sam deploy --guided
```

The project creates an API endpoint protected by a bearer token authorization. Use token value '123' while testing. Youc an change the token validation logic in the `LambdaAuthorizer` function. To learn more about Lambda authorizer function, refer to [the API Gateway documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html).

## Use the API

At the end of the deployment, SAM displays the endpoint of your API Gateway:

```bash
Outputs
----------------------------------------------------------------------------------------
Key                 SwiftAPIEndpoint
Description         API Gateway endpoint URL for your application
Value               https://[your-api-id].execute-api.[your-aws-region].amazonaws.com
----------------------------------------------------------------------------------------
```

Use cURL or a tool such as [Postman](https://www.postman.com/) to interact with your API. Replace **[your-api-endpoint]** with the SwiftAPIEndpoint value from the deployment output.

**Invoke the API Endpoint**

```bash
curl -H 'Authorization: Bearer 123' https://[your-api-endpoint]/stocks/AMZN
```

## Test the API Locally
SAM also allows you to execute your Lambda functions locally on your development computer. Follow these instructions to execute the Lambda function locally. Further capabilities can be explored in the [SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-invoke.html).

**Event Files**

When a Lambda function is invoked, API Gateway sends an event to the function with all the data packaged with the API call. When running the functions locally, you pass in a json file to the function that simulates the event data. The **events** folder contains a json file for the function.

**Invoke the Lambda Function Locally**

```bash
sam local invoke QuoteService --event events/GetQuote.json
```

On macOS, you might need to run this command if `sam` doesn't see `docker`:
```bash
export DOCKER_HOST=unix://$HOME/.docker/run/docker.sock
```

## Cleanup

When finished with your application, use SAM to delete it from your AWS account. Answer **Yes (y)** to all prompts. This will delete all of the application resources created in your AWS account.

```bash
sam delete
```

## ⚠️ Security and Reliability Notice

This is an example application for demonstration purposes. When deploying such infrastructure in production environments, we strongly encourage you to follow these best practices for improved security and resiliency:

- Enable access logging on API Gateway ([documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html))
- Ensure that AWS Lambda function is configured for function-level concurrent execution limit ([concurrency documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html), [configuration guide](https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html))
- Check encryption settings for Lambda environment variables ([documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars-encryption.html))
- Ensure that AWS Lambda function is configured for a Dead Letter Queue (DLQ) ([documentation](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-retain-records.html#invocation-dlq))
- Ensure that AWS Lambda function is configured inside a VPC when it needs to access private resources ([documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html), [code example](https://github.com/awslabs/swift-aws-lambda-runtime/tree/main/Examples/ServiceLifecycle%2BPostgres))

**Note:** The `openapi.yaml` file in this example is not suited for production. In real-world scenarios, you must:
1. Ensure that the global security field has rules defined
2. Ensure that security operations is not empty ([OpenAPI Security Specification](https://learn.openapis.org/specification/security.html))
3. Follow proper authentication, authorization, input validation, and error handling practices

As per Checkov CKV_OPENAPI_4 and CKV_OPENAPI_5 security checks.
