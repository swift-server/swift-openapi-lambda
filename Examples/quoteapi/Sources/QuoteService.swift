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

@main
struct QuoteServiceImpl: APIProtocol, OpenAPILambdaHttpApi {

    init(transport: OpenAPILambdaTransport) throws {
        try self.registerHandlers(on: transport)
    }

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
