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

import Foundation
import Logging
import OpenAPIRuntime
import OpenAPILambda
import ServiceLifecycle

@main
struct QuoteServiceImpl: APIProtocol, OpenAPILambdaHttpApi {

    let logger: Logger

    func register(transport: OpenAPILambdaTransport) throws {

        // OPTIONAL
        // you have a chance here to customize the routes, for example
        try transport.router.get("/health") { _, _ in
            "OK"
        }
        logger.trace("Available Routes\n\(transport.router)")  // print the router tree (for debugging purposes)

        // OPTIONAL
        // to log all requests and their responses, add a logging middleware
        let loggingMiddleware = LoggingMiddleware(logger: logger)

        // OPTIONAL
        // This app includes a sample authorization middleware
        // It transforms the bearer token into a username.
        // The user name can be access through a TaskLocal variable.
        let authenticationMiddleware = self.authenticationMiddleware()

        // MANDATORY (middlewares are optional)
        try self.registerHandlers(on: transport, middlewares: [loggingMiddleware, authenticationMiddleware])
    }

    static func main() async throws {

        // when you just need to run the Lambda function, call Self.run()
        let openAPIService = QuoteServiceImpl(i: 42)  // with dependency injection
        try await openAPIService.run()

        // =============================

        // when you need to have access to the runtime for advanced usage
        // (dependency injection, Service LifeCycle, etc)
        //
        // 1. Create the open API lambda service,
        // 2. Pass it to an OpenAPI Lambda Handler
        // 3. Create the Lambda Runtime service, passing the handler
        // 4. Either start the runtime, or add it to a service lifecycle group.

        // Here is an example where you start your own Lambda runtime

        // let openAPIService = QuoteServiceImpl(i: 42) // 1.
        // let lambda = try OpenAPILambdaHandler(withService: openAPIService) // 2.
        // let lambdaRuntime = LambdaRuntime(body: lambda.handle) // 3.
        // try await lambdaRuntime.run() // 4.


        // =============================

        // Here is an example with Service Lifecycle
        // Add the following in Package.swift
        //    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.8.0"),
        // and
        //    .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
        // Add `import ServiceLifecycle` at the top of this file`

        // let openAPIService = QuoteServiceImpl(i: 42) // 1.
        // let lambda = try OpenAPILambdaHandler(withService: openAPIService) // 2.
        // let lambdaRuntime = LambdaRuntime(body: lambda.handle) // 3.
        // let serviceGroup = ServiceGroup(
        //     services: [lambdaRuntime],
        //     gracefulShutdownSignals: [.sigterm],
        //     cancellationSignals: [.sigint],
        //     logger: Logger(label: "ServiceGroup")
        // )
        // try await serviceGroup.run() // 4.

    }

    // example of dependency injection
    let i: Int
    init(i: Int) {
        self.i = i
        var logger = Logger(label: "QuoteService")
        logger.logLevel = .trace
        self.logger = logger
    }

    func getQuote(_ input: Operations.getQuote.Input) async throws -> Operations.getQuote.Output {

        // OPTIONAL
        // Check if the Authentication Middleware has been able to authenticate the user
        guard let user = AuthenticationServerMiddleware.User.current else { return .unauthorized(.init()) }

        // You can log events to the AWS Lambda logs here
        logger.trace("GetQuote for \(user) - Started")

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

        logger.trace("GetQuote - Returning")

        return .ok(.init(body: .json(price)))
    }

    func authenticationMiddleware() -> AuthenticationServerMiddleware {
        AuthenticationServerMiddleware(authenticate: { stringValue in
            // Warning: this is an overly simplified authentication strategy, checking
            // for well-known tokens.
            //
            // In your project, here you would likely call out to a library that performs
            // a cryptographic validation, or similar.
            //
            // The code is for illustrative purposes only and should not be used directly.
            switch stringValue {
            case "123":
                // A known user authenticated.
                return .init(name: "Seb")
            case "456":
                // A known user authenticated.
                return .init(name: "Nata")
            default:
                // Unknown credentials, no authenticated user.
                return nil
            }
        })
    }
}
