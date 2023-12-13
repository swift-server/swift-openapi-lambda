// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-openapi-lambda",
    platforms: [
        .macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6),
    ],
    products: [.library(name: "OpenAPILambda", targets: ["OpenAPILambda"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", branch: "1.0.0-alpha.1"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
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
        .testTarget(name: "OpenAPILambdaTests", dependencies: [.byName(name: "OpenAPILambda")]),
    ]
)
