//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OpenAPI Lambda open source project
//
// Copyright Swift OpenAPI Lambda project authors
// Copyright (c) 2023 Amazon.com, Inc. or its affiliates.
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift OpenAPI Lambda project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import AWSLambdaEvents
import Foundation
import HTTPTypes
import Testing

@testable import OpenAPILambda

struct ALBConversionTests {

    static let albEventJSON = """
        {
          "requestContext": {
            "elb": {
              "targetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/lambda-target/50dc6c495c0c9188"
            }
          },
          "httpMethod": "GET",
          "path": "/stocks/AAPL",
          "queryStringParameters": {},
          "headers": {
            "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            "host": "lambda-alb-123578498.us-east-1.elb.amazonaws.com",
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
          },
          "body": "",
          "isBase64Encoded": false
        }
        """

    @Test("ALB request to HTTPRequest conversion")
    func testALBRequestToHTTPRequest() throws {
        let data = ALBConversionTests.albEventJSON.data(using: .utf8)!
        let albRequest = try JSONDecoder().decode(ALBTargetGroupRequest.self, from: data)

        let httpRequest = try albRequest.httpRequest()

        #expect(httpRequest.method == HTTPRequest.Method.get)
        #expect(httpRequest.path == "/stocks/AAPL")
        #expect(
            httpRequest.headerFields[HTTPField.Name.accept]
                == "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        )
        #expect(httpRequest.headerFields[HTTPField.Name("host")!] == "lambda-alb-123578498.us-east-1.elb.amazonaws.com")
        #expect(
            httpRequest.headerFields[HTTPField.Name.userAgent]
                == "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        )
    }

    @Test("ALB X-Forwarded-Proto and Host mapping")
    func testALBForwardedHeaders() throws {
        let albEventWithForwardedHeaders = """
            {
              "requestContext": {
                "elb": {
                  "targetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/lambda-target/50dc6c495c0c9188"
                }
              },
              "httpMethod": "GET",
              "path": "/stocks/AAPL",
              "queryStringParameters": {},
              "headers": {
                "Host": "lambda-alb-123578498.us-east-1.elb.amazonaws.com",
                "X-Forwarded-Proto": "https"
              },
              "body": "",
              "isBase64Encoded": false
            }
            """

        let data = albEventWithForwardedHeaders.data(using: .utf8)!
        let albRequest = try JSONDecoder().decode(ALBTargetGroupRequest.self, from: data)

        let httpRequest = try albRequest.httpRequest()

        #expect(httpRequest.scheme == "https")
        #expect(httpRequest.authority == "lambda-alb-123578498.us-east-1.elb.amazonaws.com")
    }

    @Test("ALB lowercase headers mapping")
    func testALBLowercaseHeaders() throws {
        let albEventWithLowercaseHeaders = """
            {
              "requestContext": {
                "elb": {
                  "targetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/lambda-target/50dc6c495c0c9188"
                }
              },
              "httpMethod": "GET",
              "path": "/stocks/AAPL",
              "queryStringParameters": {},
              "headers": {
                "host": "lambda-alb-123578498.us-east-1.elb.amazonaws.com",
                "x-forwarded-proto": "https"
              },
              "body": "",
              "isBase64Encoded": false
            }
            """

        let data = albEventWithLowercaseHeaders.data(using: .utf8)!
        let albRequest = try JSONDecoder().decode(ALBTargetGroupRequest.self, from: data)

        let httpRequest = try albRequest.httpRequest()

        #expect(httpRequest.scheme == "https")
        #expect(httpRequest.authority == "lambda-alb-123578498.us-east-1.elb.amazonaws.com")
    }

    @Test("HTTPResponse to ALB response conversion")
    func testHTTPResponseToALBResponse() throws {
        var httpResponse = HTTPResponse(status: .ok)
        httpResponse.headerFields[HTTPField.Name.contentType] = "application/json"
        httpResponse.headerFields[HTTPField.Name.contentLength] = "42"

        let albResponse = ALBTargetGroupResponse(from: httpResponse)

        #expect(albResponse.statusCode == .ok)
        #expect(albResponse.headers?[HTTPField.Name.contentType.rawName] == "application/json")
        #expect(albResponse.headers?[HTTPField.Name.contentLength.rawName] == "42")
        #expect(albResponse.isBase64Encoded == false)
    }


}
