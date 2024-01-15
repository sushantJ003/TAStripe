// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TAStripe",
    platforms: [
        .iOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TAStripe",
            targets: ["TAStripe"]),
    ],
    dependencies: [
            // Dependencies declare other packages that this package depends on.
        
        .package(url: "https://github.com/stripe/stripe-ios-spm", from: "23.20.0"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", .upToNextMajor(from: "2.3.1")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TAStripe", dependencies: [
                .product(name: "Stripe", package: "stripe-ios-spm"),
                .product(name: "ObjectMapper", package: "ObjectMapper"),
                .product(name: "SVProgressHUD", package: "SVProgressHUD"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")],
            resources: [.copy("Group")]),
        .testTarget(
            name: "TAStripeTests",
            dependencies: ["TAStripe"]),
    ]
)
