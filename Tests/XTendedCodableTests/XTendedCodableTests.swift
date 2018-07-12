import XCTest
import XTendedCodable

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

            // Dictionary
            guard let xCustom = decodedExt["x-custom"]?.dict else {
                XCTFail()
                return
            }
            XCTAssert(xCustom["key"]?.int == -1)
            XCTAssert(xCustom["description"]?.string == "something")

        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEncode() {
        let c: Int? = nil
        let testExt = XTension([
            "x-string": "Hello!",
            "x-int": 10,
            "x-bool": false,
            "x-double": 3.14,
            "x-int-array": [1, 2, 3],
            "x-any-array": [1, "Welcome", false],
            "x-custom": ["key": -1, "description": "something"],
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

            XCTAssert(decodedExt["x-int"]?.int == codable.xInt)

            // Primitives
            XCTAssert(decodedExt["x-string"]?.string == testExt["x-string"]?.string)
            XCTAssert(decodedExt["x-int"]?.int == testExt["x-int"]?.int)
            XCTAssert(decodedExt["x-bool"]?.bool == testExt["x-bool"]?.bool)
            XCTAssert(decodedExt["x-double"]?.double == testExt["x-double"]?.double)
            XCTAssert(decodedExt["x-double"]?.float == testExt["x-double"]?.float)

            // Array
            XCTAssert(decodedExt["x-int-array"]?.intArray == testExt["x-int-array"]?.intArray)

            guard let xAnyArray = decodedExt["x-any-array"]?.array else {
                XCTFail()
                return
            }
            XCTAssert(xAnyArray.count == 3)

            // Dictionary
            guard let xCustom = decodedExt["x-custom"]?.dict,
                let xTestCustom = testExt["x-custom"]?.dict
            else {
                XCTFail()
                return
            }
            XCTAssert(xCustom.count == 2)
            XCTAssert(xCustom["key"]?.int == xTestCustom["key"]?.int)
            XCTAssert(xCustom["description"]?.string == xTestCustom["description"]?.string)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testDecode", testDecode),
        ("testEncode", testEncode),
    ]
}
