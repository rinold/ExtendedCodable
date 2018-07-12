
// MARK: - Default Extension Storage type [String: AnyCodable]

public typealias DefaultExtension = [String: AnyCodable]

extension Dictionary where Key == String, Value == AnyCodable {
    public init(_ from: [String: Any]) {
        self = from.mapValues { .init(from: $0) }
    }
}

extension Dictionary: DecodableKeyValueContainer where Key == String, Value == AnyCodable {}

// MARK: - Extended Codable

public protocol ExtendedCodable: Extendable where ExtensionStorage == DefaultExtension { }

extension ExtendedCodable {
    public mutating func filterExtensionStorage(keys: [String]) -> [String] {
        return keys.filter { $0.hasPrefix("x-") }
    }
}
