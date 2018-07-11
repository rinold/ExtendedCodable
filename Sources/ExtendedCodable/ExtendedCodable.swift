
public protocol ExtendedCodable: Extendable where ExtensionStorage == DefaultExtension { }

extension ExtendedCodable {
    public mutating func filterExtensions() {
        extensions = extensions?.filter { $0.key.hasPrefix("x-") }
    }
}

public typealias DefaultExtension = [String: AnyCodable]

extension Dictionary where Key == String, Value == AnyCodable {
    public init(_ from: [String: Any]) {
        self = from.mapValues { .init(from: $0) }
    }
}
