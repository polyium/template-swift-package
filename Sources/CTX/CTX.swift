//
//  CTX.swift
//  swift-package-template
//
//  Created by Jacob Sanders on 6/18/25.
//

public protocol Contextual: Sendable {
    /// The type of value uniquely identified by this key.
    associatedtype Value: Sendable

    /// The human-readable name of a key.
    ///
    /// This name will be used instead of the type name when a value is printed.
    ///
    /// Defaults to `nil`.
    ///
    /// **Example**
    ///
    /// ```swift
    /// private enum Example: Contextual {
    ///     typealias Value = String
    ///     static var override: String? {
    ///         return "Other-Key-Name"
    ///     }
    /// }
    /// ```
    ///
    /// - Note: Ensure that the `var override` here is ***not assigned*** a default.
    ///     - Additionally, it cannot be a `let`, either, as that breaks the protocol's conformance.
    ///
    /// Technically,
    ///
    /// ```swift
    /// static var override: String? = "Bad"
    /// ```
    /// is a commuted value and is therefore not concurrency safe.
    static var override: String? { get }
}

/// Set defaults of the protocol.
extension Contextual {
    // public static let overrides: Overrides = .init()
    public static var override: String? { nil }
}

/// A type-erased ``Keyer`` used when iterating through the ``CTX`` using its `forEach` method.
public struct Keyer: Sendable {
    /// The key's type erased to `Any.Type`.
    public let type: Any.Type

    /// A key override for the instance's ``name``.
    private let override: String?
    
    //public let overrides: Overrides = .init()

    /// A human-readable String representation of the underlying key.
    /// If no explicit name has been set on the wrapped key the type name is used.
    public var name: String {
        self.override ?? String(describing: self.type.self)
    }

    init<Key: Contextual>(_ v: Key.Type) {
        self.type = v
        self.override = v.override
    }
}

extension Keyer: Hashable {
    public static func == (lhs: Keyer, rhs: Keyer) -> Bool {
        ObjectIdentifier(lhs.type) == ObjectIdentifier(rhs.type)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self.type))
    }
}

public struct CTX: Sendable {
    private var storage = [Keyer: Sendable]()

    init() {}
}

extension CTX {
    public func items() -> [(Keyer, Any)] {
        var v: [(Keyer, Any)] = []
        
        self.storage.forEach { key, value in
            v.append((key, value))
        }
        
        return v
    }
    
    public func map() -> [Keyer: Any] {
        var v: [Keyer: Any] = [:]
        
        self.storage.forEach { key, value in
            v[key] = value
        }
        
        return v
    }
}

extension CTX {
    /// Creates a new empty "top level" context, generally used as an "initial" context to immediately be populated with
    /// some values by a framework or runtime. Another use case is for tasks starting in the "background" (e.g. on a timer),
    /// which don't have a "request context" per se that they can pick up, and as such they have to create a "top level"
    /// context for their work.
    ///
    /// ## Usage
    ///
    /// ### Frameworks
    ///
    /// This function is really only intended to be used by frameworks and libraries, at the "top-level" where a request's,
    /// message's or task's processing is initiated. For example, a framework handling requests, should create an empty
    /// context when handling a request only to immediately populate it with useful trace information extracted from e.g.
    /// request headers.
    ///
    /// ### Applications
    /// Application code should never have to create an empty context during the processing lifetime of any request,
    /// and only should create context if some processing is performed in the background - thus the naming of this property.
    ///
    /// Usually, a framework such as an HTTP server or similar "request handler" would already provide users
    /// with a context to be passed along through subsequent calls, either implicitly through the task-local `CTX.current`
    /// or explicitly as part of some kind of framework-related `CTX`.
    public static var root: CTX {
        CTX()
    }
}

extension CTX {
    /// A context intended as a placeholder until a real value can be passed through a function call.
    ///
    /// It should ONLY be used while prototyping or when the passing of the proper context is not yet possible,
    /// e.g. because an external library did not pass it correctly and has to be fixed before the proper context
    /// can be obtained where the TO-DO/Placeholder is currently used.
    ///
    /// ## Crashing on TO-DO context creation
    /// You may set the `CTX_STRICT` variable while compiling a project in order to make calls to this function crash
    /// with a fatal error, indicating where a placeholder context was used. This comes in handy when wanting to ensure that
    /// a project never ends up using code which initially was written as "was lazy, did not pass context", yet the
    /// project requires context passing to be done correctly throughout the application. Similar checks can be performed
    /// at compile time easily using linters (not yet implemented), since it is always valid enough to detect a to-do context
    /// being passed as illegal and warn or error when spotted.
    ///
    /// ## Example
    ///
    ///     let context = CTX.Placeholder("The framework XYZ should be modified to pass us a context here, and we'd pass it along"))
    ///
    /// - Parameters:
    ///   - reason: Informational reason for developers, why a placeholder context was used instead of a proper one,
    ///   - function: The function to which the Placeholder refers.
    ///   - file: The file to which the Placeholder refers.
    ///   - line: The line to which the Placeholder refers.
    /// - Returns: Empty "to-do" context which should be eventually replaced with a carried through one, or `topLevel`.
    public static func Placeholder(
        _ reason: StaticString? = "",
        function: String = #function,
        file: String = #file,
        line: UInt = #line
    ) -> CTX {
        var context = CTX()
        #if CTXSTRICT
        fatalError("CTXSTRICT: @ \(file):\(line) (function \(function)), reason: \(reason)")
        #else
        context[Key.self] = .init(file: file, line: line)
        #endif
        
        return context
    }
    
    private enum Key: Contextual {
        typealias Value = Location.Placeholder
        static var override: String? { "Placeholder" }
    }
}

public struct Location: Sendable {
    /// Carried automatically by a "to do" context.
    /// It can be used to track where a context originated and which "to do" context must be fixed into a real one to avoid this.
    public struct Placeholder: Sendable {
        /// Source file location where the to-do or placeholder``CTX`` was created
        public let file: String
        /// Source line location where the to-do or placeholder``CTX`` was created
        public let line: UInt
    }
}

extension CTX {
    /// Provides type-safe access to the context's values.
    /// This API should ONLY be used inside of accessor implementations.
    ///
    /// End users should use "accessors" the key's author MUST define rather than using this subscript, following this pattern:
    ///
    ///     internal enum TestID: CTX.Key {
    ///         typealias Value = TestID
    ///     }
    ///
    ///     extension CTX {
    ///         public internal(set) var testID: TestID? {
    ///             get {
    ///                 self[TestIDKey.self]
    ///             }
    ///             set {
    ///                 self[TestIDKey.self] = newValue
    ///             }
    ///         }
    ///     }
    ///
    /// This is in order to enforce a consistent style across projects and also allow for fine grained control over
    /// who may set and who may get such property. Just access control to the Key type itself lacks such fidelity.
    ///
    /// Note that specific context and context types MAY (and usually do), offer also a way to set context values,
    /// however in the most general case it is not required, as some frameworks may only be able to offer reading.
    public subscript<Key: Contextual>(_ key: Key.Type) -> Key.Value? {
        get {
            guard let value = self.storage[Keyer(key)] else { return nil }
            // It's safe to force-cast as this subscript is the only way to set a value.
            return (value as! Key.Value)
        }
        set {
            self.storage[Keyer(key)] = newValue
        }
    }
}

extension CTX {
    /// The number of items in the context.
    public var count: Int {
        self.storage.count
    }

    /// A Boolean value that indicates whether the context is empty.
    public var empty: Bool {
        self.storage.isEmpty
    }

    /// Iterate through all items in this `CTX` by invoking the given closure for each item.
    ///
    /// The order of those invocations is NOT guaranteed and should not be relied on.
    ///
    /// - Parameter body: The closure to be invoked for each item stored in this `CTX`,
    /// passing the type-erased key and the associated value.
    // @preconcurrency
    public func forEach(_ body: (Keyer, any Sendable) throws -> Void) rethrows {
        // swift-format-ignore: ReplaceForEachWithForLoop
        try self.storage.forEach { key, value in
            try body(key, value)
        }
    }
}

// MARK: - Propagating ServiceContext

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension CTX {
    /// A `CTX` is automatically propagated through task-local storage. This API enables binding a top-level `CTX` and
    /// implicitly passes it to child tasks when using structured concurrency.
    @TaskLocal public static var current: CTX?

    /// Convenience API to bind the task-local ``CTX/current`` to the passed `value`, and execute the passed `operation`.
    ///
    /// To access the task-local value, use `CTX.current`.
    ///
    /// SeeAlso: [Swift Task Locals](https://developer.apple.com/documentation/swift/tasklocal)
    public static func withValue<T>(_ value: CTX?, operation: () throws -> T) rethrows -> T {
        try CTX.$current.withValue(value, operation: operation)
    }

    #if compiler(>=6.0)
    /// Convenience API to bind the task-local ``CTX/current`` to the passed `value`, and execute the passed `operation`.
    ///
    /// To access the task-local value, use `CTX.current`.
    ///
    /// SeeAlso: [Swift Task Locals](https://developer.apple.com/documentation/swift/tasklocal)
    public static func withValue<T>(
        _ value: CTX?,
        isolation: isolated (any Actor)? = #isolation,
        operation: () async throws -> T
    ) async rethrows -> T {
        try await CTX.$current.withValue(value, operation: operation)
    }
    #endif
}
