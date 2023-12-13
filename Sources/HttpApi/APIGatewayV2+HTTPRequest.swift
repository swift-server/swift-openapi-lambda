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
import AWSLambdaEvents
import HTTPTypes
import OpenAPIRuntime

extension APIGatewayV2Request {

    /// Return an `HTTPRequest.Method` for this `APIGatewayV2Request`
    public func httpRequestMethod() throws -> HTTPRequest.Method {
        guard let method = HTTPRequest.Method(rawValue: self.context.http.method.rawValue) else {
            throw LambdaOpenAPIHttpError.invalidMethod(self.context.http.method.rawValue)
        }
        return method
    }

    /// Return an `HTTPRequest` for this `APIGatewayV2Request`
    public func httpRequest() throws -> HTTPRequest {
        try HTTPRequest(
            method: self.httpRequestMethod(),
            scheme: "https",
            authority: "",
            path: self.rawPath,
            headerFields: self.headers.httpFields()
        )
    }
}

extension APIGatewayV2Response {

    /// Create a `APIGatewayV2Response` from an `HTTPResponse`
    public init(from response: HTTPResponse) {
        self = APIGatewayV2Response(
            statusCode: .init(code: UInt(response.status.code)),
            headers: .init(from: response.headerFields),
            isBase64Encoded: false,
            cookies: nil
        )
    }
}

public extension HTTPHeaders {
    /// Create an `HTTPFields` (from `HTTPTypes` library) from this APIGateway `HTTPHeader`
    func httpFields() -> HTTPFields {
        HTTPFields(self.map { key, value in HTTPField(name: .init(key)!, value: value) })
    }

    /// Create HTTPHeaders from HTTPFields
    init(from fields: HTTPFields) {
        var headers: HTTPHeaders = [:]
        fields.forEach { headers[$0.name.rawName] = $0.value }
        self = headers
    }
}
