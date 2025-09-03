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
import AWSLambdaRuntime
import AWSLambdaEvents
import OpenAPIRuntime
import HTTPTypes

/// Specialization of LambdaHandler which runs an OpenAPILambda
public struct OpenAPILambdaHandler<OALS: OpenAPILambdaService>: Sendable {

    private let router: OpenAPILambdaRouter
    private let transport: OpenAPILambdaTransport
    private let openAPIService: OALS

    /// the input type for this Lambda handler (received from the `OpenAPILambda`)
    public typealias Event = OALS.Event

    /// the output type for this Lambda handler (received from the `OpenAPILambda`)
    public typealias Output = OALS.Output

    /// Initialize `OpenAPILambdaHandler`.
    ///
    /// Create application, set it up and create `OpenAPILambda` from application and create responder
    /// - Parameters
    ///   - context: Lambda initialization context
    init() throws {
        self.router = TrieRouter()
        self.transport = OpenAPILambdaTransport(router: self.router)

        // decouple the OpenAPILambda creation from the registration of teh transport
        // this allows users to provide their own overloaded init() function to inject dependencies.
        self.openAPIService = OALS()
        try self.openAPIService.register(transport: self.transport)
    }

    /// Initialize an `OpenAPILambdaHandler` with your own `OpenAPILambda` object.
    ///
    /// Use this function when you need to inject dependencies in your OpenAPILambda
    /// - Parameters:
    ///   - lambda: The `OpenAPILambda` instance to use.
    public init(service: OALS) throws {
        self.router = TrieRouter()
        self.transport = OpenAPILambdaTransport(router: self.router)
        self.openAPIService = service
        try self.openAPIService.register(transport: self.transport)
    }

    /// The Lambda handling method.
    /// Concrete Lambda handlers implement this method to provide the Lambda functionality.
    ///
    /// - Parameters:
    ///     - event: Event of type `Event` representing the event or request.
    ///     - context: Runtime ``LambdaContext``.
    ///
    /// - Returns: A Lambda result ot type `Output`.
    public func handler(event: OALS.Event, context: LambdaContext) async throws -> OALS.Output {

        // by default returns HTTP 500
        var lambdaResponse: OpenAPILambdaResponse = (HTTPResponse(status: .internalServerError), "unknown error")

        do {
            // convert Lambda event source to OpenAPILambdaRequest
            let request = try openAPIService.request(context: context, from: event)

            // route the request to find the handlers and extract the paramaters
            let (handler, parameters) = try router.route(method: request.0.method, path: request.0.path!)

            // call the request handler (and extract the HTTPRequest and HTTPBody)
            let httpRequest = request.0
            let httpBody = HTTPBody(stringLiteral: request.1 ?? "")
            let response = try await handler(httpRequest, httpBody, ServerRequestMetadata(pathParameters: parameters))

            // transform the response to an OpenAPILambdaResponse
            let maxPayloadSize = 10 * 1024 * 1024  // APIGateway payload is 10M max
            let body: String? = try? await String(collecting: response.1 ?? "", upTo: maxPayloadSize)
            lambdaResponse = (response.0, body)

        }
        catch OpenAPILambdaRouterError.noHandlerForPath(let path) {

            // There is no hadler registered for this path. This is a programming error.
            lambdaResponse = (
                HTTPResponse(status: .internalServerError),
                "There is no OpenAPI handler registered for the path \(path)"
            )

        }
        catch OpenAPILambdaRouterError.noRouteForMethod(let method) {

            // There is no hadler registered for this path. This is a programming error.
            lambdaResponse = (HTTPResponse(status: .notFound), "There is no route registered for the method \(method)")

        }
        catch OpenAPILambdaRouterError.noRouteForPath(let path) {

            // There is no hadler registered for this path. This is a programming error.
            lambdaResponse = (HTTPResponse(status: .notFound), "There is no route registered for the path \(path)")

        }
        catch OpenAPILambdaHttpError.invalidMethod(let method) {

            // the APIGateway HTTP verb is rejected by HTTTypes HTTPRequest.Method => HTTP 500
            // this should never happen
            lambdaResponse = (
                HTTPResponse(status: .internalServerError),
                "Type mismatch between APIGatewayV2 and HTTPRequest.Method. \(method) verb is rejected by HTTPRequest.Method 🤷‍♂️"
            )

        }
        catch {
            // some other error happened
            lambdaResponse = (HTTPResponse(status: .internalServerError), "Unknown error: \(String(reflecting: error))")
        }

        // transform the OpenAPILambdaResponse to the Lambda Output
        return openAPIService.output(from: lambdaResponse)
    }
}
