
import Foundation

public struct AnyCodable {

    let anyValue: Any?
    let typeName: String

    public static func register<T>(_ type: T.Type) where T: Codable {
        decoders.append({ decoder in
            (try T(from: decoder), "\(T.self)")
        })
        encoders["\(T.self)"] = makeEncoder(for: T.self)
    }

    public init<T>(from value: T) {
        anyValue = value as Any
        typeName = "\(T.self)"
    }

    static var decoders: [(Decoder) throws -> (Any?, String)] = [
        { (try String(from: $0), "String") },
        { (try Bool(from: $0), "Bool") },
        { (try Int(from: $0), "Int") },
        { (try Double(from: $0), "Double") },
        { (try String?(from: $0), "Optional<String>") },
        { (try Bool?(from: $0), "Optional<Bool>") },
        { (try Int?(from: $0), "Optional<Int?>") },
        { (try Double?(from: $0), "Optional<Double>") },
        { (try [AnyCodable](from: $0), "Array<AnyCodable>") },
        { (try [String: AnyCodable](from: $0), "Dictionary<String, AnyCodable>") },
    ]

    typealias TypeEncoder = (Any, Encoder) throws -> Void

    static var encoders: [String: TypeEncoder] = [
        "String": makeEncoder(for: String.self),
        "Int": makeEncoder(for: Int.self),
        "Bool": makeEncoder(for: Bool.self),
        "Double": makeEncoder(for: Double.self),
        "AnyCodable": makeEncoder(for: AnyCodable?.self),
        "Array<AnyCodable>": makeAnyCodableArrayEncoder(),
        "Dictionary<String, AnyCodable>": makeAnyCodableDictEncoder(forKey: String.self),
    ]

    static func makeEncoder<T>(for type: T.Type) -> TypeEncoder where T: Encodable {
        return { anyValue, encoder in
            if let value = anyValue as? T {
                try value.encode(to: encoder)
            } else {
                let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "")
                throw EncodingError.invalidValue(anyValue, context)
            }
        }
    }

    static func makeAnyCodableArrayEncoder() -> TypeEncoder {
        return { anyValue, encoder in
            if let value = anyValue as? [Any] {
                let mapped = value.map { AnyCodable(from: $0) }
                try mapped.encode(to: encoder)
            } else {
                let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "")
                throw EncodingError.invalidValue(anyValue, context)
            }
        }
    }

    static func makeAnyCodableDictEncoder<T>(forKey type: T.Type) -> TypeEncoder where T: Hashable & Encodable {
        return { anyValue, encoder in
            if let value = anyValue as? [T: Any] {
                let mapped = value.mapValues { AnyCodable(from: $0) }
                try mapped.encode(to: encoder)
            } else {
                let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "")
                throw EncodingError.invalidValue(anyValue, context)
            }
        }
    }

}

extension AnyCodable: Codable {

    public init(from decoder: Decoder) throws {
        for typeDecoder in AnyCodable.decoders {
            do {
                (anyValue, typeName) = try typeDecoder(decoder)
                return
            } catch {
                continue
            }
        }
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        guard let value = anyValue else {
            return
        }

        if typeName == "Any" {
            for typeEncoder in AnyCodable.encoders.values {
                do {
                    try typeEncoder(value, encoder)
                    return
                } catch {
                    continue
                }
            }
        }

        guard let typeEncoder = AnyCodable.encoders.first(where: { $0.key == typeName })?.value else {
            return
        }
        try typeEncoder(value, encoder)
    }

}

extension AnyCodable {

    public func to<T>(_ type: T.Type) -> T? {
        return anyValue as? T
    }

    public func to<T>(_ type: Array<T>.Type) -> [T]? {
        if let anyCodableArray = anyValue as? [AnyCodable] {
            return anyCodableArray.compactMap { $0.to(T.self) }
        } else {
            return (anyValue as? [Any])?.compactMap { $0 as? T }
        }
    }

    public func to(_ type: Array<AnyCodable>.Type) -> [AnyCodable]? {
        guard let anyCodableArray = anyValue as? [Any] else {
            return nil
        }
        return anyCodableArray.compactMap {
            return $0 as? AnyCodable ?? AnyCodable(from: $0)
        }
    }

    // Not needed on Swift 4.2
    public func to<T>(_ type: Array<T?>.Type) -> [T?]? {
        if let anyCodableSequence = anyValue as? [AnyCodable] {
            return anyCodableSequence.map { $0.anyValue as? T }
        } else {
            return (anyValue as? [Any])?.map { $0 as? T }
        }
    }

    public func to<K, V>(_ type: Dictionary<K, V>.Type) -> Dictionary<K, V>? {
        if let anyCodableDict = anyValue as? [K: AnyCodable] {
            return anyCodableDict.compactMapValues { $0.to(V.self) }
        } else if let anyDict = anyValue as? [K: Any] {
            return anyDict.compactMapValues { $0 as? V }
        }
        return nil
    }

    public func to<K>(_ type: Dictionary<K, AnyCodable>.Type) -> Dictionary<K, AnyCodable>? {
        guard let anyDict = anyValue as? [K: Any] else {
            return nil
        }
        return anyDict.compactMapValues {
            return $0 as? AnyCodable ?? AnyCodable(from: $0)
        }
    }

}

