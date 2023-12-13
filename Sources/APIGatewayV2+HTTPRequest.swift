import Foundation
import AWSLambdaEvents
import HTTPTypes
import OpenAPIRuntime

extension HTTPHeaders {
    func httpFields() -> HTTPFields {
        HTTPFields(self.map { key, value in HTTPField(name: .init(key)!, value: value) })
    }

    /// Create HTTPHeaders from HTTPFields
    public init(from fields: HTTPFields) {
        var headers: HTTPHeaders = [:]
        fields.forEach { headers[$0.name.rawName] = $0.value }
        self = headers
    }
}

extension APIGatewayV2Request {

    /// Return an `HTTPRequest.Method` for this `APIGatewayV2Request`
    public func httpRequestMethod() throws -> HTTPRequest.Method {
        guard let method = HTTPRequest.Method(rawValue: self.context.http.method.rawValue) else {
            throw LambdaOpenAPIRouterError.invalidMethod(self.context.http.method.rawValue)
        }
        return method
    }

    /// Return an `HTTPRequest` for this `APIGatewayV2Request`
    public func httpRequest() throws -> HTTPRequest {
        try HTTPRequest(
            method: self.httpRequestMethod(),
            scheme: "https",
            authority: "",
            path: self.rawPath,
            headerFields: self.headers.httpFields()
        )
    }
}

extension APIGatewayV2Response {

    /// Create a `APIGatewayV2Response` from an `HTTPResponse`
    public init(from response: HTTPResponse) {
        self = APIGatewayV2Response(
            statusCode: .init(code: UInt(response.status.code)),
            headers: .init(from: response.headerFields),
            isBase64Encoded: false,
            cookies: nil
        )
    }
}
