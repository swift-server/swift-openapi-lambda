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
import AWSLambdaRuntime
import Logging
import OpenAPIRuntime
import HTTPTypes

/// A Lambda function implemented with a OpenAPI server (implementing `APIProtocol` from Swift OpenAPIRuntime)
public protocol OpenAPILambdaService: Sendable {

    associatedtype Event: Decodable, Sendable
    associatedtype Output: Encodable, Sendable

    /// Injects the transport.
    ///
    /// This is where your OpenAPILambdaService implementation must register the transport
    func register(transport: OpenAPILambdaTransport) throws
    
    /// Convert from `Event` type to `OpenAPILambdaRequest`
    /// - Parameters:
    ///   - context: Lambda context
    ///   - from: Event
    func request(context: LambdaContext, from: Event) throws -> OpenAPILambdaRequest

    /// Convert from `OpenAPILambdaResponse` to `Output` type
    /// - Parameter from: response from OpenAPIRuntime
    func output(from: OpenAPILambdaResponse) -> Output
}

extension OpenAPILambdaService {

    /// Start the Lambda Runtime with the Lambda handler function
    /// for this OpenAPI Lambda service implementation with a custom logger,
    ///
    /// - Parameter logger: The logger to use for Lambda runtime logging
    public func run(logger: Logger? = nil) async throws {
        let _logger = logger ?? Logger(label: "OpenAPILambdaService")

        let lambda = try OpenAPILambdaHandler(withService: self)
        let lambdaRuntime = LambdaRuntime(logger: _logger, body: lambda.handle)
        try await lambdaRuntime.run()
    }
}


