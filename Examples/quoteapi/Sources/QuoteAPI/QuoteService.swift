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
import OpenAPIRuntime
import OpenAPILambda
// import ServiceLifecycle

@main
struct QuoteServiceImpl: APIProtocol, OpenAPILambdaHttpApi {

    func register(transport: OpenAPILambdaTransport) throws {
        try self.registerHandlers(on: transport)
    }

    static func main() async throws {

        // when you just need to run the Lambda function, call Self.run()
        try await Self.run()

        // =============================

        // when you need to have access to the runtime for advanced usage (dependency injection, Service LifeCycle, etc)
        // create the LambdaRuntime and run it

        // Here is an example with Service Lifecycle
        // Add the following in Package.swift
        //    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.6.0"),
        // and
        //    .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        // Add `import ServiceLifecycle` at the top of this file`

        // let lambdaRuntime = try LambdaRuntime(body: Self.handler())
        // try await lambdaRuntime.run()
        // let serviceGroup = ServiceGroup(
        //     services: [lambdaRuntime],
        //     gracefulShutdownSignals: [.sigterm],
        //     cancellationSignals: [.sigint],
        //     logger: Logger(label: "ServiceGroup")
        // )
        // try await serviceGroup.run()

        // =============================

        // When you need full control on this struct lifecycle, for example to inject dependencies,
        // you can create your own instance of `OpenAPILambda`
        // 1. add your custom init() function
        // 2. create an instance of this struct, inject any required dependencies,
        //    such as a database connection
        // 3. create the lambda handler and pass the instance to its initializer
        // 4. create the lambda runtime and pass the handler to its initializer

        // let openAPIService = QuoteServiceImpl(i: 42) // 2.
        // let lambda = try OpenAPILambdaHandler(service: openAPIService) // 3.
        // let lambdaRuntime = LambdaRuntime(body: lambda.handler) // 4.
        // try await lambdaRuntime.run()
    }

    // example of dependency injection when using a custom initializer
    // let i: Int
    // init(i: Int) { // 1.
    //     self.i = i
    // }
    // init() { self.i = 0 } // to comply with protocol

    func getQuote(_ input: Operations.getQuote.Input) async throws -> Operations.getQuote.Output {

        let symbol = input.path.symbol

        var date: Date = Date()
        if let dateString = input.query.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            date = dateFormatter.date(from: dateString) ?? Date()
        }

        let price = Components.Schemas.quote(
            symbol: symbol,
            price: Double.random(in: 100..<150).rounded(),
            change: Double.random(in: -5..<5).rounded(),
            changePercent: Double.random(in: -0.05..<0.05),
            volume: Double.random(in: 10000..<100000).rounded(),
            timestamp: date
        )

        return .ok(.init(body: .json(price)))
    }
}
