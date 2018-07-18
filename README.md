# XTendedCodable

[![CI Status](https://img.shields.io/travis/rinold/XTendedCodable.svg?style=flat)](https://travis-ci.org/rinold/XTendedCodable)
![Swift](https://img.shields.io/badge/swift-4.1-green.svg)
![Swift Package Manager](https://img.shields.io/badge/spm-+-orange.svg)
[![License](https://img.shields.io/cocoapods/l/ProxyResolver.svg?style=flat)](https://cocoapods.org/pods/ProxyResolver)

An easy way to handle JSON objects `x-^` extensions in Codable structures, e.g. the [OpenAPI Specification Extensions](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#specificationExtensions). All extension fields are aggregated in extensions `storage` field during decoding and are encoded at the same level as base object field.

## Usage
To support extensions decoding and encoding for your Codable structs, just conform to `XTendedCodable` protocol, e.g.:

```swift
import XTendedCodable

struct ExampleCodable: XTendedCodable {
    let name: String
    let date: Date

    // Default provided [String: AnyCodable]  storage
    var extensions: XTension?
}
```
## And that's all! :)

It can now decode the `x-^` properties from JSON:
```json
{
    "name" : "Extended Example Codable",
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
```

For example:
```swift

// Decode the JSON above
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let exampleCodable = try decoder.decode(ExampleCodable.self, from: jsonData)

if let ext = exampleCodable.extensions {
    let xOptionalStringArray = ext["x-string?-array"]?.to([String?].self)
    for string in xOptionalStringArray.compactMap { $0 } {
      print (string)
    }
}

// Output:
"a"
"c"
```

More examples of Decoding and Encoding could be found in [tests](https://github.com/rinold/XTendedCodable/blob/master/Tests/XTendedCodableTests/XTendedCodableTests.swift) sources.

#### Bonus

You can add properties to your `ExampleCodable` later in extensions or just for convenience if you know what you will be working with, e.g.:

```swift
extension TestCodable {
    var xProperty: Int? {
        get { return extensions?["x-some-property"]?.int }
        set { extensions?["x-some-property"] = .init(from: newValue) }
    }
}
```

**Note**: non-prefixed with "x-" keys will not be encoded. Possibly, you can use this to hide some properties from decoding/encoding - without modifying `CodingKeys`, `decode` and `encode` methods.

### Customization

XTendedCodable provides `Extendable` generic protocol so you can set your own Storage type (with needed conformance limitations) and per-model fields filtering rules.

### Handling custom types

Any custom type conforming Codable could be handled by just another `AnyCodable` bycicle, if no, I possibly messed up somewhere :)

```swift
AnyCodable.register(CustomCodableType.self)
```

## Installation

#### [Swift Package Manager](https://swift.org/package-manager/)

To install it add following package to needed `Packages.swift` dependencies:

```swift
.package(url: "https://github.com/rinold/XTendedCodable.git", from: "0.2.1")
```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/rinold/XTendedCodable/tags).

## Authors

* **rinold** - Mikhail Churbanov, mihail.churbanov@gmail.com

## License

ProxyResolver is available under the MIT license. See the LICENSE file for more info.
