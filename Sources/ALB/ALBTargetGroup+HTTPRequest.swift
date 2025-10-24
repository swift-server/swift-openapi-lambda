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

extension ALBTargetGroupRequest {

    /// Return an `HTTPRequest` for this `ALBTargetGroupRequest`
    public func httpRequest() throws -> HTTPRequest {
        HTTPRequest(
            method: self.httpMethod,
            scheme: nil,
            authority: nil,
            path: self.path,
            headerFields: self.headers?.httpFields() ?? [:]
        )
    }
}

extension ALBTargetGroupResponse {

    /// Create a `APIGatewayV2Response` from an `HTTPResponse`
    public init(from response: HTTPResponse) {
        self = ALBTargetGroupResponse(
            statusCode: response.status,
            statusDescription: response.debugDescription,
            headers: .init(from: response.headerFields),
            multiValueHeaders: nil,
            isBase64Encoded: false
        )
    }
}
