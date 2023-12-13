import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
import OpenAPIRuntime
import HTTPTypes

/// The errors that can be generated
public enum LambdaOpenAPIHttpError: Error {
    case invalidMethod(String)
}

/// An specialization of the `OpenAPILambda` protocol that works with Amazon API Gateway HTTP Mode, aka API Gateway v2
public protocol OpenAPILambdaHttpApi: OpenAPILambda
where
    Event == APIGatewayV2Request,
    Output == APIGatewayV2Response
{}


extension OpenAPILambdaHttpApi {
    /// Transform a Lambda input (`APIGatewayV2Request` and `LambdaContext`) to an OpenAPILambdaRequest (`HTTPRequest`, `String?`)
    public func request(context: LambdaContext, from request: Event) throws -> OpenAPILambdaRequest {
        (try request.httpRequest(), request.body)
    }

    /// Transform an OpenAPI response (`HTTPResponse`, `String?`) to a Lambda Output (`APIGatewayV2Response`)
    public func output(from response: OpenAPILambdaResponse) -> Output {
        var apiResponse = APIGatewayV2Response(from: response.0)
        apiResponse.body = response.1
        return apiResponse
    }
}
