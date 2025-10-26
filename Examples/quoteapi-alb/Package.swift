// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuoteServiceALB",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "QuoteServiceALB", targets: ["QuoteServiceALB"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.8.2"),
        .package(url: "https://github.com/awslabs/swift-aws-lambda-runtime.git", from: "2.0.0"),
        .package(url: "https://github.com/awslabs/swift-aws-lambda-events.git", from: "1.2.0"),
        .package(name: "swift-openapi-lambda", path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "QuoteServiceALB",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "OpenAPILambda", package: "swift-openapi-lambda"),
            ],
            path: "Sources/QuoteAPI",
            resources: [
                .copy("openapi.yaml"),
                .copy("openapi-generator-config.yaml"),
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        )
    ]
)
