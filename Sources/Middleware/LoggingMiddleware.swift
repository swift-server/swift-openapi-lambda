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

import HTTPTypes
import Logging
import OpenAPIRuntime

/// A middleware that logs request and response metadata.
/// Only active at .trace level
public struct LoggingMiddleware: ServerMiddleware {

    private let logger: Logger

    /// A middleware that logs request and response metadata.
    /// Only active at .trace level
    ///
    /// - Parameters:
    ///   - logger: The logger instance to use for logging request/response data
    ///
    /// - Note: This middleware only logs at .trace level and will not generate output at other log levels
    ///
    public init(logger: Logger) {
        self.logger = logger
    }

    /// Intercepts HTTP requests and logs request/response metadata at trace level.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request
    ///   - body: The request body, if any
    ///   - metadata: Metadata associated with the request
    ///   - operationID: The OpenAPI operation ID for this request
    ///   - next: The next middleware/handler in the chain
    ///
    /// - Returns: A tuple containing the HTTP response and optional response body
    ///
    /// - Throws: Rethrows any errors from downstream handlers
    ///
    /// This method logs:
    /// - The request method and path on entry
    /// - The response status code on successful completion
    /// - Error descriptions if an error occurs
    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        metadata: ServerRequestMetadata,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {

        logger.trace(">>>: \(request.method.rawValue) \(request.path ?? "")")
        do {
            let (response, responseBody) = try await next(request, body, metadata)
            logger.trace("<<<: \(response.status.code)")
            return (response, responseBody)
        }
        catch {
            logger.trace("!!!: \(error.localizedDescription)")
            throw error
        }
    }

}
