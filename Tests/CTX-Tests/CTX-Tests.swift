//
//  CTX-Tests.swift
//  swift-package-template
//
//  Created by Jacob Sanders on 6/18/25.
//

import Testing

@testable import CTX

@Suite("Context")
struct Tests {
    private enum A: Contextual {
        typealias Value = Int
    }

    private enum B: Contextual {
        typealias Value = Double
    }

    private enum C: Contextual {
        typealias Value = String

        static var override: String? {
            return "Overwrite"
        }
    }

    @Test("Context - Empty-Root-Context") func root() async throws {
        let context = CTX.root

        #expect(context.empty)
        #expect(context.count == 0)
    }

    @Test("Context - Read-Write-Subscripting") func subscripting() async throws {
        var context = CTX()

        #expect(context[A.self] == nil)
        #expect(context[B.self] == nil)
        #expect(context[C.self] == nil)

        context[A.self] = 1
        context[B.self] = 1.0
        context[C.self] = "string"

        #expect(!(context.empty), "Context Key(s) Were Set")
        #expect(context.count == 3, "Three Context Key(s) Were Set")

        #expect(context[A.self] == 1)
        #expect(context[B.self] == 1.0)
        #expect(context[C.self] == "string")
    }

    @Test("Context - Walking") func walk() async throws {
        var context = CTX()

        context[A.self] = 1
        context[B.self] = 1.0
        context[C.self] = "string"

        let items = context.items()

        #expect(items.count == 3)

        let mapping = context.map()

        #expect(mapping.contains(where: { $0.key.name == "A" }))
        #expect(mapping.contains(where: { $0.value as? Int == 1 }))

        #expect(mapping.contains(where: { $0.key.name == "B" }))
        #expect(mapping.contains(where: { $0.value as? Double == 1.0 }))

        #expect(mapping.allSatisfy({ (key: Keyer, value: Any) in key.name != "C" }))
        #expect(mapping.contains(where: { $0.key.name == "Overwrite" }))
        #expect(mapping.contains(where: { $0.value as? String == "string" }))
    }
}
