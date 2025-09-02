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
public protocol OpenAPILambda {

    associatedtype Event: Decodable
    associatedtype Output: Encodable

    /// Initialize application.
    ///
    /// This is where you create your OpenAPI service implementation and register the transport
    init(transport: OpenAPILambdaTransport) throws

    /// Convert from `Event` type to `OpenAPILambdaRequest`
    /// - Parameters:
    ///   - context: Lambda context
    ///   - from: Event
    func request(context: LambdaContext, from: Event) throws -> OpenAPILambdaRequest

    /// Convert from `OpenAPILambdaResponse` to `Output` type
    /// - Parameter from: response from OpenAPIRuntime
    func output(from: OpenAPILambdaResponse) -> Output
}

extension OpenAPILambda {
    /// Returns the Lambda handler function for this OpenAPI Lambda implementation.
    /// - Returns: A handler function that can be used with AWS Lambda Runtime
    public static func handler() throws -> (Event, LambdaContext) async throws -> Output {
        try OpenAPILambdaHandler<Self>().handler
    }

    /// Start the Lambda Runtime with the Lambda handler function for this OpenAPI Lambda implementation with a custom logger,
    /// when one is given.
    /// - Parameter logger: The logger to use for Lambda runtime logging
    public static func run(logger: Logger? = nil) async throws {

        let _logger = logger ?? Logger(label: "OpenAPILambda")
        #if swift(>=6.2)
        let box = UnsafeTransferBox(value: try Self.handler())
        let lambdaRuntime = LambdaRuntime(logger: _logger, body: box.value)
        #else
        let lambdaHandler = try Self.handler()
        let lambdaRuntime = LambdaRuntime(logger: _logger, body: lambdaHandler)
        #endif
        try await lambdaRuntime.run()
    }
}

// on Swift 6.2, with approachable concurrency, the compiler considers
// the `lambdaHandler` can not be sent to the `LambdaRuntime(body:)` directly
// despite the fact `lambdaHandler` is not used after that
// There are two workarounds:
// - make `OpenAPILambda` conform to `Sendable`. But this would require users to ensure their implementations are also `Sendable`
// - wrap the handler in a `UnsafeTransferBox`
#if swift(>=6.2)
fileprivate struct UnsafeTransferBox<Value>: @unchecked Sendable {
    let value: Value
    init(value: Value) {
        self.value = value
    }
}
#endif
