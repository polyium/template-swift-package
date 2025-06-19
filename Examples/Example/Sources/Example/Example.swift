import Foundation

import Library

import Logging

/// Initialize runtime requirements. Function should be called as early as possible.
internal func initialize() ->  {
    /// Initialize the default logger.
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardError(label: label)
        handler.logLevel = .trace
        return handler
    }
}

@main
public struct Example: Sendable {
    fileprivate static let logger = Logger(label: "io.polyium.apple.example")
    
    public static func main() async {
        initialize()
        
        logger.notice("Executable ...")
        
        print("Hello World")
    }
}
