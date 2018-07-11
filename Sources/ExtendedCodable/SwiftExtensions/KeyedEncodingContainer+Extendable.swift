
extension KeyedEncodingContainer {
    public mutating func encode<T>(_ value: T, forKey key: KeyedDecodingContainer<K>.Key) throws where T: Extendable {
        try encode(ExtensionExtractor(from: value), forKey: key)
    }
}
