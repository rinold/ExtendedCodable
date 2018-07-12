
public struct FailableCodable<T: Codable> : Codable {

    public let model: T?

    public init(from codable: T?) {
        model = codable
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        model = try? container.decode(T.self)
    }

    public func encode(to encoder: Encoder) throws {
        try? model.encode(to: encoder)
    }

}

public struct FailableCodableArray<Element: Codable>: Codable {

    public let elements: [Element]

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        while !container.isAtEnd {
            if let element = try container.decode(FailableCodable<Element>.self).model {
                elements.append(element)
            }
        }
        self.elements = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in elements {
            try? container.encode(FailableCodable(from: element))
        }
    }

}
