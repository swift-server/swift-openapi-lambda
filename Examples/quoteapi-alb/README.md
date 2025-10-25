# QuoteAPI ALB Example

This application illustrates how to deploy a Server-Side Swift workload on AWS using an Application Load Balancer (ALB) with Lambda targets. The workload is a simple REST API that returns stock quotes. Requests to the ALB are forwarded to an AWS Lambda Function written in Swift using the OpenAPI Lambda library.

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

The **sam deploy** command creates the Lambda function, Application Load Balancer, and associated VPC resources in your AWS account.

```bash
sam deploy --guided
```

## Use the API

At the end of the deployment, SAM displays the endpoint of your Application Load Balancer:

```bash
Outputs
----------------------------------------------------------------------------------------
Key                 QuoteAPILoadBalancerURL
Description         Application Load Balancer URL for QuoteAPI
Value               http://QuoteAPILoadBalancer-123456789.us-east-1.elb.amazonaws.com/stocks/AAPL
----------------------------------------------------------------------------------------
```

Use cURL or a tool such as [Postman](https://www.postman.com/) to interact with your API. Replace **[your-alb-endpoint]** with the QuoteAPILoadBalancerURL value from the deployment output.

**Invoke the API Endpoint**

```bash
curl http://[your-alb-endpoint]/stocks/AMZN
```

## Test the API Locally

SAM also allows you to execute your Lambda functions locally on your development computer.

**Invoke the Lambda Function Locally**

```bash
sam local invoke QuoteServiceALB --event events/GetQuote.json
```

On macOS, you might need to run this command if `sam` doesn't see `docker`:
```bash
export DOCKER_HOST=unix://$HOME/.docker/run/docker.sock
```

## Architecture

This example demonstrates:

- **Application Load Balancer**: Routes HTTP requests to Lambda functions
- **Lambda Target Group**: Configures the ALB to forward requests to Lambda
- **VPC Setup**: Creates a VPC with public subnets for the ALB
- **Security Groups**: Controls inbound traffic to the ALB
- **OpenAPI Integration**: Uses Swift OpenAPI Lambda library with ALB events

## Cleanup

When finished with your application, use SAM to delete it from your AWS account. Answer **Yes (y)** to all prompts. This will delete all of the application resources created in your AWS account.

```bash
sam delete
```

> **⚠️ Security and Reliability Notice**
> 
> This is an example application for demonstration purposes. When deploying such infrastructure in production environments, we strongly encourage you to follow these best practices for improved security and resiliency:
> 
> - Enable access logging on Application Load Balancer ([documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html))
> - Ensure that AWS Lambda function is configured for function-level concurrent execution limit ([concurrency documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html), [configuration guide](https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html))
> - Check encryption settings for Lambda environment variables ([documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars-encryption.html))
> - Ensure that AWS Lambda function is configured for a Dead Letter Queue (DLQ) ([documentation](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-retain-records.html#invocation-dlq))
> - Configure HTTPS/TLS termination on the Application Load Balancer ([documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html))
> 
> **Note:** The `openapi.yaml` file in this example is not suited for production. In real-world scenarios, you must:
> 1. Ensure that the global security field has rules defined
> 2. Ensure that security operations is not empty ([OpenAPI Security Specification](https://learn.openapis.org/specification/security.html))
> 3. Follow proper authentication, authorization, input validation, and error handling practices
> 
> As per Checkov CKV_OPENAPI_4 and CKV_OPENAPI_5 security checks.
