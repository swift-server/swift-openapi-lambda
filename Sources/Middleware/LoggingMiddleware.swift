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

import HTTPTypes
import Logging
import OpenAPIRuntime

/// A middleware that logs request and response metadata.
/// Only active at .trace level
public struct LoggingMiddleware: ServerMiddleware {

		private let logger: Logger
		public init(logger: Logger) {
				self.logger = logger
		}

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
        } catch {
            logger.trace("!!!: \(error.localizedDescription)")
            throw error
        }
    }

}
