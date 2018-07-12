import XCTest
@testable import ExtendedCodable

final class CodableExtendedTests: XCTestCase {

    func testDecode() {
        let jsonString = """
{
    "name" : "TestName",
    "num" : 10,
    "timestamp": "2018-07-12T09:13:42Z",
    "x-bool" : false,
    "x-custom" : {
        "key" : -1,
        "description": "something"
    },
    "x-double" : 3.14,
    "x-string" : "Hello!",
    "x-nil": null,
    "x-int" : 10,
    "x-int-array" : [1, 2, 3],
    "x-string?-array" : ["a", null, "c"]
}
"""
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        do {
            let decodedResult = try decoder.decode(TestCodable.self, from: data)

            XCTAssert(decodedResult.name == "TestName")

            guard let decodedExt = decodedResult.extensions else {
                XCTFail()
                return
            }

            XCTAssert(decodedExt.count == 8)

            // Primitives
            XCTAssert(decodedExt["x-string"]?.to(String.self) == "Hello!")
            XCTAssert(decodedExt["x-int"]?.to(Int.self) == 10)
            XCTAssert(decodedExt["x-bool"]?.to(Bool.self) == false)
            XCTAssert(decodedExt["x-double"]?.to(Double.self) == 3.14)

            // Nillable
            XCTAssertNotNil(decodedExt["x-nil"])
            XCTAssertNil(decodedExt["x-nil"]!.anyValue)

            // Array
            let xIntArray = decodedExt["x-int-array"]!.to([Int].self)
            XCTAssert(xIntArray == [1, 2, 3])

            let xOptionalStringArray = decodedExt["x-string?-array"]!.to([String?].self)
            XCTAssert(xOptionalStringArray == ["a", nil, "c"])

            // Dictionary
            guard let xCustom = decodedExt["x-custom"]?.to([String: AnyCodable].self) else {
                XCTFail()
                return
            }
            XCTAssert(xCustom["key"]?.to(Int.self) == -1)
            XCTAssert(xCustom["description"]?.to(String.self) == "something")

        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEncode() {
        let c: Int? = nil
        let testExt = DefaultExtension([
            "x-string": "Hello!",
            "x-int": 10,
            "x-bool": false,
            "x-double": 3.14,
            "x-int-array": [1, 2, 3],
            "x-custom": ["key": -1],
            "x-nil": c as Any,
        ])

        let testCodable = TestCodable(name: "TestName", num: 10, timestamp: Date(), extensions: testExt)

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            encoder.dateEncodingStrategy = .iso8601
            decoder.dateDecodingStrategy = .iso8601
        }
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(testCodable)
            let codable = try decoder.decode(TestCodable.self, from: data)

            XCTAssert(codable.name == testCodable.name)

            guard let decodedExt = codable.extensions else {
                XCTFail()
                return
            }
            XCTAssert(decodedExt.count == testExt.count)

            // Primitives
            XCTAssert(decodedExt["x-string"]?.to(String.self) == testExt["x-string"]?.to(String.self))
            XCTAssert(decodedExt["x-int"]?.to(Int.self) == testExt["x-int"]?.to(Int.self))
            XCTAssert(decodedExt["x-bool"]?.to(Bool.self) == testExt["x-bool"]?.to(Bool.self))
            XCTAssert(decodedExt["x-double"]?.to(Double.self) == testExt["x-double"]?.to(Double.self))

            // Array
            XCTAssert(decodedExt["x-int-array"]?.to([Int].self) == testExt["x-int-array"]?.to([Int].self))

            // Dictionary
            guard let xCustom = decodedExt["x-custom"]?.to([String: AnyCodable].self),
                let xTestCustom = testExt["x-custom"]?.to([String: Any].self)
            else {
                XCTFail()
                return
            }
            XCTAssert(xCustom["key"]?.to(Int.self) == xTestCustom["key"] as? Int)
            XCTAssert(xCustom["description"]?.to(String.self) == xTestCustom["String"] as? String)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testDecode", testDecode),
        ("testEncode", testEncode),
    ]
}
