// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Sunlight",
    products: [
        .library(
            name: "Sunlight",
            targets: ["Sunlight"]
        )
    ],
    targets: [
        .target(
            name: "Sunlight",
            path: "Sources"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["Sunlight"],
            path: "Tests",
            exclude: ["Info.plist"]
        )
    ]
)
