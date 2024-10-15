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
import HTTPTypes
import OpenAPIRuntime

@testable import OpenAPILambda

// only run unit tests on Swift 6.x
#if swift(>=6.0)
import Testing

struct RouterNodeTests {
    @Test("First node is root")
    func testFirstNodeIsRoot() throws {
        // given
        let node = Node()
        // when
        guard case .root = node.value else {
            Issue.record("Top level node is not root")
            return
        }
        // then
        // succeed
    }

    @Test("Add path element")
    func testAddPathElement() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        #expect(throws: Never.self) { try node.add(pathElement: pathElement) }
        // then
        #expect(node.children.count == 1)
        let child = node.children[pathElement]
        if case .pathElement(let element) = child?.value {
            #expect(element == pathElement)
        }
        else {
            Issue.record("Not a path element")
        }
    }

    @Test("Add HTTP method")
    func testAddHTTPMethod() throws {
        // given
        let methodStr = "GET"
        let method = HTTPRequest.Method(methodStr)!
        let node = Node()
        // when
        #expect(throws: Never.self) { try node.add(httpMethod: method) }
        // then
        #expect(node.children.count == 1)
        let child = node.children[methodStr]
        if case .httpMethod(let retrievedMethod) = child?.value {
            #expect(retrievedMethod == method)
        }
        else {
            Issue.record("Not an HTTP method")
        }
    }

    @Test("Add parameter")
    func testAddParameter() throws {
        // given
        let parameter = "parameter"
        let node = Node()
        // when
        #expect(throws: Never.self) { try node.add(parameter: "parameter") }
        // then
        #expect(node.children.count == 1)
        let child = node.children[parameter]
        if case .pathParameter(let param) = child?.value {
            #expect(param == parameter)
        }
        else {
            Issue.record("Not a parameter")
        }
    }

    @Test("Add handler")
    func testAddHandler() async throws {
        // given
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }
        let node = Node()
        // when
        #expect(throws: Never.self) { try node.add(handler: handler) }
        // then
        #expect(node.children.count == 1)
        let child = node.children["handler"]
        if case .handler(let retrievedHandler) = child?.value {
            let request = HTTPRequest(method: .init("GET")!, scheme: "https", authority: nil, path: "")
            let (response, body) = try await retrievedHandler(request, nil, ServerRequestMetadata())
            #expect(response.status == .ok)
            let retrievedBody = try? await String(collecting: body ?? "", upTo: 10 * 1024 * 1024)
            #expect(retrievedBody == bodyString)
        }
        else {
            Issue.record("Not a handler")
        }
    }

    @Test("Cannot add node to handler")
    func testCanNotAddNodeToHandler() {
        // given
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }
        let node = Node()
        let _ = try? node.add(handler: handler)
        // when
        let child = node.children["handler"]
        // should throw an error
        #expect(throws: URIPathCollectionError.self) {
            try child?.add(pathElement: "test")
        }
    }

    @Test("Add duplicate node")
    func testAddDuplicateNode() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        #expect(throws: Never.self) { try node.add(pathElement: pathElement) }
        #expect(throws: Never.self) { try node.add(pathElement: pathElement) }
        // then
        #expect(node.children.count == 1)
    }

    @Test("Returns new node")
    func testReturnsNewNode() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        let newNode = try? node.add(pathElement: pathElement)
        #expect(newNode != nil)
        // then
        #expect(node.children.count == 1)
        if case .pathElement(let element) = newNode?.value {
            #expect(element == pathElement)
        }
        else {
            Issue.record("Not a path element")
        }
    }

    @Test("Returns existing child")
    func testReturnsExistingChild() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        let _ = try? node.add(pathElement: pathElement)
        let existingNode = try? node.add(pathElement: pathElement)
        #expect(existingNode != nil)

        // then
        #expect(node.children.count == 1)
        #expect(existingNode?.children.count == 0)
        if case .pathElement(let element) = existingNode?.value {
            #expect(element == pathElement)
        }
        else {
            Issue.record("Not a path element")
        }
    }

    @Test("Retrieve param child exists")
    func testRetrieveParamChildExist() {
        // given
        let pathElement = "element1"
        let root = Node()

        // when
        let pathNode = try? root.add(pathElement: pathElement)
        #expect(pathNode != nil)
        let _ = try? pathNode?.add(parameter: "param1")

        // then
        let paramNode = pathNode!.parameterChild()
        #expect(paramNode != nil)
    }

    @Test("Retrieve param child does not exist")
    func testRetrieveParamChildNOTExist() {
        // given
        let pathElement = "element1"
        let root = Node()

        // when
        let pathNode = try? root.add(pathElement: pathElement)
        #expect(pathNode != nil)
        let _ = try? pathNode?.add(pathElement: "element2")

        // then
        let paramNode = pathNode!.parameterChild()
        #expect(paramNode == nil)
    }

}
#endif
