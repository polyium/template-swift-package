// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "example",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(
            name: "example",
            targets: ["Example"]
        ),
    ],
    dependencies: [
        // MARK: - Core Runtime Dependencies
        .package(url: "https://github.com/apple/swift-log.git", branch: "main"),
        
        .package(name: "swift-package-template", path: "../.."),
    ],
    targets: [
        // MARK: - Executable

        .executableTarget(
            name: "Example",
            dependencies: [
                .product(name: "Library", package: "swift-package-template"),
                .product(name: "Logging", package: "swift-log")
            ],
        ),
    ]
)

// MARK: - Allow consumers to specify which targets they want to import

for target in package.targets {
    switch target.type {
    case .regular, .test, .executable:
        var settings = target.swiftSettings ?? []
        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        target.swiftSettings = settings
    case .macro, .plugin, .system, .binary:
        ()  // not applicable
    @unknown default:
        ()  // unknown, no-op
    }
}
