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
import OpenAPIRuntime


// TODO: add more method to simplify usage

// Current API :

// try router.add(
//     method: .get,
//     path: "/health"
// ) { (request: HTTPRequest, body: HTTPBody?, metadata: ServerRequestMetadata) -> (HTTPResponse,HTTPBody?) in
//     return (.init(status: .ok), .init("OK"))
// }

// should be

// try router.get("/health") { _ in
//     "OK"
// }

extension OpenAPILambdaRouter {

    /// Adds a GET route to the router for the given path.
    ///
    /// The given handler retruns a String that will be converted to the correct response type.
    /// It will return an HTTP 200 response or HTTP 500 if your handler throws and error
    /// - Parameters:
    ///   - path: The path for the route.
    ///   - handler: The handler to be executed for the route.
    /// - Throws: An error if the route cannot be added.
    public func get(
        _ path: String,
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> String
    ) throws {
        try generic(method: .get, path: path, handler: handler)
    }

    /// Adds a POST route to the router for the given path.
    ///
    /// The given handler retruns a String that will be converted to the correct response type.
    /// It will return an HTTP 200 response or HTTP 500 if your handler throws and error
    /// - Parameters:
    ///   - path: The path for the route.
    ///   - handler: The handler to be executed for the route.
    /// - Throws: An error if the route cannot be added.
    public func post(
        _ path: String,
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> String
    ) throws {
        try generic(method: .post, path: path, handler: handler)
    }

    func generic<Response: StringProtocol & Sendable>(
        method: HTTPRequest.Method,
        path: String,
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> Response
    ) throws {

        let openAPIHandler: OpenAPIHandler = {
            (request: HTTPRequest, body: HTTPBody?, metadata: ServerRequestMetadata) -> (HTTPResponse, HTTPBody?) in
            do {
                let response = try await handler(request, body)
                return (.init(status: .ok), .init(response))
            }
            catch {
                return (.init(status: .internalServerError), nil)
            }
        }

        try add(method: method, path: path, handler: openAPIHandler)
    }
}
