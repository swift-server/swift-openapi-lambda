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
import Testing

@testable import OpenAPILambda

@Suite("HTTP Headers Conversion Tests")
struct HTTPHeadersConversionTests {
    
    @Test("Multi-value headers preserved as comma-separated")
    func testMultiValueHeadersPreserved() throws {
        var httpResponse = HTTPResponse(status: .ok)
        httpResponse.headerFields.append(HTTPField(name: HTTPField.Name.setCookie, value: "session=abc123"))
        httpResponse.headerFields.append(HTTPField(name: HTTPField.Name.setCookie, value: "theme=dark"))
        
        let albResponse = ALBTargetGroupResponse(from: httpResponse)
        
        #expect(albResponse.headers?[HTTPField.Name.setCookie.rawName] == "session=abc123, theme=dark")
        #expect(albResponse.multiValueHeaders == nil)
    }
    
    @Test("HTTPHeaders to HTTPFields conversion")
    func testHTTPHeadersToHTTPFields() throws {
        let headers: HTTPHeaders = [
            "Set-Cookie": "session=abc123, theme=dark",
            "Content-Type": "application/json"
        ]
        
        let httpFields = headers.httpFields()
        
        #expect(httpFields[HTTPField.Name.setCookie] == "session=abc123, theme=dark")
        #expect(httpFields[HTTPField.Name.contentType] == "application/json")
    }
}