
/// Dictionary of x-^ properties with String keys and AnyCodable values
public typealias XTension = [String: AnyCodable]

extension Dictionary: DecodableKeyValueContainer where Key == String, Value == AnyCodable {
    public init(_ from: [String: Any]) {
        self = from.mapValues { .init(from: $0) }
    }
}

extension Extendable where ExtensionStorage == XTension {

    public func filteredStorageKeysForDecoding(keys: [String]) -> [String] {
        return keys.filter { $0.hasPrefix("x-") }
    }

    public func filteredStorageForEncoding() -> XTension? {
        return extensions?.filter { $0.key.hasPrefix("x-") }
    }
    
}
