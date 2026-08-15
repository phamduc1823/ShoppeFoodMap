// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShoppeFoodMap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ShoppeFoodMap",
            targets: ["ShoppeFoodMap"]
        ),
    ],
    targets: [
        .executableTarget(
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
