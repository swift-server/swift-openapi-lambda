import AWSLambdaEvents
import Foundation
import HTTPTypes

/// Errors returned by the router
public enum LambdaOpenAPIRouterError: Error {
    case noRouteForPath(String)
    case noHandlerForPath(String)
    case noRouteForMethod(HTTPRequest.Method)
}

/// A router API
public protocol LambdaOpenAPIRouter {
    /// add a route for a given HTTP method and path and associate a handler
    func add(method: HTTPRequest.Method, path: String, handler: @escaping OpenAPIHandler) throws

    /// Retrieve the handler and path parameter for a given HTTP method and path
    func route(method: HTTPRequest.Method, path: String) async throws -> (
        OpenAPIHandler, OpenAPILambdaRequestParameters
    )
}
