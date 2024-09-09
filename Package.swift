// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrdshSDK",
    defaultLocalization:"en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "DrdshSDK",
            targets: ["DrdshSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", from: "1.2.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.0.0")
    ],
    targets: [
        .target(
            name: "DrdshSDK",
            dependencies: [
                "SwiftyJSON",
                "MBProgressHUD",
                .product(name: "IQKeyboardManagerSwift",package: "IQKeyboardManager"),
                .product(name: "SocketIO",package: "socket.io-client-swift")
            ],
            path: "Sources",
            resources: [
                .process("Resources") // Add resources folder here
            ]
            // ,swiftSettings: [
            //     .define("SOME_CONDITIONAL_FLAG")
            // ],
//             linkerSettings: [
//                 .linkedFramework("UIKit")
//             ]
        ),
        .testTarget(
            name: "DrdshSDKTests",
            dependencies: ["DrdshSDK"]
        ),
    ],
    swiftLanguageVersions: [.v5]
    // ,cLanguageStandard: .gnu11,
    // cxxLanguageStandard: .gnucxx11
)
