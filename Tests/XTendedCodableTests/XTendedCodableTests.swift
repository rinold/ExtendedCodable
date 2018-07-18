import XCTest
import XTendedCodable

final class CodableExtendedTests: XCTestCase {

    let singleTestCodableJSON = """
{
    "name" : "TestName",
    "num" : 10,
    "timestamp" : "2018-07-12T09:13:42Z",
    "x-string" : "Hello!",
    "x-int" : 10,
    "x-bool" : false,
    "x-double" : 3.14,
    "x-int-array" : [1, 2, 3],
    "x-any-array" : [1, "Welcome", false],
    "x-custom" : {
        "key" : -1,
        "description": "something"
    },
    "x-string?-array" : ["a", null, "c"],
    "x-nil" : null
}
"""

    static let nilInt: Int? = nil
    static let testExt = XTension([
        "x-string": "Hello!",
        "x-int": 10,
        "x-bool": false,
        "x-double": 3.14,
        "x-int-array": [1, 2, 3],
        "x-any-array": [1, "Welcome", false],
        "x-custom": ["key": -1, "description": "something"],
        "x-string?-array": ["a", nil, "c"],
        "x-nil": CodableExtendedTests.nilInt as Any,
    ])

    let testCodable = TestCodable(name: "TestName", num: 10, timestamp: Date(), extensions: testExt)

    func assertSignleObject(_ decoded: TestCodable) {
        XCTAssert(decoded.name == "TestName")

        guard let decodedExt = decoded.extensions else {
            XCTFail()
            return
        }

        XCTAssert(decodedExt.count == CodableExtendedTests.testExt.count)

        // Primitives
        XCTAssert(decodedExt["x-string"]?.string == "Hello!")
        XCTAssert(decodedExt["x-int"]?.int == 10)
        XCTAssert(decodedExt["x-bool"]?.bool == false)
        XCTAssert(decodedExt["x-double"]?.double == 3.14)
        XCTAssert(decodedExt["x-double"]?.float == 3.14)

        // Nillable
        XCTAssertNotNil(decodedExt["x-nil"])
        XCTAssertNil(decodedExt["x-nil"]?.any)

        // Array
        let xIntArray = decodedExt["x-int-array"]?.intArray
        XCTAssert(xIntArray == [1, 2, 3])

        guard let xOptionalStringArray = decodedExt["x-string?-array"]?.to([String?].self) else {
            XCTFail()
            return
        }
        XCTAssert(xOptionalStringArray == ["a", nil, "c"])

        guard let xAnyArray = decodedExt["x-any-array"]?.array else {
            XCTFail()
            return
        }
        XCTAssert(xAnyArray.count == 3)

        // Dictionary
        guard let xCustom = decodedExt["x-custom"]?.dict else {
            XCTFail()
            return
        }
        XCTAssert(xCustom.count == 2)
        XCTAssert(xCustom["key"]?.int == -1)
        XCTAssert(xCustom["description"]?.string == "something")
    }

    func testDecodeUsingJSONDecoder() {
        let data = singleTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            let decodedResult = try decoder.decode(TestCodable.self, from: data)
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeOptionalUsingJSONDecoder() {
        let data = singleTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let decodedResult = try decoder.decode(TestCodable?.self, from: data) else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeArrayUsingJSONDecoder() {
        let arrayWithTestCodableJSON = "[\(singleTestCodableJSON)]"
        let data = arrayWithTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let decodedResult = try decoder.decode([TestCodable].self, from: data).first else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeOptionalArrayUsingJSONDecoder() {
        let arrayWithTestCodableJSON = "[\(singleTestCodableJSON)]"
        let data = arrayWithTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let decodedResult = try decoder.decode([TestCodable]?.self, from: data)?.first else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeArrayOfOptionalUsingJSONDecoder() {
        let arrayWithTestCodableJSON = "[\(singleTestCodableJSON)]"
        let data = arrayWithTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let first = try decoder.decode([TestCodable?].self, from: data).first,
                let decodedResult = first
            else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeUsingKeyedContainer() {
        let keyedTestCodableJSON = "{\"testCodable\": \(singleTestCodableJSON)}"
        let data = keyedTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            let decodedResult = try decoder.decode(TestSingleKeyedCodingHelper.self, from: data).testCodable
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeArrayUsingKeyedContainer() {
        let keyedArrayOfTestCodableJSON = "{\"arrayOfTestCodable\": [\(singleTestCodableJSON)]}"
        let data = keyedArrayOfTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            let array = try decoder.decode(TestArrayKeyedCodingHelper.self, from: data).arrayOfTestCodable
            guard let decodedResult = array.first else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }

    }

    func testDecodeOptionalUsingKeyedContainer() {
        let keyedTestCodableJSON = "{\"testCodable\": \(singleTestCodableJSON)}"
        let data = keyedTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let decodedResult = try decoder.decode(TestOptionalKeyedCodingHelper.self, from: data).testCodable else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodeOptionalArrayUsingKeyedContainer() {
        let keyedArrayOfTestCodableJSON = "{\"arrayOfTestCodable\": [\(singleTestCodableJSON)]}"
        let data = keyedArrayOfTestCodableJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            guard let array = try decoder.decode(TestOptionalKeyedCodingHelper.self, from: data).arrayOfTestCodable,
                let decodedResult = array.first
            else {
                XCTFail()
                return
            }
            assertSignleObject(decodedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEncodeUsingJSONEncoder() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            encoder.dateEncodingStrategy = .iso8601
            decoder.dateDecodingStrategy = .iso8601
        }
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode([testCodable])
            let codable = try decoder.decode([TestCodable].self, from: data).first!
            assertSignleObject(codable)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEncodeArrayUsingJSONEncoder() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            encoder.dateEncodingStrategy = .iso8601
            decoder.dateDecodingStrategy = .iso8601
        }
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode([testCodable])
            guard let codable = try decoder.decode([TestCodable].self, from: data).first else {
                XCTFail()
                return
            }
            assertSignleObject(codable)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testDecodeUsingJSONDecoder", testDecodeUsingJSONDecoder),
        ("testDecodeOptionalUsingJSONDecoder", testDecodeOptionalUsingJSONDecoder),
        ("testDecodeArrayUsingJSONDecoder", testDecodeArrayUsingJSONDecoder),
        ("testDecodeOptionalArrayUsingJSONDecoder", testDecodeOptionalArrayUsingJSONDecoder),
        ("testDecodeArrayOfOptionalUsingJSONDecoder", testDecodeArrayOfOptionalUsingJSONDecoder),
        ("testDecodeUsingKeyedContainer", testDecodeUsingKeyedContainer),
        ("testDecodeOptionalUsingKeyedContainer", testDecodeOptionalUsingKeyedContainer),
        ("testDecodeArrayUsingKeyedContainer", testDecodeArrayUsingKeyedContainer),
        ("testDecodeOptionalArrayUsingKeyedContainer", testDecodeOptionalArrayUsingKeyedContainer),
        ("testEncodeUsingJSONEncoder", testEncodeUsingJSONEncoder),
        ("testEncodeArrayUsingJSONEncoder", testEncodeArrayUsingJSONEncoder),
    ]
}
