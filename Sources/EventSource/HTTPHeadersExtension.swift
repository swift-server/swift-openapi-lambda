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
import AWSLambdaEvents
import HTTPTypes

public extension HTTPHeaders {
    /// Create an `HTTPFields` (from `HTTPTypes` library) from this APIGateway `HTTPHeader`
    func httpFields() -> HTTPFields {
        HTTPFields(self.map { key, value in HTTPField(name: .init(key)!, value: value) })
    }

    /// Create HTTPHeaders from HTTPFields
    init(from fields: HTTPFields) {
        var headers: HTTPHeaders = [:]
        for field in fields {
            let name = field.name.rawName
            if let existing = headers[name] {
                headers[name] = "\(existing), \(field.value)"
            }
            else {
                headers[name] = field.value
            }
        }
        self = headers
    }
}
