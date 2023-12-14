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
    /// Initializes and runs the Lambda function.
    ///
    /// If you precede your ``EventLoopLambdaHandler`` conformer's declaration with the
    /// [@main](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID626)
    /// attribute, the system calls the conformer's `main()` method to launch the lambda function.
    public static func main() throws { OpenAPILambdaHandler<Self>.main() }
}
