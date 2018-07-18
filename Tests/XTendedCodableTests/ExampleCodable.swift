
import Foundation
import XTendedCodable

/// Test Codable extended with default [String: AnyCodable] storage
struct TestCodable: XTendedCodable {
    let name: String
    let num: Int
    let timestamp: Date

    // Extension storage (XTension is default one provided - [String: AnyCodable] storage
    var extensions: XTension?
}

extension TestCodable {
    var xInt: Int? {
        get { return extensions?["x-int"]?.int }
        set { extensions?["x-int"] = .init(from: newValue) }
    }
}

struct TestSingleKeyedCodingHelper: Codable {
    let testCodable: TestCodable
}

struct TestArrayKeyedCodingHelper: Codable {
    let arrayOfTestCodable: [TestCodable]
}

struct TestOptionalKeyedCodingHelper: Codable {
    let testCodable: TestCodable?
    let arrayOfTestCodable: [TestCodable]?
}
