// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealmExtensions",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RealmExtensions",
            targets: ["RealmExtensions"]),
        .library(
            name: "ComposableRealm",
            targets: ["ComposableRealm"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa.git", from: "10.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.1.4")),
    ],
    targets: [
        .target(
            name: "RealmExtensions",
            dependencies: [
                "RealmSwift",
            ]),
        .target(
            name: "ComposableRealm",
            dependencies: [
                "RealmExtensions",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"),
            ]),
        .testTarget(
            name: "RealmExtensionsTests",
            dependencies: ["RealmExtensions"]),
    ]
)
