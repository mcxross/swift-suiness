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
                     checksum: "7ecc10d391546ab459f63af53fecba4987c2b784491340f3c832907547a5e12b"),
        .target(
            name: "Suiness",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)
