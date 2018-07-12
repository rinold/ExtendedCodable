
extension AnyCodable {

    public var any: Any? {
        return anyValue
    }

    public var string: String? {
        return to(String.self)
    }

    public var int: Int? {
        return to(Int.self)
    }

    public var bool: Bool? {
        return to(Bool.self)
    }

    public var double: Double? {
        return to(Double.self)
    }

    public var float: Float? {
        if let double = to(Double.self) { return Float(double) }
        return nil
    }

    public var array: [AnyCodable]? {
        return to([AnyCodable].self)
    }

    public var stringArray: [String]? {
        return to([String].self)
    }

    public var intArray: [Int]? {
        return to([Int].self)
    }

    public var boolArray: [Bool]? {
        return to([Bool].self)
    }

    public var doubleArray: [Double]? {
        return to([Double].self)
    }

    public var dict: [String: AnyCodable]? {
        return to([String: AnyCodable].self)
    }

}
