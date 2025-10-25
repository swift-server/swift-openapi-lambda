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
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
import OpenAPIRuntime
import HTTPTypes

/// An specialization of the `OpenAPILambda` protocol that works with an Application Load Balancer
public protocol OpenAPILambdaALB: OpenAPILambdaService
where
    Event == ALBTargetGroupRequest,
    Output == ALBTargetGroupResponse
{}


extension OpenAPILambdaALB {
    /// Transform a Lambda input (`ALBTargetGroupRequest` and `LambdaContext`) to an OpenAPILambdaRequest (`HTTPRequest`, `String?`)
    public func request(context: LambdaContext, from request: Event) throws -> OpenAPILambdaRequest {
        (try request.httpRequest(), request.body)
    }

    /// Transform an OpenAPI response (`HTTPResponse`, `String?`) to a Lambda Output (`ALBTargetGroupResponse`)
    public func output(from response: OpenAPILambdaResponse) -> Output {
        var apiResponse = ALBTargetGroupResponse(from: response.0)
        apiResponse.body = response.1 ?? ""
        return apiResponse
    }
}
