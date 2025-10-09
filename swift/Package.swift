// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "WebWords",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0")
    ],
    targets: [
        .executableTarget(
            name: "WebWords",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]
        )
    ]
)