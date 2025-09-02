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
import Testing

@testable import OpenAPILambda

struct RouterGraphTests {
    @Test("Path with no parameters")
    func testPathNoParams() async throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph: URIPathCollection = URIPath()
        let path = "/element1/element2"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        // when
        #expect(throws: Never.self) { try graph.add(method: method, path: path, handler: handler) }

        // then
        var node: Node? = graph.root()

        // first node is GET
        node = node?.children[strMethod]
        if case .httpMethod(let retrievedMethod) = node?.value {
            #expect(retrievedMethod == method)
        }
        else {
            Issue.record("Not an HTTP method")
        }
        // all other nodes but last are path elements
        node = node?.children["element1"]
        #expect(node != nil)
        #expect(node?.children.count == 1)
        if case .pathElement(let element) = node?.value { #expect(element == "element1") }
        node = node?.children["element2"]
        #expect(node != nil)
        #expect(node?.children.count == 1)
        if case .pathElement(let element) = node?.value { #expect(element == "element2") }

        // last node is a handler
        node = node?.children["handler"]
        if case .handler(let retrievedHandler) = node?.value {
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
    @Test("Path with one parameter")
    func testPathOneParams() async throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph: URIPathCollection = URIPath()
        let path = "/element1/{param1}"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        // when
        #expect(throws: Never.self) { try graph.add(method: method, path: path, handler: handler) }
        // then
        var node: Node? = graph.root()

        // first node is GET
        node = node?.children[strMethod]
        if case .httpMethod(let retrievedMethod) = node?.value {
            #expect(retrievedMethod == method)
        }
        else {
            Issue.record("Not an HTTP method")
        }
        // next node  is a  path elements
        node = node?.children["element1"]
        #expect(node != nil)
        #expect(node?.children.count == 1)
        if case .pathElement(let element) = node?.value { #expect(element == "element1") }
        node = node?.children["param1"]
        #expect(node != nil)
        #expect(node?.children.count == 1)
        if case .pathParameter(let param) = node?.value { #expect(param == "param1") }

        // last node is a handler
        node = node?.children["handler"]
        if case .handler(let retrievedHandler) = node?.value {
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
    @Test("Two GET paths")
    func testTwoGETPaths() async throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph: URIPathCollection = URIPath()
        let path1 = "/element1"
        let path2 = "/element2"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        // when
        #expect(throws: Never.self) { try graph.add(method: method, path: path1, handler: handler) }
        #expect(throws: Never.self) { try graph.add(method: method, path: path2, handler: handler) }

        // then
        var node: Node? = graph.root()

        // first node is GET
        node = node?.children[strMethod]
        if case .httpMethod(let retrievedMethod) = node?.value {
            #expect(retrievedMethod == method)
        }
        else {
            Issue.record("Not an HTTP method")
        }
        // next nodes are a path elements
        let node1 = node?.children["element1"]
        #expect(node1 != nil)
        #expect(node1?.children.count == 1)
        if case .pathElement(let element) = node1?.value { #expect(element == "element1") }

        let node2 = node?.children["element2"]
        #expect(node2 != nil)
        #expect(node2?.children.count == 1)
        if case .pathElement(let element) = node2?.value { #expect(element == "element2") }

        // last node is a handler
        let node3 = node1?.children["handler"]
        #expect(node3 != nil)
        if case .handler(let retrievedHandler) = node3?.value {
            let request = HTTPRequest(method: .init("GET")!, scheme: "https", authority: nil, path: "")
            let (response, body) = try await retrievedHandler(request, nil, ServerRequestMetadata())
            #expect(response.status == .ok)
            let retrievedBody = try? await String(collecting: body ?? "", upTo: 10 * 1024 * 1024)
            #expect(retrievedBody == bodyString)
        }
        else {
            Issue.record("Not a handler")
        }

        let node4 = node2?.children["handler"]
        try #require(node4 != nil)
        if case .handler(let retrievedHandler) = node4?.value {
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
    @Test("Multiple HTTP methods")
    func testMultipleHTTPMethods() throws {
        // given
        let strMethod1 = "GET"
        let strMethod2 = "POST"
        let method1 = HTTPRequest.Method(strMethod1)!
        let method2 = HTTPRequest.Method(strMethod2)!
        let graph: URIPathCollection = URIPath()
        let path = "/element1/element2"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        // when
        #expect(throws: Never.self) { try graph.add(method: method1, path: path, handler: handler) }
        #expect(throws: Never.self) { try graph.add(method: method2, path: path, handler: handler) }

        // then
        var node: Node? = graph.root()

        // first node is GET
        let node1 = node?.children[strMethod1]
        if case .httpMethod(let retrievedMethod) = node1?.value {
            #expect(retrievedMethod == method1)
        }
        else {
            Issue.record("Not an HTTP method")
        }
        // but there is also a POST node at level 1
        let node2 = node?.children[strMethod2]
        if case .httpMethod(let retrievedMethod) = node2?.value {
            #expect(retrievedMethod == method2)
        }
        else {
            Issue.record("Not an HTTP method")
        }

        // all other nodes but last are path elements
        node = node1?.children["element1"]
        #expect(node1 != nil)
        #expect(node1?.children.count == 1)
        if case .pathElement(let element) = node1?.value { #expect(element == "element1") }
        node = node2?.children["element2"]
        #expect(node2 != nil)
        #expect(node2?.children.count == 1)
        if case .pathElement(let element) = node2?.value { #expect(element == "element2") }
    }
    //    func testDeepSearch() {
    //        // given
    //        let strMethod = "GET"
    //        let method = HTTPRequest.Method(strMethod)!
    //        let graph = prepareGraph(for: method)
    //
    //        let root: Node? = graph.root()
    //        XCTAssertNotNil(root)
    //
    //        // when
    //        // search for GET node
    //        var node = graph.findFirst(from: root!, name: "GET")
    //        // then
    //        if case .httpMethod(let retrievedMethod) = node?.value {
    //            XCTAssert(retrievedMethod == method)
    //        } else {
    //            XCTFail("Not an HTTP method")
    //        }
    //
    //        // when
    //        // search for element1 node
    //        node = graph.findFirst(from: root!, name: "element1")
    //        // then
    //        XCTAssertNotNil(node)
    //        if case .pathElement(let element) = node?.value {
    //            XCTAssert(element == "element1")
    //        } else {
    //            XCTFail("Not an path element")
    //        }
    //
    //        // when
    //        // search for element2 node
    //        node = graph.findFirst(from: root!, name: "element2")
    //        // then
    //        XCTAssertNotNil(node)
    //        if case .pathElement(let element) = node?.value {
    //            XCTAssert(element == "element2")
    //        } else {
    //            XCTFail("Not an path element")
    //        }
    //
    //        // when
    //        // search for element3 node
    //        node = graph.findFirst(from: root!, name: "element3")
    //        // then
    //        XCTAssertNotNil(node)
    //        if case .pathElement(let element) = node?.value {
    //            XCTAssert(element == "element3")
    //        } else {
    //            XCTFail("Not an path element")
    //        }
    //    }

    @Test("No method path")
    func testNoMethodPath() {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraph(for: method)

        // when
        // then
        let noExistingMethod = HTTPRequest.Method("POST")!
        // #expect(throws: OpenAPILambdaRouterError.noRouteForMethod(noExistingMethod).self) {
        #expect(throws: OpenAPILambdaRouterError.self) {
            try graph.find(method: noExistingMethod, path: "/dummy")
        }
    }

    @Test("No two param children")
    func testNoTwoParamChilds() {
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph: URIPathCollection = URIPath()
        let path1 = "/element1/{param1}"
        let path2 = "/element1/{param2}"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        // when
        #expect(throws: Never.self) { try graph.add(method: method, path: path1, handler: handler) }

        // then
        #expect(throws: URIPathCollectionError.self) {
            try graph.add(method: method, path: path2, handler: handler)
        }
    }

    @Test("Find handler 1")
    func testFindHandler1() throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)
        let pathToTest = "/element1/element2"

        //when
        #expect(throws: Never.self) { try graph.find(method: method, path: pathToTest) }
        let (_, metadata) = try graph.find(method: method, path: pathToTest)
        #expect(metadata.count == 0)
    }

    @Test(
        "Find handler 2",
        arguments: [
            "/element3/value1/element4",
            "/element3/value2/element4",
            "/element3/value1/element4?param1=value1",
        ]
    )
    func testFindHandler2(
        pathToTest: String
    ) throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)

        //when
        #expect(throws: Never.self) {
            let (_, metadata) = try graph.find(method: method, path: pathToTest)

            // then (we can not test if the query string param have been decoded, that's the job of the openapi runtime.)
            #expect(metadata.count == 1)
        }

    }

    @Test("Find handler 3")
    func testFindHandler3() throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)
        let pathToTest = "/element5/value1"

        //when
        #expect(throws: Never.self) { try graph.find(method: method, path: pathToTest) }
        let (_, metadata) = try graph.find(method: method, path: pathToTest)
        #expect(metadata.count == 1)
    }

    @Test("Find handler error 1")
    func testFindHandlerError1() throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)
        let pathToTest = "/element6/value1"

        //when
        #expect(throws: OpenAPILambdaRouterError.self) {
            try graph.find(method: method, path: pathToTest)
        }
    }

    @Test("Find handler error 2")
    func testFindHandlerError2() throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)
        let pathToTest = "/element6"

        //when
        #expect(throws: OpenAPILambdaRouterError.self) {
            try graph.find(method: method, path: pathToTest)
        }
    }

    @Test("Find handler error no HTTP method")
    func testFindHandlerErrorNoHttpMethod() throws {
        // given
        let strMethod = "GET"
        let method = HTTPRequest.Method(strMethod)!
        let graph = prepareGraphForFind(for: method)
        let pathToTest = "/element1/element2"

        //when
        #expect(throws: OpenAPILambdaRouterError.self) {
            try graph.find(method: HTTPRequest.Method(rawValue: "POST")!, path: pathToTest)
        }
    }

    private func prepareGraph(for method: HTTPRequest.Method) -> URIPath {
        let graph = URIPath()
        let path1 = "/element1/element2"
        let path2 = "/element1/element3"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        try! graph.add(method: method, path: path1, handler: handler)
        try! graph.add(method: method, path: path2, handler: handler)
        return graph
    }

    private func prepareGraphForFind(for method: HTTPRequest.Method) -> URIPath {
        let graph = URIPath()
        let path1 = "/element1/element2"
        let path2 = "/element3/{param1}/element4"
        let path3 = "/element5/{param2}"
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }

        try! graph.add(method: method, path: path1, handler: handler)
        try! graph.add(method: method, path: path2, handler: handler)
        try! graph.add(method: method, path: path3, handler: handler)

        return graph
    }

}
