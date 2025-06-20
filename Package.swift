// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Used only for environment variables, does not make its way into the product code.
import class Foundation.ProcessInfo

/// Development specific  settings and toggles.
enum Development {
    /// Enable strict mode in development mode.
    /// - Requires explicit sendable returns.
    /// - Will trigger warnings as errors; without `-warnings-as-errors`, `-require-explicit-sendable` becomes non-deterministic in IDE-based development.
    case strict

    case lax

    static var Default: Development {
        .lax
    }
}

let mode: Development = .strict

/// strict concurrency settings for swift.
let settings: [SwiftSetting] = {
    var configurations: [SwiftSetting] = []

    configurations.append(contentsOf: [
        .enableUpcomingFeature("StrictConcurrency")
        
    ])
    
    switch mode {
    case .strict:
        configurations.append(
            .unsafeFlags(["-require-explicit-sendable", "-warnings-as-errors"])
        )
    default:
        break
    }

    return configurations
}()

let package = Package(
    name: "swift-package-template",
    platforms: [
        // Platforms are the available target consumers.
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Library",
            targets: ["Library"]
        ),

        .library(
            name: "CTX",
            targets: ["CTX"]
        ),

        .executable(
            name: "Executable",
            targets: ["Executable"]
        ),
    ],
    dependencies: [
        // MARK: - Core Runtime Dependencies
        .package(url: "https://github.com/apple/swift-log.git", branch: "main"),

        // MARK: - CI Dependencies
        .package(url: "https://github.com/apple/swift-play-experimental.git", branch: "main"),

        // MARK: - Plugin Dependencies
        .package(url: "https://github.com/swiftlang/swift-format.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        // MARK: - Internal

        .target(
            name: "Internal",
            dependencies: [
                .product(name: "Playgrounds", package: "swift-play-experimental")
            ],
            swiftSettings: settings,
            
        ),

        // MARK: - Public

        .target(
            name: "CTX",
            dependencies: [],
            swiftSettings: settings,
        ),

        .target(
            name: "Library",
            dependencies: [
                "Internal"
            ],
            swiftSettings: settings
        ),
        
        // MARK: - Executable

        .executableTarget(
            name: "Executable",
            dependencies: [
                "Library",
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: settings,
        ),

        // MARK: - Tests

        .testTarget(
            name: "Internal-Tests",
            dependencies: ["Internal"],
            swiftSettings: settings
        ),

        .testTarget(
            name: "CTX-Tests",
            dependencies: ["CTX"],
            swiftSettings: settings
        ),

        .testTarget(
            name: "Library-Tests",
            dependencies: ["Library"],
            swiftSettings: settings
        ),

        .testTarget(
            name: "Executable-Tests",
            dependencies: ["Library"],
            swiftSettings: settings
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
