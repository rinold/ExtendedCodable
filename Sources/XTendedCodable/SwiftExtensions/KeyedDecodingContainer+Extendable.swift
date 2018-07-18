
extension KeyedDecodingContainer {
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T: Extendable {
        return try decode(ExtensionInjector<T>.self, forKey: key).extendable
    }

    public func decodeIfPresent<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T? where T: Extendable {
        return try decodeIfPresent(ExtensionInjector<T>.self, forKey: key)?.extendable
    }
}
