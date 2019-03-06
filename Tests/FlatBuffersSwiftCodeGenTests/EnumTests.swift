//
//  EnumTests.swift
//  CodeGenTests
//
//  Created by Maxim Zaks on 18.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation
import XCTest
@testable import FlatBuffersSwiftCodeGenCore

class EnumTests: XCTestCase {
    
    func testEnum() {
        let s: StaticString = """
    // my comment
    enum Foo : byte (something) {
        bar1 = 1, bar2, bar3
    }
"""
        let result = Enum.with(pointer: s.utf8Start, length: s.utf8CodeUnitCount)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0.name.value, "Foo")
        XCTAssertEqual(result?.0.type.scalar, .i8)
        XCTAssertEqual(result?.0.metaData?.values[0].0.value, "something")
        XCTAssertEqual(result?.0.cases.count, 3)
        XCTAssertEqual(result?.0.cases[0].ident.value, "bar1")
        XCTAssertEqual(result?.0.cases[0].value?.value, "1")
        XCTAssertEqual(result?.0.cases[1].ident.value, "bar2")
        XCTAssertNil(result?.0.cases[1].value)
        XCTAssertEqual(result?.0.cases[2].ident.value, "bar3")
        XCTAssertNil(result?.0.cases[2].value)
        XCTAssertEqual(result?.0.comments.count, 1)
        XCTAssertEqual(result?.0.comments[0].value, " my comment")
    }
    
    func testEnumToSwift() {
        let s: StaticString = """
    enum Foo : byte {
        bar1, bar2 = 3, bar3
    }
"""
        let result = Enum.with(pointer: s.utf8Start, length: s.utf8CodeUnitCount)
        let stringResult = result?.0.swift
        let expected = """
public enum Foo: Int8, FlatBuffersEnum {
    case bar1, bar2 = 3, bar3
    public static func fromScalar<T>(_ scalar: T) -> Foo? where T : Scalar {
        guard let value = scalar as? RawValue else {
            return nil
        }
        return Foo(rawValue: value)
    }
}
"""
        XCTAssertEqual(expected, stringResult)
    }

    func testEnumFromJsonValueExtension() {
        let s: StaticString = """
    enum Foo : byte {
        bar1, bar2 = 3, bar3
    }
"""
        let result = Enum.with(pointer: s.utf8Start, length: s.utf8CodeUnitCount)
        let stringResult = result?.0.genFromJsonValue()
        let expected = """
extension Foo {
    static func from(jsonValue: Any?) -> Foo? {
        if let string = jsonValue as? String {
            if string == "bar1" {
                return .bar1
            }
            if string == "bar2" {
                return .bar2
            }
            if string == "bar3" {
                return .bar3
            }
        }
        if let int = jsonValue as? Int,
            let rawValue = Int8(exactly: int) {
            return Foo.init(rawValue: rawValue)
        }
        return nil
    }
}
"""
        print(stringResult!)
        XCTAssertEqual(expected, stringResult!)

    }

    static var allTests = [
        ("testEnum", testEnum),
        ("testEnumToSwift", testEnumToSwift),
        ("testEnumFromJsonValueExtension", testEnumFromJsonValueExtension)
    ]
}
