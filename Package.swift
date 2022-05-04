// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if arch(wasm32)
let ui: [Package.Dependency] = [.package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.5.1")]
let products: [Target.Dependency] = [.product(name: "TokamakShim", package: "Tokamak")]
#else
let ui: [Package.Dependency] = []
let products: [Target.Dependency] = []
#endif

let package = Package(
    name: "AttributeViews",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AttributeViews",
            targets: ["AttributeViews"]),
    ],
    dependencies: ui + [
        .package(name: "Attributes", url: "git@github.com:mipalgu/Attributes.git", .branch("main")),
        .package(name: "GUUI", url: "git@github.com:mipalgu/GUUI.git", .branch("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AttributeViews",
            dependencies: products + ["Attributes", "GUUI"]),
        .target(name: "AttributeViewsTests", dependencies: products + ["AttributeViews", "Attributes", "GUUI"])
    ]
)
