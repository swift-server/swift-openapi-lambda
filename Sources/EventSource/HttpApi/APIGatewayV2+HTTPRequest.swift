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
import HTTPTypes
import OpenAPIRuntime

extension APIGatewayV2Request {

    // OpenAPIGenerator expects the path to include the query string
    var pathWithQueryString: String {
        rawPath + (rawQueryString.isEmpty ? "" : "?\(rawQueryString)")
    }

    /// Return an `HTTPRequest` for this `APIGatewayV2Request`
    public func httpRequest() throws -> HTTPRequest {
        HTTPRequest(
            method: self.context.http.method,
            scheme: "https",  // APIGateway is always HTTPS
            authority: self.headers["Host"],
            path: pathWithQueryString,
            headerFields: self.headers.httpFields()
        )
    }
}

extension APIGatewayV2Response {

    /// Create a `APIGatewayV2Response` from an `HTTPResponse`
    public init(from response: HTTPResponse) {
        self = APIGatewayV2Response(
            statusCode: response.status,
            headers: .init(from: response.headerFields),
            isBase64Encoded: false,
            cookies: nil
        )
    }
}
