import Foundation
import Library
import Logging

internal func initialize() {
    /// Initialize the default logger.
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardError(label: label)
        handler.logLevel = .trace
        return handler
    }
}

@main
public struct Executable: Sendable {
    fileprivate static let logger = Logger(label: "io.polyium.apple.swift-package-template")

    public static func main() async {
        initialize()

        logger.notice("Example Executable ...")

        print("Hello World")
    }
}
