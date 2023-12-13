//
//  RouterNodeTest.swift
//
//
//  Created by Stormacq, Sebastien on 11/12/2023.
//

import HTTPTypes
import OpenAPIRuntime

import XCTest
@testable import OpenAPILambda

final class RouterNodeTest: XCTestCase {
    func testFirstNodeIsRoot() throws {
        // given
        let node = Node()
        // when
        guard case .root = node.value else {
            XCTFail("Top level node is not root")
            return
        }
        // then
        // succeed
    }
    func testAddPathElement() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        XCTAssertNoThrow(try node.add(pathElement: pathElement))
        // then
        XCTAssert(node.children.count == 1)
        let child = node.children[pathElement]
        if case .pathElement(let element) = child?.value {
            XCTAssert(element == pathElement)
        }
        else {
            XCTFail("Not a path element")
        }
    }
    func testAddHTTPMethod() throws {
        // given
        let methodStr = "GET"
        let method = HTTPRequest.Method(methodStr)!
        let node = Node()
        // when
        XCTAssertNoThrow(try node.add(httpMethod: method))
        // then
        XCTAssert(node.children.count == 1)
        let child = node.children[methodStr]
        if case .httpMethod(let retrievedMethod) = child?.value {
            XCTAssert(retrievedMethod == method)
        }
        else {
            XCTFail("Not an HTTP method")
        }
    }
    func testAddParameter() throws {
        // given
        let parameter = "parameter"
        let node = Node()
        // when
        XCTAssertNoThrow(try node.add(parameter: "parameter"))
        // then
        XCTAssert(node.children.count == 1)
        let child = node.children[parameter]
        if case .pathParameter(let param) = child?.value {
            XCTAssert(param == parameter)
        }
        else {
            XCTFail("Not a parameter")
        }
    }
    func testAddHandler() async throws {
        // given
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }
        let node = Node()
        // when
        XCTAssertNoThrow(try node.add(handler: handler))
        // then
        XCTAssert(node.children.count == 1)
        let child = node.children["handler"]
        if case .handler(let retrievedHandler) = child?.value {
            let request = HTTPRequest(method: .init("GET")!, scheme: "https", authority: nil, path: "")
            let (response, body) = try await retrievedHandler(request, nil, ServerRequestMetadata())
            XCTAssert(response.status == .ok)
            let retrievedBody = try? await String(collecting: body ?? "", upTo: 10 * 1024 * 1024)
            XCTAssert(retrievedBody == bodyString)
        }
        else {
            XCTFail("Not a handler")
        }
    }
    func testCanNotAddNodeToHandler() {
        // given
        let bodyString = "bodyString"
        let handler: OpenAPIHandler = { a, b, c in (HTTPResponse(status: .ok), HTTPBody(bodyString)) }
        let node = Node()
        XCTAssertNoThrow(try node.add(handler: handler))
        // when
        let child = node.children["handler"]
        // should throw an error
        XCTAssertThrowsError(try child?.add(pathElement: "test"))
    }
    func testAddDuplicateNode() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        XCTAssertNoThrow(try node.add(pathElement: pathElement))
        XCTAssertNoThrow(try node.add(pathElement: pathElement))
        // then
        XCTAssert(node.children.count == 1)
    }
    func testReturnsNewNode() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        let newNode = try? node.add(pathElement: pathElement)
        XCTAssertNotNil(newNode)
        // then
        XCTAssert(node.children.count == 1)
        if case .pathElement(let element) = newNode?.value {
            XCTAssert(element == pathElement)
        }
        else {
            XCTFail("Not a path element")
        }
    }
    func testReturnsExistingChild() throws {
        // given
        let pathElement = "test"
        let node = Node()
        // when
        let _ = try? node.add(pathElement: pathElement)
        let existingNode = try? node.add(pathElement: pathElement)
        XCTAssertNotNil(existingNode)

        // then
        XCTAssert(node.children.count == 1)
        XCTAssert(existingNode?.children.count == 0)
        if case .pathElement(let element) = existingNode?.value {
            XCTAssert(element == pathElement)
        }
        else {
            XCTFail("Not a path element")
        }
    }
    func testRetrieveParamChildExist() {
        // given
        let pathElement = "element1"
        let root = Node()

        // when
        let pathNode = try? root.add(pathElement: pathElement)
        XCTAssertNotNil(pathNode)
        let _ = try? pathNode?.add(parameter: "param1")

        // then
        let paramNode = pathNode!.parameterChild()
        XCTAssertNotNil(paramNode)

    }
    func testRetrieveParamChildNOTExist() {
        // given
        let pathElement = "element1"
        let root = Node()

        // when
        let pathNode = try? root.add(pathElement: pathElement)
        XCTAssertNotNil(pathNode)
        let _ = try? pathNode?.add(pathElement: "element2")

        // then
        let paramNode = pathNode!.parameterChild()
        XCTAssertNil(paramNode)
    }

}
