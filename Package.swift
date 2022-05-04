// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Attributes",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Attributes",
            targets: ["Attributes"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "git@github.com:mipalgu/XMI.git", .branch("main")),
        .package(url: "https://github.com/mipalgu/swift_helpers.git", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Attributes",
            dependencies: ["XMI", "swift_helpers"]),
        .testTarget(
            name: "AttributesTests",
            dependencies: ["Attributes"]),
    ]
)
