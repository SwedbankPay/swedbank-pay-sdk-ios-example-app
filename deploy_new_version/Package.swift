// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "deploy",
    platforms: [.macOS(.v11)],
    products: [.executable(name: "deploy", targets: ["deploy"])],
    dependencies: [
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "2.4.0")
    ],
    targets: [
        .executableTarget(
            name: "deploy",
            dependencies: ["JOSESwift"]
        )
    ]
)
