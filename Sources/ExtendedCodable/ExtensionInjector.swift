
/// Helper providing the injection of Specification Extensions into target object during decoding
public struct ExtensionInjector<T>: Decodable where T: Extendable & Decodable {
    public var extendable: T

    typealias StorageKey = T.ExtensionStorage.Key
    typealias StorageValue = T.ExtensionStorage.Value
    struct DummyDecodable: Decodable { }

    public init(from decoder: Decoder) throws {
        extendable = try T(from: decoder)
        let allKeys = try [StorageKey: DummyDecodable](from: decoder).map { $0.key }
        let extKeys: [StorageKey] = extendable.filterExtensionStorage(keys: allKeys)
        var storage = T.ExtensionStorage()
        let container = try decoder.container(keyedBy: DynamicCodingKey<StorageKey>.self)
        for extKey in extKeys {
            storage[extKey] = try container.decode(StorageValue.self, forKey: .key(extKey))
        }
        extendable.extensions = storage
    }

}
