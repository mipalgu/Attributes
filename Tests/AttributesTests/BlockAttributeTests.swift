// BlockAttributeTests.swift 
// Attributes 
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

@testable import Attributes
import XCTest

/// Test class for BlockAttribute.
final class BlockAttributeTests: XCTestCase {

    /// BlockAttribute data to test.
    let attributes: [BlockAttribute] = [
        .code("x", language: .c),
        .text("test"),
        .collection([.line("collection")], display: nil, type: .line),
        .complex(["Name": .line("complex")], layout: [Field(name: "Name", type: .line)]),
        .enumerableCollection(["1"], validValues: ["1", "2"]),
        .table(
            [[.line("table")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]
        )
    ]

    /// The types of the attributes.
    let types: [BlockAttributeType] = [
        .code(language: .c),
        .text,
        .collection(type: .line),
        .complex(layout: [Field(name: "Name", type: .line)]),
        .enumerableCollection(validValues: ["1", "2"]),
        .table(columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)])
    ]

    /// The string values of the attributes.
    let strValues: [String] = [
        "x",
        "test",
        "collection",
        "complex",
        "1",
        "table"
    ]

    /// The XMI names of the attributes.
    let xmiNames: [String] = [
        "CodeAttribute",
        "TextAttribute",
        "CollectionAttribute",
        "ComplexAttribute",
        "EnumerableCollectionAttribute",
        "TableAttribute"
    ]

    /// An array of tuples containing the attribute and it's type.
    var valueAndTypes: [(BlockAttribute, BlockAttributeType)] {
        Array(zip(attributes, types))
    }

    /// Values and their string representations.
    var valuesAndStrValues: [(BlockAttribute, String)] {
        Array(zip(attributes, strValues))
    }

    /// The attributes and their xmiNames.
    var valuesAndXMINames: [(BlockAttribute, String)] {
        Array(zip(attributes, xmiNames))
    }

    /// A path from an Attribute to a LineAttribute.
    var linePath: ReadOnlyPath<Attribute, LineAttribute> {
        let attributePath = AnyPath(Path(Attribute.self))
        let blockPath = AnyPath(Path(path: \Attribute.blockAttribute, ancestors: [attributePath]))
        let collectionPath = AnyPath(
            Path(path: \Attribute.blockAttribute.collectionValue, ancestors: [attributePath, blockPath])
        )
        let firstPath = AnyPath(Path(
            path: \Attribute.blockAttribute.collectionValue[0],
            ancestors: [attributePath, blockPath, collectionPath]
        ))
        return ReadOnlyPath(
            keyPath: \Attribute.blockAttribute.collectionValue[0].lineAttribute,
            ancestors: [attributePath, blockPath, collectionPath, firstPath]
        )
    }

    /// Test type computed property.
    func testType() {
        valueAndTypes.forEach {
            XCTAssertEqual($0.type, $1)
        }
        XCTAssertEqual(valuesAndStrValues.count, attributes.count)
    }

    /// Test strValue.
    func testStrValue() {
        valuesAndStrValues.forEach {
            XCTAssertEqual($0.strValue, $1)
        }
        XCTAssertEqual(valuesAndStrValues.count, attributes.count)
    }

    /// Test xmiName property.
    func testXMINames() {
        valuesAndXMINames.forEach {
            XCTAssertEqual($0.xmiName, $1)
        }
        XCTAssertEqual(valuesAndXMINames.count, attributes.count)
    }

    /// Test value getters.
    func testValueGetters() {
        let code = BlockAttribute.code("x", language: .c)
        XCTAssertEqual(code.codeValue, "x")
        let text = BlockAttribute.text("test")
        XCTAssertEqual(text.textValue, "test")
        let collection = BlockAttribute.collection([.line("collection")], display: nil, type: .line)
        XCTAssertEqual(collection.collectionValue, [.line("collection")])
        let complex = BlockAttribute.complex(
            ["Name": .line("complex")], layout: [Field(name: "Name", type: .line)]
        )
        XCTAssertEqual(complex.complexFields, [Field(name: "Name", type: .line)])
        XCTAssertEqual(complex.complexValue, ["Name": .line("complex")])
        let enumerableCollection = BlockAttribute.enumerableCollection(["1"], validValues: ["1", "2"])
        XCTAssertEqual(enumerableCollection.enumerableCollectionValue, ["1"])
        XCTAssertEqual(enumerableCollection.enumerableCollectionValidValues, ["1", "2"])
        let table = BlockAttribute.table(
            [[.line("table")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]
        )
        XCTAssertEqual(table.tableValue, [[.line("table")]])
    }

    /// Test value setters.
    func testValueSetters() {
        var code = BlockAttribute.code("x", language: .c)
        code.codeValue = "y"
        XCTAssertEqual(code.codeValue, "y")
        var text = BlockAttribute.text("test")
        text.textValue = "new"
        XCTAssertEqual(text.textValue, "new")
        var collection = BlockAttribute.collection([.line("collection")], display: nil, type: .line)
        collection.collectionValue = [.line("new")]
        XCTAssertEqual(collection.collectionValue, [.line("new")])
        var complex = BlockAttribute.complex(
            ["Name": .line("complex")], layout: [Field(name: "Name", type: .line)]
        )
        complex.complexFields = [Field(name: "Name2", type: .line)]
        XCTAssertEqual(complex.complexFields, [Field(name: "Name2", type: .line)])
        complex.complexValue = ["Name2": .line("new")]
        XCTAssertEqual(complex.complexValue, ["Name2": .line("new")])
        var enumerableCollection = BlockAttribute.enumerableCollection(["1"], validValues: ["1", "2"])
        enumerableCollection.enumerableCollectionValue = ["2"]
        XCTAssertEqual(enumerableCollection.enumerableCollectionValue, ["2"])
        enumerableCollection.enumerableCollectionValidValues = ["2"]
        XCTAssertEqual(enumerableCollection.enumerableCollectionValidValues, ["2"])
        var table = BlockAttribute.table(
            [[.line("table")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]
        )
        table.tableValue = [[.line("new")]]
        XCTAssertEqual(table.tableValue, [[.line("new")]])
    }

    /// Test simple collection getters.
    func testSimpleCollectionGetters() {
        let boolCollection = BlockAttribute.collection(
            [.bool(true), .bool(false)], display: linePath, type: .bool
        )
        XCTAssertEqual(boolCollection.collectionBools, [true, false])
        let integerCollection = BlockAttribute.collection(
            [.integer(1), .integer(2)], display: linePath, type: .integer
        )
        XCTAssertEqual(integerCollection.collectionIntegers, [1, 2])
        let floatCollection = BlockAttribute.collection(
            [.float(10.0), .float(11.1)], display: linePath, type: .float
        )
        XCTAssertEqual(floatCollection.collectionFloats, [10.0, 11.1])
        let expressionCollection = BlockAttribute.collection(
            [.expression("x", language: .c), .expression("y", language: .c)],
            display: linePath,
            type: .expression(language: .cxx)
        )
        XCTAssertEqual(expressionCollection.collectionExpressions, ["x", "y"])
        let lineCollection = BlockAttribute.collection(
            [.line("a"), .line("b")], display: linePath, type: .line
        )
        XCTAssertEqual(lineCollection.collectionLines, ["a", "b"])
        let codeCollection = BlockAttribute.collection(
            [.code("X()", language: .cxx), .code("Y()", language: .cxx)],
            display: linePath,
            type: .code(language: .cxx)
        )
        XCTAssertEqual(codeCollection.collectionCode, ["X()", "Y()"])
        let textCollection = BlockAttribute.collection(
            [.text("a b c"), .text("d e f")], display: linePath, type: .text
        )
        XCTAssertEqual(textCollection.collectionText, ["a b c", "d e f"])
        XCTAssertEqual(boolCollection.collectionDisplay, linePath)
    }

    /// Test simple collection setters.
    func testSimpleCollectionSetters() {
        var boolCollection = BlockAttribute.collection(
            [.bool(true), .bool(false)], display: linePath, type: .bool
        )
        boolCollection.collectionBools = [true, true]
        XCTAssertEqual(boolCollection.collectionBools, [true, true])
        var integerCollection = BlockAttribute.collection(
            [.integer(1), .integer(2)], display: linePath, type: .integer
        )
        integerCollection.collectionIntegers = [5, 6]
        XCTAssertEqual(integerCollection.collectionIntegers, [5, 6])
        var floatCollection = BlockAttribute.collection(
            [.float(10.0), .float(11.1)], display: linePath, type: .float
        )
        floatCollection.collectionFloats = [1.0, 2.0]
        XCTAssertEqual(floatCollection.collectionFloats, [1.0, 2.0])
        var expressionCollection = BlockAttribute.collection(
            [.expression("x", language: .c), .expression("y", language: .c)],
            display: linePath,
            type: .expression(language: .cxx)
        )
        expressionCollection.collectionExpressions = ["a", "b"]
        XCTAssertEqual(expressionCollection.collectionExpressions, ["a", "b"])
        var lineCollection = BlockAttribute.collection(
            [.line("a"), .line("b")], display: linePath, type: .line
        )
        lineCollection.collectionLines = ["x", "y"]
        XCTAssertEqual(lineCollection.collectionLines, ["x", "y"])
        var codeCollection = BlockAttribute.collection(
            [.code("X()", language: .cxx), .code("Y()", language: .cxx)],
            display: linePath,
            type: .code(language: .cxx)
        )
        codeCollection.collectionCode = ["1", "2"]
        XCTAssertEqual(codeCollection.collectionCode, ["1", "2"])
        var textCollection = BlockAttribute.collection(
            [.text("a b c"), .text("d e f")], display: linePath, type: .text
        )
        textCollection.collectionText = ["1", "2"]
        XCTAssertEqual(textCollection.collectionText, ["1", "2"])
        XCTAssertEqual(boolCollection.collectionDisplay, linePath)
    }

    /// Test complex collection getters.
    func testComplexCollectionGetters() {
        let enumeratedCollection = BlockAttribute.collection(
            [.enumerated("1", validValues: ["1", "2"]), .enumerated("2", validValues: ["1", "2"])],
            display: linePath,
            type: .enumerated(validValues: ["1", "2"])
        )
        XCTAssertEqual(enumeratedCollection.collectionEnumerated, ["1", "2"])
        let complexCollection = BlockAttribute.collection(
            [
                .complex(
                    ["Name": .line("complex")],
                    layout: [Field(name: "Name", type: .line)]
                ),
                .complex(
                    ["Name2": .line("complex2")],
                    layout: [Field(name: "Name", type: .line)]
                )
            ], display: linePath,
            type: .complex(layout: [Field(name: "Name", type: .line)])
        )
        XCTAssertEqual(
            complexCollection.collectionComplex, [["Name": .line("complex")], ["Name2": .line("complex2")]]
        )
        let enumCollCollection = BlockAttribute.collection(
            [
                .enumerableCollection(["1"], validValues: ["1", "2"]),
                .enumerableCollection(["2"], validValues: ["1", "2"])
            ],
            display: linePath,
            type: .enumerableCollection(validValues: ["1", "2"])
        )
        XCTAssertEqual(enumCollCollection.collectionEnumerableCollection, [["1"], ["2"]])
        let tableCollection = BlockAttribute.collection(
            [
                .table([[.line("first")]], columns: [(name: "Name", type: .line)]),
                .table([[.line("second")]], columns: [(name: "Name", type: .line)])
            ],
            display: linePath,
            type: .table(columns: [(name: "Name", type: .line)])
        )
        XCTAssertEqual(tableCollection.collectionTable, [[[.line("first")]], [[.line("second")]]])
    }

    /// Test complex collection setters.
    func testComplexCollectionSetters() {
        var enumeratedCollection = BlockAttribute.collection(
            [.enumerated("1", validValues: ["1", "2"]), .enumerated("2", validValues: ["1", "2"])],
            display: linePath,
            type: .enumerated(validValues: ["1", "2"])
        )
        enumeratedCollection.collectionEnumerated = ["1", "1"]
        XCTAssertEqual(enumeratedCollection.collectionEnumerated, ["1", "1"])
        var complexCollection = BlockAttribute.collection(
            [
                .complex(
                    ["Name": .line("complex")],
                    layout: [Field(name: "Name", type: .line)]
                ),
                .complex(
                    ["Name2": .line("complex2")],
                    layout: [Field(name: "Name", type: .line)]
                )
            ], display: linePath,
            type: .complex(layout: [Field(name: "Name", type: .line)])
        )
        complexCollection.collectionComplex = [["Name": .line("1")], ["Name2": .line("2")]]
        XCTAssertEqual(
            complexCollection.collectionComplex, [["Name": .line("1")], ["Name2": .line("2")]]
        )
        var enumCollCollection = BlockAttribute.collection(
            [
                .enumerableCollection(["1"], validValues: ["1", "2"]),
                .enumerableCollection(["2"], validValues: ["1", "2"])
            ],
            display: linePath,
            type: .enumerableCollection(validValues: ["1", "2"])
        )
        enumCollCollection.collectionEnumerableCollection = [["1"], ["1"]]
        XCTAssertEqual(enumCollCollection.collectionEnumerableCollection, [["1"], ["1"]])
        var tableCollection = BlockAttribute.collection(
            [
                .table([[.line("first")]], columns: [(name: "Name", type: .line)]),
                .table([[.line("second")]], columns: [(name: "Name", type: .line)])
            ],
            display: linePath,
            type: .table(columns: [(name: "Name", type: .line)])
        )
        tableCollection.collectionTable = [[[.line("1")]], [[.line("1")]]]
        XCTAssertEqual(tableCollection.collectionTable, [[[.line("1")]], [[.line("1")]]])
    }

}
