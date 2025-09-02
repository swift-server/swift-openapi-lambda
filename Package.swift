// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-lambda",
    platforms: [.macOS(.v15)],
    products: [.library(name: "OpenAPILambda", targets: ["OpenAPILambda"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.8.2"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "2.0.0-beta.2"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "OpenAPILambda",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ],
            path: "Sources"
        ),
        // test targets
        .testTarget(
            name: "OpenAPILambdaTests",
            dependencies: [
                .byName(name: "OpenAPILambda")
            ]
        ),
    ]
)
