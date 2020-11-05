// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescription.md

import PackageDescription

let package = Package(
    name: "SwiftCLI",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "swiftcli",
            targets: ["swiftcli"]),
        .library(
            name: "SwiftCLIKit",
            type: .dynamic,
            targets: ["SwiftCLIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.3.1")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "9.0.0")),
    ],
    targets: [
        .target(
            name: "swiftcli",
            dependencies: ["SwiftCLIKit"]),
        .target(
            name: "SwiftCLIKit",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "SwiftCLIKitTests",
            dependencies: ["SwiftCLIKit", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
