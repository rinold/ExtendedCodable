
import Foundation

extension JSONEncoder {
    public func encode<T>(_ value: T) throws -> Data where T: Extendable {
        return try encode(ExtensionExtractor(from: value))
    }

    public func encode<T>(_ value: [T]) throws -> Data where T: Extendable {
        let encodable = value.map { ExtensionExtractor(from: $0) }
        return try encode(encodable)
    }
}
