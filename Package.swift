// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift Package: Suiness

import PackageDescription;

let package = Package(
    name: "Suiness",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Suiness",
            targets: ["Suiness"]
        )
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(name: "RustFramework", url: "https://github.com/mcxross/swift-suiness/releases/download/v0.1.2-beta/RustFramework.xcframework-v0.1.2-beta.zip",
                     checksum: "6942907f177a1fd313fa48f887828a5eca6a087e54e07a71e8e8168a46abac94"),
        .target(
            name: "Suiness",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)
