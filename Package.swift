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
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-cocoa", from: "5.0.0"),
    ],
    targets: [
        
        .target(
            name: "RealmExtensions",
            dependencies: [
                "RealmSwift",
        ]),
        .testTarget(
            name: "RealmExtensionsTests",
            dependencies: ["RealmExtensions"]),
    ]
)
