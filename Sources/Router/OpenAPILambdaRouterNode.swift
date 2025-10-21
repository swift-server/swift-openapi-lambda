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
import HTTPTypes

/// A node in the graph
/// A node has a value and a list of children nodes
/// A node value can be
/// - `root` (only one, at the top of the tree),
/// - an HTTP method (represented as a HTTPRequest.Method)
/// - a path element (represented as a `String`),
/// - a path parameter (represented as a `String`)
/// - a handler, only for leaf nodes (represented as `OpenAPIHandler`)
final class Node {
    let value: NodeValue
    var children: [String: Node] = [:]

    /// Default init, create a root node
    init() { value = .root }

    /// Creates a node for an HTTP method
    init(httpMethod: HTTPRequest.Method) { value = .httpMethod(httpMethod) }

    /// Creates a node for a path element
    init(pathElement: String) { value = .pathElement(pathElement) }

    /// Creates a node for a path parameter
    init(parameterName: String) { value = .pathParameter(parameterName) }

    /// Creates a node for an OpenAPI handler
    init(handler: @escaping OpenAPIHandler) { value = .handler(handler) }

    /// Creates a node for an existing node value
    private init(value: NodeValue) { self.value = value }

    /// Convenience method to add a child node of type HttpRequest.Method to this node
    /// - Parameter:
    ///   - httpMethod: an HTTP Method
    /// - Returns:
    ///   - the node that has been created
    /// - Throws:
    ///   - URIPathCollectionError.canNotAddChildToHandlerNode when trying to add a child to leaf node of type `.handler`
    ///   - URIPathCollectionError.canNotHaveMultipleParamChilds when trying to add multiple child node of type `.parameter`
    func add(httpMethod: HTTPRequest.Method) throws -> Node { try add(child: NodeValue.httpMethod(httpMethod)) }

    /// Convenience method to add a child node of type path element to this node
    /// - Parameter:
    ///   - pathElement: the name of a path element. A path element is a `String` usually found between `/` characters in the URI
    /// - Returns:
    ///   - the node that has been created
    /// - Throws:
    ///   - URIPathCollectionError.canNotAddChildToHandlerNode when trying to add a child to leaf node of type `.handler`
    ///   - URIPathCollectionError.canNotHaveMultipleParamChilds when trying to add multiple child node of type `.parameter`
    func add(pathElement: String) throws -> Node { try add(child: NodeValue.pathElement(pathElement)) }

    /// Convenience method to add a child node of type path parameter  to this node
    /// - Parameter:
    ///     - pathParameter: the name of a path parameter. A path parameter is a `{name}` usually found between `/` characters in the URI
    /// - Returns:
    ///   - the node that has been created
    /// - Throws:
    ///   - URIPathCollectionError.canNotAddChildToHandlerNode when trying to add a child to leaf node of type `.handler`
    ///   - URIPathCollectionError.canNotHaveMultipleParamChilds when trying to add multiple child node of type `.parameter`
    func add(parameter: String) throws -> Node { try add(child: NodeValue.pathParameter(parameter)) }

    /// Convenience method to add a child node of type handler to this node
    /// - Parameter:
    ///     - handler: a function handler. A handler MUST be a leaf node (it has no children) and is of type `OpenAPIHandler`
    /// - Returns:
    ///   - the node that has been created
    /// - Throws:
    ///   - URIPathCollectionError.canNotAddChildToHandlerNode when trying to add a child to leaf node of type `.handler`
    ///   - URIPathCollectionError.canNotHaveMultipleParamChilds when trying to add multiple child node of type `.parameter`
    func add(handler: @escaping OpenAPIHandler) throws -> Node { try add(child: NodeValue.handler(handler)) }

    /// Convenience method to add a child node to this node
    /// - Parameter:
    ///   - child: A NodeValue to add as child node to this node
    /// - Returns:
    ///   - the node that has been created
    /// - Throws:
    ///   - URIPathCollectionError.canNotAddChildToHandlerNode when trying to add a child to leaf node of type `.handler`
    ///   - URIPathCollectionError.canNotHaveMultipleParamChilds when trying to add multiple child node of type `.parameter`
    private func add(child: NodeValue) throws -> Node {
        let key = key(for: child)
        // if the child node already exist, just ignore
        guard children[key] == nil else { return children[key]! }
        // Reject the add() operation when this node is an handler.  Handler are leaf nodes.
        if self.value.isHandler { throw URIPathCollectionError.canNotAddChildToHandlerNode }

        // Reject the add() operation when there is already a param Node as child
        // OpenAI specification -> https://swagger.io/specification/
        // The following paths are considered identical and invalid:
        // /pets/{petId}
        // /pets/{name}

        // when the child we try to add is a param
        if child.isPathParameter {
            // and there is already a param child
            if hasParamChild() { throw URIPathCollectionError.canNotHaveMultipleParamChilds }
        }
        let newNode = Node(value: child)
        children[key] = newNode
        return newNode
    }

    /// Returns the child with the given value, nil if no child with such name exist
    /// - Parameter:
    ///     - name: the value of the child node
    func child(with name: String) -> Node? { self.children[name] }

    /// Returns the child with the given value, nil if no child with such name exist
    /// - Parameter:
    ///     - name: the value of the child node
    func child(with name: Substring) -> Node? { self.children[String(name)] }

    /// Returns the parameter child for this node if there is one, nil otherwise
    func parameterChild() -> Node? {
        let paramNodes = self.children.filter { key, value in self.children[key]!.value.isPathParameter }
        precondition(paramNodes.count <= 1)
        return paramNodes.count == 1 ? paramNodes.first!.value : nil
    }

    /// Returns true when one of the child is a param node, false otherwise
    private func hasParamChild() -> Bool {
        if self.children.isEmpty { return false }
        return self.children.keys.allSatisfy { key in self.children[key]!.value.isPathParameter }
    }

    /// Returns the handler child for this node if there is one, nil otherwise
    func handlerChild() -> Node? {
        let handlerNodes = self.children.filter { key, value in self.children[key]!.value.isHandler }
        precondition(handlerNodes.count <= 1)
        return handlerNodes.count == 1 ? handlerNodes.first!.value : nil
    }

    /// Get a `Hashable` key for a node value
    /// There can be only one root node and one child handler (as a leaf of the tree), so it is OK to hardcode these keys
    private func key(for value: NodeValue) -> String {
        switch value {
        case .root: "root"
        case .httpMethod(let method): method.rawValue
        case .pathElement(let element): element
        case .pathParameter(let name): name
        case .handler: "handler"
        }
    }

    /// A value for a node.
    /// Possible values are:
    /// - `root` (only one, at the top of the tree),
    /// - an HTTP method (represented as a HTTPRequest.Method)
    /// - a path element (represented as a `String`),
    /// - a path parameter (represented as a `String`)
    /// - a handler, only for leaf nodes (represented as `OpenAPIHandler`)
    enum NodeValue {
        case root
        case httpMethod(HTTPRequest.Method)
        case pathElement(String)
        case pathParameter(String)
        case handler(OpenAPIHandler)

        var isPathParameter: Bool {
            switch self {
            case .pathParameter(_): return true
            default: return false
            }
        }

        var isHandler: Bool {
            switch self {
            case .handler(_): return true
            default: return false
            }
        }

        var handler: OpenAPIHandler? {
            switch self {
            case .handler(let handler): return handler
            default: return nil
            }
        }

        var asString: String? {
            switch self {
            case .root: return nil
            case .httpMethod(let method): return method.rawValue
            case .pathElement(let element): return element
            case .pathParameter(let param): return param
            case .handler(_): return nil
            }
        }
    }
}
