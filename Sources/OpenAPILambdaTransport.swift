//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OpenAPI Lambda open source project
//
// Copyright (c) 2023 Amazon.com, Inc. or its affiliates
//                    and the Swift OpenAPI Lambda project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift OpenAPI Lambda project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Data types for OpenAPI over an Lambda HTTP transport
/// This library uses `String?` as body type, it is aligned to `AWSLambdaEvents.APIGatewayV2Request`
/// This library doesn't support streaming HTTP responses (nor does the AWS Lambda Runtime 1.0.0)

/// The request made to the OpenAPILambda
public typealias OpenAPILambdaRequest = (HTTPRequest, String?)

/// The response from the OpenAPILambda
public typealias OpenAPILambdaResponse = (HTTPResponse, String?)

/// the parameters collected on the input
public typealias OpenAPILambdaRequestParameters = [String: Substring]

/// an OpenAPI handler
public typealias OpenAPIHandler = @Sendable (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (
    HTTPResponse, HTTPBody?
)

/// Lambda Transport for OpenAPI generator
public struct OpenAPILambdaTransport: ServerTransport {

    private var router: OpenAPILambdaRouter

    /// Create a `OpenAPILambdaTransport` with the given `OpenAPILambdaRouter`
    public init(router: OpenAPILambdaRouter) { self.router = router }

    /// Registers an HTTP operation handler at the provided path and method.
    /// - Parameters:
    ///   - handler: A handler to be invoked when an HTTP request is received.
    ///   - method: An HTTP request method.
    ///   - path: The URL path components, for example `["pets", ":petId"]`.
    ///   - queryItemNames: The names of query items to be extracted
    ///   from the request URL that matches the provided HTTP operation.
    public func register(_ handler: @escaping OpenAPIHandler, method: HTTPRequest.Method, path: String) throws {
        try self.router.add(method: method, path: path, handler: handler)
    }
}
