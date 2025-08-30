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

## Deploy the application

The **sam deploy** command creates the Lambda function and API Gateway in your AWS account.

```bash
sam deploy --guided
```

Accept the default response to every prompt, except the following warning:

```bash
QuoteService may not have authorization defined, Is this okay? [y/N]: y
```

The project creates a publicly accessible API endpoint. This is a warning to inform you the API does not have authorization. If you are interested in adding authorization to the API, please refer to the [SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-httpapi.html).

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
curl https://[your-api-endpoint]/stocks/AMZN
```

## Test the API Locally
SAM also allows you to execute your Lambda functions locally on your development computer. Follow these instructions to execute the Lambda function locally. Further capabilities can be explored in the [SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-invoke.html).

**Event Files**

When a Lambda function is invoked, API Gateway sends an event to the function with all the data packaged with the API call. When running the functions locally, you pass in a json file to the function that simulates the event data. The **events** folder contains a json file for the function.

**Invoke the Lambda Function Locally**

```bash
sam local invoke QuoteService --event events/GetQuote.json
```

## Cleanup

When finished with your application, use SAM to delete it from your AWS account. Answer **Yes (y)** to all prompts. This will delete all of the application resources created in your AWS account.

```bash
sam delete
```
