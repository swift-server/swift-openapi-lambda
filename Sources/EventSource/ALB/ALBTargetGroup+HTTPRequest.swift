//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OpenAPI Lambda open source project
//
// Copyright Swift OpenAPI Lambda project authors
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates.
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
        let headers = self.headers ?? [:]
        let scheme = headers.first { $0.key.lowercased() == "x-forwarded-proto" }?.value
        let authority = headers.first { $0.key.lowercased() == "host" }?.value

        return HTTPRequest(
            method: self.httpMethod,
            scheme: scheme,
            authority: authority,
            path: self.path,
            headerFields: headers.httpFields()
        )
    }
}

extension ALBTargetGroupResponse {

    /// Create an `ALBTargetGroupResponse` from an `HTTPResponse`
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
