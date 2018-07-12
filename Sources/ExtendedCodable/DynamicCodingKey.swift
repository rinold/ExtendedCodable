
public enum DynamicCodingKey1: CodingKey { }

public enum DynamicCodingKey<T>: CodingKey where T: CustomStringConvertible & LosslessStringConvertible {
    case key(T)

    public var stringValue: String {
        guard case let .key(stringValue) = self else {
            assert(false, "")
        }
        return stringValue.description
    }

    public init?(stringValue: String) {
        guard let keyValue = T(stringValue) else { return nil }
        self = .key(keyValue)
    }

    public var intValue: Int? {
        return nil
    }

    public init?(intValue: Int) {
        return nil
    }
}
