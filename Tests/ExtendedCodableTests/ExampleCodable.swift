
import ExtendedCodable

/// Test Codable extended with default [String: AnyCodable] storage
struct TestCodable: ExtendedCodable {
    let name: String
    let num: Int

    // Our extension storage
    var extensions: DefaultExtension?
}
