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

    /// Create a new instance of the OpenAPILambdaService.
    init()

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
    /// Returns the Lambda handler function for this OpenAPILambdaService implementation.
    /// Use this function when you create a vanilla OpenAPILambdaService and just need to access its handler
    /// If you need to inject dependencies into your OpenAPILambdaService implementation,
    /// write your own initializer, such as `init(dbConnection:)` on the OpenAPILambdaService implementation,
    /// then create the OpenAPILambdaHandler and the LambdaRuntime manually.
    /// For example:
    ///         let openAPIService = QuoteServiceImpl(i: 42) // my custom OpenAPI service initializer
    ///         let lambda = try OpenAPILambdaHandler(service: openAPIService)
    ///         let lambdaRuntime = LambdaRuntime(body: lambda.handler)
    ///         try await lambdaRuntime.run()
    ///
    /// - Returns: A handler function that can be used with AWS Lambda Runtime
    public static func handler() throws -> (Event, LambdaContext) async throws -> Output {
        try OpenAPILambdaHandler<Self>().handler
    }

    /// Start the Lambda Runtime with the Lambda handler function for this OpenAPI Lambda implementation with a custom logger,
    /// when one is given.
    /// - Parameter logger: The logger to use for Lambda runtime logging
    public static func run(logger: Logger? = nil) async throws {
        let _logger = logger ?? Logger(label: "OpenAPILambdaService")
        let lambdaRuntime = LambdaRuntime(logger: _logger, body: try Self.handler())
        try await lambdaRuntime.run()
    }
}
