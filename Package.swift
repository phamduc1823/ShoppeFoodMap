// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShoppeFoodMap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ShoppeFoodMap",
            targets: ["ShoppeFoodMap"]
        ),
    ],
    targets: [
        .target(
            name: "ShoppeFoodMap",
            path: ".",
            exclude: ["Tests"],
            sources: [
                "App",
                "Core",
                "Data",
                "Services",
                "Optimization",
                "UI",
                "Features"
            ]
        ),
        .testTarget(
            name: "ShoppeFoodMapTests",
            dependencies: ["ShoppeFoodMap"],
            path: "Tests"
        ),
    ]
)
