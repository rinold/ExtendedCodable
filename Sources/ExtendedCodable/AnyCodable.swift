
import Foundation

typealias TypeEncoder = (Any, Encoder) throws -> Void

public struct AnyCodable: Codable {

    static var decoders: [(Decoder) throws -> (Any?, String)] = [
        { (try String(from: $0), "String") },
        { (try Bool(from: $0), "Bool") },
        { (try Int(from: $0), "Int") },
        { (try Double(from: $0), "Double") },
        { (try String?(from: $0), "String?") },
        { (try Bool?(from: $0), "Bool?") },
        { (try Int?(from: $0), "Int?") },
        { (try Double?(from: $0), "Double?") },
        { (try [AnyCodable](from: $0), "[AnyCodable]") },
        { (try [String: AnyCodable](from: $0), "[String: AnyCodable]") },
    ]

    static var encoders: [String: TypeEncoder] = [
        "String": makeEncoder(for: String.self),
        "Int": makeEncoder(for: Int.self),
        "Bool": makeEncoder(for: Bool.self),
        "Double": makeEncoder(for: Double.self),
        "AnyCodable": makeEncoder(for: AnyCodable?.self),
        "[AnyCodable]": makeAnyCodableArrayEncoder(),
        "[String: AnyCodable]": makeAnyCodableDictEncoder(forKey: String.self),
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

    public static func register<T>(_ type: T.Type) where T: Codable {
        decoders.append({ decoder in
            (try T(from: decoder), "\(T.self)")
        })
        encoders["\(T.self)"] = makeEncoder(for: T.self)
    }

    let anyValue: Any?
    let typeName: String

    public init<T>(from value: T) {
        anyValue = value as Any
        typeName = "\(T.self)"
    }

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

    public func to<T>(_ type: T.Type) -> T? {
        return anyValue as? T
    }

    public func to<T>(_ type: Array<T>.Type) -> [T]? {
        if let anyCodableSequence = anyValue as? [AnyCodable] {
            return anyCodableSequence.compactMap { $0.to(T.self) }
        } else {
            return (anyValue as? [Any])?.compactMap { $0 as? T }
        }
    }

    public func to<T>(_ type: Array<T?>.Type) -> [T?]? {
        if let anyCodableSequence = anyValue as? [AnyCodable] {
            return anyCodableSequence.map { $0.anyValue as? T }
        } else {
            return (anyValue as? [Any])?.map { $0 as? T }
        }
    }

}
