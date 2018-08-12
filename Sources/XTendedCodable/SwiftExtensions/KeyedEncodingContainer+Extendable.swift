
extension KeyedEncodingContainer {
    public mutating func encode<T>(_ value: T, forKey key: KeyedDecodingContainer<K>.Key) throws where T: Extendable {
        try encode(ExtensionExtractor(from: value), forKey: key)
    }

    public mutating func encode<T>(_ value: [T], forKey key: KeyedDecodingContainer<K>.Key) throws where T: Extendable {
        let encodable = value.map { ExtensionExtractor(from: $0) }
        try encode(encodable, forKey: key)
    }

    public mutating func encodeIfPresent<T>(_ value: T?, forKey key: KeyedDecodingContainer<K>.Key) throws where T: Extendable {
        guard let value = value else { return }
        try encode(ExtensionExtractor(from: value), forKey: key)
    }

    public mutating func encodeIfPresent<T>(_ value: [T]?, forKey key: KeyedDecodingContainer<K>.Key) throws where T: Extendable {
        guard let value = value else { return }
        let encodable = value.map { ExtensionExtractor(from: $0) }
        try encode(encodable, forKey: key)
    }
}
