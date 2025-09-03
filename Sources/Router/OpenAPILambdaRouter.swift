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
import AWSLambdaEvents
import Foundation
import HTTPTypes

/// Errors returned by the router
public enum OpenAPILambdaRouterError: Error {
    case noRouteForPath(String)
    case noHandlerForPath(String)
    case noRouteForMethod(HTTPRequest.Method)
}

/// A router API
public protocol OpenAPILambdaRouter: Sendable {
    /// add a route for a given HTTP method and path and associate a handler
    func add(method: HTTPRequest.Method, path: String, handler: @escaping OpenAPIHandler) throws

    /// Retrieve the handler and path parameter for a given HTTP method and path
    func route(method: HTTPRequest.Method, path: String) throws -> (
        OpenAPIHandler, OpenAPILambdaRequestParameters
    )
}
