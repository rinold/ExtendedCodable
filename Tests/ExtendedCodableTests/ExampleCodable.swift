
import ExtendedCodable
import Foundation

/// Test Codable extended with default [String: AnyCodable] storage
struct TestCodable: ExtendedCodable {
    let name: String
    let num: Int
    let timestamp: Date

    // Our extension storage
    var extensions: DefaultExtension?
}
