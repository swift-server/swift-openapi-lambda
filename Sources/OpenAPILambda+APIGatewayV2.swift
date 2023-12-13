import AWSLambdaRuntime
import AWSLambdaEvents
import HTTPTypes

//temp
import Foundation

extension OpenAPILambda where Event == APIGatewayV2Request {
    /// Transform a Lambda input (`APIGatewayV2Request` and `LambdaContext`) to an OpenAPILambdaRequest (`HTTPRequest`, `String?`)
    public func request(context: LambdaContext, from request: Event) throws -> OpenAPILambdaRequest {
        (try request.httpRequest(), request.body)
    }
}

extension OpenAPILambda where Output == APIGatewayV2Response {
    /// Transform an OpenAPI response (`HTTPResponse`, `String?`) to a Lambda Output (`APIGatewayV2Response`)
    public func output(from response: OpenAPILambdaResponse) -> Output {
        var apiResponse = APIGatewayV2Response(from: response.0)
        apiResponse.body = response.1
        return apiResponse
    }
}
