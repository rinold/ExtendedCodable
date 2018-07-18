
import Foundation

extension JSONDecoder {
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Extendable {
        return try decode(ExtensionInjector<T>.self, from: data).extendable
    }

    public func decode<T>(_ type: [T].Type, from data: Data) throws -> [T] where T: Extendable {
        return try decode([ExtensionInjector<T>].self, from: data).map { $0.extendable }
    }
}
