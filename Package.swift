// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-lambda",
    platforms: [.macOS(.v12)],
    products: [.library(name: "OpenAPILambda", targets: ["OpenAPILambda"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha.3"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "OpenAPILambda",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ],
            path: "Sources",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")]
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
