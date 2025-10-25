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

struct APIGatewayV2ConversionTests {

    static let apiGatewayEventJSON = """
        {
          "rawQueryString": "",
          "headers": {
            "host": "b2k1t8fon7.execute-api.us-east-1.amazonaws.com",
            "accept": "*/*",
            "user-agent": "curl/8.1.2",
            "authorization": "Bearer 123"
          },
          "requestContext": {
            "apiId": "b2k1t8fon7",
            "http": {
              "sourceIp": "191.95.148.219",
              "userAgent": "curl/8.1.2",
              "method": "GET",
              "path": "/stocks/AAPL",
              "protocol": "HTTP/1.1"
            },
            "timeEpoch": 1701957940365,
            "domainPrefix": "b2k1t8fon7",
            "accountId": "486652066693",
            "time": "07/Dec/2023:14:05:40 +0000",
            "stage": "$default",
            "domainName": "b2k1t8fon7.execute-api.us-east-1.amazonaws.com",
            "requestId": "Pk2gOia2IAMEPOw="
          },
          "isBase64Encoded": false,
          "version": "2.0",
          "routeKey": "$default",
          "rawPath": "/stocks/AAPL"
        }
        """

    static let apiGatewayEventWithQueryJSON = """
        {
          "rawQueryString": "limit=10&offset=0",
          "headers": {
            "host": "b2k1t8fon7.execute-api.us-east-1.amazonaws.com"
          },
          "requestContext": {
            "apiId": "b2k1t8fon7",
            "http": {
              "sourceIp": "191.95.148.219",
              "userAgent": "curl/8.1.2",
              "method": "GET",
              "path": "/stocks/AAPL",
              "protocol": "HTTP/1.1"
            },
            "timeEpoch": 1701957940365,
            "domainPrefix": "b2k1t8fon7",
            "accountId": "486652066693",
            "time": "07/Dec/2023:14:05:40 +0000",
            "stage": "$default",
            "domainName": "b2k1t8fon7.execute-api.us-east-1.amazonaws.com",
            "requestId": "Pk2gOia2IAMEPOw="
          },
          "isBase64Encoded": false,
          "version": "2.0",
          "routeKey": "$default",
          "rawPath": "/stocks/AAPL"
        }
        """

    @Test("API Gateway v2 request to HTTPRequest conversion")
    func testAPIGatewayV2RequestToHTTPRequest() throws {
        let data = APIGatewayV2ConversionTests.apiGatewayEventJSON.data(using: .utf8)!
        let apiGatewayRequest = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let httpRequest = try apiGatewayRequest.httpRequest()

        #expect(httpRequest.method == HTTPRequest.Method.get)
        #expect(httpRequest.path == "/stocks/AAPL")
        #expect(httpRequest.scheme == "https")
        #expect(httpRequest.headerFields[HTTPField.Name("host")!] == "b2k1t8fon7.execute-api.us-east-1.amazonaws.com")
        #expect(httpRequest.headerFields[HTTPField.Name.accept] == "*/*")
        #expect(httpRequest.headerFields[HTTPField.Name.userAgent] == "curl/8.1.2")
        #expect(httpRequest.headerFields[HTTPField.Name.authorization] == "Bearer 123")
    }

    @Test("API Gateway v2 request with query string")
    func testAPIGatewayV2RequestWithQueryString() throws {
        let data = APIGatewayV2ConversionTests.apiGatewayEventWithQueryJSON.data(using: .utf8)!
        let apiGatewayRequest = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let httpRequest = try apiGatewayRequest.httpRequest()

        #expect(httpRequest.path == "/stocks/AAPL?limit=10&offset=0")
    }

    @Test("HTTPResponse to API Gateway v2 response conversion")
    func testHTTPResponseToAPIGatewayV2Response() throws {
        var httpResponse = HTTPResponse(status: .ok)
        httpResponse.headerFields[HTTPField.Name.contentType] = "application/json"
        httpResponse.headerFields[HTTPField.Name.contentLength] = "42"

        let apiGatewayResponse = APIGatewayV2Response(from: httpResponse)

        #expect(apiGatewayResponse.statusCode == .ok)
        #expect(apiGatewayResponse.headers?[HTTPField.Name.contentType.rawName] == "application/json")
        #expect(apiGatewayResponse.headers?[HTTPField.Name.contentLength.rawName] == "42")
        #expect(apiGatewayResponse.isBase64Encoded == false)
        #expect(apiGatewayResponse.cookies == nil)
    }
}
