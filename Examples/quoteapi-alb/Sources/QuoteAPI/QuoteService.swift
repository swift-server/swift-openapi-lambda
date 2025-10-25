//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift OpenAPI Lambda open source project
//
// Copyright Swift OpenAPI Lambda project authors
// Copyright (c) Amazon.com, Inc. or its affiliates.
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

@main
struct QuoteServiceALBImpl: APIProtocol, OpenAPILambdaALB {

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

        // MANDATORY (middlewares are optional)
        try self.registerHandlers(on: transport, middlewares: [loggingMiddleware])
    }

    static func main() async throws {
        let openAPIService = QuoteServiceALBImpl()
        try await openAPIService.run()
    }

    init() {
        var logger = Logger(label: "QuoteServiceALB")
        logger.logLevel = .trace
        self.logger = logger
    }

    func getQuote(_ input: Operations.getQuote.Input) async throws -> Operations.getQuote.Output {
        logger.trace("GetQuote - Started")

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
}
