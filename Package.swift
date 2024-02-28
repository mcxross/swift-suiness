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
        .binaryTarget(name: "RustFramework", path: "./RustFramework.xcframework"),
        .target(
            name: "Suiness",
            dependencies: [
                .target(name: "RustFramework")
            ]
        ),
    ]
)