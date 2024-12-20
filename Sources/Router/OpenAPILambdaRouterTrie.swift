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

/// A Trie router implementation
public struct TrieRouter: OpenAPILambdaRouter {
    private let uriPath: URIPathCollection = URIPath()

    /// add a route for a given HTTP method and path and associate a handler
    public func add(method: HTTPRequest.Method, path: String, handler: @escaping OpenAPIHandler) throws {
        try uriPath.add(method: method, path: path, handler: handler)
    }

    /// Retrieve the handler and path parameter for a given HTTP method and path
    public func route(method: HTTPRequest.Method, path: String) async throws -> (
        OpenAPIHandler, OpenAPILambdaRequestParameters
    ) { try uriPath.find(method: method, path: path) }
}

enum URIPathCollectionError: Error {
    case canNotAddChildToHandlerNode
    case canNotHaveMultipleParamChilds
}

protocol URIPathCollection {
    func root() -> Node
    func add(method: HTTPRequest.Method, path: String, handler: @escaping OpenAPIHandler) throws
    func find(method: HTTPRequest.Method, path: String) throws -> (OpenAPIHandler, OpenAPILambdaRequestParameters)
}

/// A Trie graph representation of an URI path + its handler
/// see https://en.wikipedia.org/wiki/Trie
///
///  Example :
///  an URI of GET /stocks/{symbol} will generate a tree `root -> GET -> stocks -> symbol`
struct URIPath: URIPathCollection {
    private var _root = Node()

    func root() -> Node { self._root }

    /// Add a method + path to the graph
    /// This methods decompose the path into components and create nodes as required.
    /// - Parameters:
    ///     - method: the HTTP method to use as first node
    ///     - path: the full path as received from OpenAPI registration (including parameters encoded as {param name}
    ///     - handler: the OpenAPI handler to invoke for such path
    func add(method: HTTPRequest.Method, path: String, handler: @escaping OpenAPIHandler) throws {

        // add or retrieve the HTTP method node
        var node = try root().add(httpMethod: method)

        // add each path element as child nodes
        let pathComponents = path.split(separator: "/")
        for component in pathComponents {
            if component.hasPrefix("{") && component.hasSuffix("}") {
                var comp = component
                comp.removeFirst()
                comp.removeLast()
                node = try node.add(parameter: String(comp))
            }
            else {
                node = try node.add(pathElement: String(component))
            }
        }

        // finally add the handler
        _ = try node.add(handler: handler)
    }

    /// Navigate the tree to find the handler
    /// Collect parameter name and value on the way
    /// - Parameters:
    ///     - method : the HTTP method for this path
    ///     - path : the path as received by the API Gateway (with parameter values and not names)
    /// - Returns:
    ///     - the OpenAPIHandler for this path
    ///     - the OpenAI ServerRequestMetadata (a [String:String] with parameter names and their values
    /// - Throws:
    ///     - OpenAPILambdaRouterError.noRouteForPath when there is no handler in the graph for the given combination of HTTP method and path
    ///     - OpenAPILambdaRouterError.noRouteForMethod when there is no handler for that HTTP method
    ///     - OpenAPILambdaRouterError.noHandlerForPath when there is no handler as leaf node of the tree. This is a programming error and should not happen
    func find(method: HTTPRequest.Method, path: String) throws -> (OpenAPIHandler, OpenAPILambdaRequestParameters) {
        var parameters: OpenAPILambdaRequestParameters = [:]
        let root: Node = root()

        // first node is the HTTP Method
        guard let nodeHTTP = root.children[method.rawValue] else {
            throw OpenAPILambdaRouterError.noRouteForMethod(method)
        }

        // search for each path component.  If a component is not found, it might be a parameter
        // stop at the start of the query string
        let pathComponents = path.prefix(while: { $0 != "?" }).split(separator: "/")
        var currentNode = nodeHTTP
        for component in pathComponents {
            if let child = currentNode.child(with: component) {
                // found a node with path element, continue to explore
                currentNode = child
            }
            else {
                // no path element for this component, maybe this component is a parameter value
                // let's see if we have a child param node
                if let child = currentNode.parameterChild() {
                    let paramName = child.value.asString!

                    //TODO: do not collect param when another child is a path with matching name ?
                    // /stock/{symbol}
                    // /stock/date
                    // verify if this is authorized by OpenAPI spec

                    // collect the param value
                    parameters[paramName] = component
                    // continue progress
                    currentNode = child
                }
                else {
                    throw OpenAPILambdaRouterError.noRouteForPath(path)
                }
            }
        }

        //at this stage, current node must have a handler child
        guard let handlerNode = currentNode.handlerChild() else {
            throw OpenAPILambdaRouterError.noHandlerForPath(path)
        }

        // did we found an handler ?
        guard let handler = handlerNode.value.handler else { throw OpenAPILambdaRouterError.noHandlerForPath(path) }
        return (handler, parameters)
    }

    //    /// Perform a deep search to find the first node with the matching value
    //    func findFirst(from startingNode: Node, name: String) -> Node? {
    //
    //        // check if the node we're looking for is this one
    //        // it can be a parameter, a path element, or an http method
    //        switch startingNode.value {
    //        case .pathParameter(let param): if param == name { return startingNode }
    //        case .pathElement(let element): if element == name { return startingNode }
    //        case .httpMethod(let method): if method.rawValue == name { return startingNode }
    //        default: break
    //        }
    //
    //        // otherwise, check child nodes
    //        for key in startingNode.children.keys {
    //
    //            // if the search finds a non nil value, we found it
    //            if let result = findFirst(from: startingNode.children[key]!, name: name) {
    //                return result
    //            }
    //            // otherwise continue with the next key
    //        }
    //
    //        // otherwise we did not find it
    //        return nil
    //    }

}
