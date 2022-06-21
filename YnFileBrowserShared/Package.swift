// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "YnFileBrowserShared",
    products: [
        .library(
            name: "YnFileBrowserShared",
            targets: ["YnFileBrowserShared"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "YnFileBrowserShared",
            dependencies: []),
        .testTarget(
            name: "YnFileBrowserSharedTests",
            dependencies: ["YnFileBrowserShared"])
    ])
