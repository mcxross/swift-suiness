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
        .binaryTarget(name: "RustFramework", url: "https://github.com/mcxross/swift-suiness/releases/download/v0.1.3-beta/RustFramework.xcframework-v0.1.3-beta.zip",
                     checksum: "a962f412129be4956170b684840248aa52ae8c168515d63acbd53162754633c8"),
        .target(
            name: "Suiness",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)
