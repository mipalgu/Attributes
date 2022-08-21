// AttributeTests.swift 
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for Attribute.
final class AttributeTests: XCTestCase {

    /// All line attributes.
    let lineAttributes: [LineAttribute] = [
        .bool(true),
        .enumerated("1", validValues: ["1", "2"]),
        .expression("x", language: .c),
        .float(5.2),
        .integer(2),
        .line("test")
    ]

    /// All block attributes
    let blockAttributes: [BlockAttribute] = [
        .code("y", language: .c),
        .collection([.bool(false), .bool(true)], display: nil, type: .bool),
        .complex(["Name": .line("test")], layout: [Field(name: "Name", type: .line)]),
        .enumerableCollection(["1"], validValues: ["1", "2"]),
        .table([[.line("table")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]),
        .text("test")
    ]

    /// Line Attributes.
    var lines: [Attribute] {
        lineAttributes.map {
            Attribute.line($0)
        }
    }

    /// Block Attributes.
    var blocks: [Attribute] {
        blockAttributes.map {
            Attribute.block($0)
        }
    }

    /// All Attributes.
    var all: [Attribute] {
        lines + blocks
    }

    /// All types.
    var allTypes: [AttributeType] {
        lineAttributes.map {
            AttributeType.line($0.type)
        } + blockAttributes.map {
            AttributeType.block($0.type)
        }
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

    /// Test type property.
    func testTypes() {
        XCTAssertEqual(all.count, allTypes.count)
        let data = zip(all, allTypes)
        data.forEach {
            XCTAssertEqual($0.type, $1)
        }
    }

    /// Test isLine property.
    func testIsLine() {
        lines.forEach {
            XCTAssertTrue($0.isLine)
        }
        blocks.forEach {
            XCTAssertFalse($0.isLine)
        }
    }

    /// Test isBlock property.
    func testIsBlock() {
        lines.forEach {
            XCTAssertFalse($0.isBlock)
        }
        blocks.forEach {
            XCTAssertTrue($0.isBlock)
        }
    }

    /// Test lineAttribute property.
    func testLineAttribute() {
        XCTAssertEqual(lines.count, lineAttributes.count)
        let data = zip(lines, lineAttributes)
        data.forEach {
            XCTAssertEqual($0.lineAttribute, $1)
        }
    }

    /// Test blockAttribute property.
    func testBlockAttribute() {
        XCTAssertEqual(blocks.count, blockAttributes.count)
        let data = zip(blocks, blockAttributes)
        data.forEach {
            XCTAssertEqual($0.blockAttribute, $1)
        }
    }

    /// Test strValue property.
    func testStringValue() {
        XCTAssertEqual(lines.count, lineAttributes.count)
        let lineData = zip(lines, lineAttributes)
        lineData.forEach {
            XCTAssertEqual($0.strValue, $1.strValue)
        }
        XCTAssertEqual(blocks.count, blockAttributes.count)
        let blockData = zip(blocks, blockAttributes)
        blockData.forEach {
            XCTAssertEqual($0.strValue, $1.strValue)
        }
    }

    /// Test init from LineAttribute.
    func testLineInit() {
        lineAttributes.forEach {
            XCTAssertEqual(Attribute(lineAttribute: $0), .line($0))
        }
    }

    /// Test init from BlockAttribute.
    func testBlockInit() {
        blockAttributes.forEach {
            XCTAssertEqual(Attribute(blockAttribute: $0), .block($0))
        }
    }

    /// Test static functions.
    func testStaticFunctions() {
        XCTAssertEqual(Attribute.bool(true), .line(.bool(true)))
        XCTAssertEqual(Attribute.code("x", language: .c), .block(.code("x", language: .c)))
        XCTAssertEqual(
            Attribute.complex(
                ["Name": .line(.line("test"))], layout: [Field(name: "Name", type: .line(.line))]
            ),
            .block(
                .complex(["Name": .line(.line("test"))], layout: [Field(name: "Name", type: .line(.line))])
            )
        )
        XCTAssertEqual(
            Attribute.enumerableCollection(["1"], validValues: ["1", "2"]),
            .block(.enumerableCollection(["1"], validValues: ["1", "2"]))
        )
        XCTAssertEqual(
            Attribute.enumerated("1", validValues: ["1", "2"]),
            .line(.enumerated("1", validValues: ["1", "2"]))
        )
        XCTAssertEqual(Attribute.expression("x", language: .c), .line(.expression("x", language: .c)))
        XCTAssertEqual(Attribute.float(1.0), .line(.float(1.0)))
        XCTAssertEqual(Attribute.integer(5), .line(.integer(5)))
        XCTAssertEqual(Attribute.line("test"), .line(.line("test")))
        XCTAssertEqual(
            Attribute.table([[.line("test")]], columns: [("Name", .line)]),
            .block(
                .table(
                    [[.line("test")]],
                    columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]
                )
            )
        )
        XCTAssertEqual(Attribute.text("test"), .block(.text("test")))
    }

    /// Test simple collection static functions.
    func testSimpleCollectionStaticFunctions() {
        XCTAssertEqual(
            Attribute.collection(bools: [true, true]),
            .block(.collection([.line(.bool(true)), .line(.bool(true))], display: nil, type: .bool))
        )
        XCTAssertEqual(
            Attribute.collection(code: ["x"], language: .c),
            .block(.collection([.block(.code("x", language: .c))], display: nil, type: .code(language: .c)))
        )
        XCTAssertEqual(
            Attribute.collection(expressions: ["x"], language: .c),
            .block(
                .collection(
                    [.line(.expression("x", language: .c))],
                    display: nil,
                    type: .expression(language: .c)
                )
            )
        )
        XCTAssertEqual(
            Attribute.collection(floats: [1.0, 2.0]),
            .block(.collection([.line(.float(1.0)), .line(.float(2.0))], display: nil, type: .float))
        )
        XCTAssertEqual(
            Attribute.collection(integers: [1, 2]),
            .block(.collection([.line(.integer(1)), .line(.integer(2))], display: nil, type: .integer))
        )
        XCTAssertEqual(
            Attribute.collection(lines: ["x"]),
            .block(.collection([.line(.line("x"))], display: nil, type: .line))
        )
        XCTAssertEqual(
            Attribute.collection(text: ["test"]),
            .block(.collection([.block(.text("test"))], display: nil, type: .block(.text)))
        )
        XCTAssertEqual(
            Attribute.collection([.line(.line("test"))], type: .line(.line)),
            .block(.collection([.line(.line("test"))], display: nil, type: .line(.line)))
        )
    }

    /// Test complex collection static functions.
    func testComplexCollectionStaticFunctions() {
        let lineCollection = Attribute.block(.collection([.line("x")], display: nil, type: .line))
        let collection = Attribute.block(
            .collection([lineCollection], display: nil, type: .collection(type: .line))
        )
        let result = Attribute.collection(
            collection: [[.line("x")]], type: .line
        )
        XCTAssertEqual(result, collection)
        XCTAssertEqual(
            Attribute.collection(
                complex: [["Name": .line("text")]], layout: [Field(name: "Name", type: .line)]
            ),
            Attribute.block(
                .collection(
                    [.block(.complex(["Name": .line("text")], layout: [Field(name: "Name", type: .line)]))],
                    display: nil,
                    type: .complex(layout: [Field(name: "Name", type: .line)])
                )
            )
        )
        XCTAssertEqual(
            Attribute.collection(enumerables: [["1"]], validValues: ["1", "2"]),
            .block(
                .collection(
                    [.block(.enumerableCollection(["1"], validValues: ["1", "2"]))],
                    display: nil,
                    type: .enumerableCollection(validValues: ["1", "2"])
                )
            )
        )
        XCTAssertEqual(
            Attribute.collection(enumerated: ["1"], validValues: ["1", "2"]),
            .block(
                .collection(
                    [.line(.enumerated("1", validValues: ["1", "2"]))],
                    display: nil,
                    type: .enumerated(validValues: ["1", "2"])
                )
            )
        )
        XCTAssertEqual(
            Attribute.collection(tables: [[[.line("test")]]], columns: [("Name", type: .line)]),
            .block(
                .collection(
                    [
                        .block(
                            .table(
                                [[.line("test")]],
                                columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)]
                            )
                        )
                    ],
                    display: nil,
                    type: .table(columns: [("Name", .line)])
                )
            )
        )
    }

    /// Test getters for simple types.
    func testSimpleGetters() {
        XCTAssertTrue(Attribute.line(.bool(true)).boolValue)
        XCTAssertEqual(Attribute.line(.integer(5)).integerValue, 5)
        XCTAssertEqual(Attribute.line(.float(2.0)).floatValue, 2.0)
        XCTAssertEqual(Attribute.line(.expression("x", language: .c)).expressionValue, "x")
        XCTAssertEqual(Attribute.line(.enumerated("1", validValues: ["1", "2"])).enumeratedValue, "1")
        XCTAssertEqual(
            Attribute.line(.enumerated("1", validValues: ["1", "2"])).enumeratedValidValues, ["1", "2"]
        )
        XCTAssertEqual(Attribute.line(.line("test")).lineValue, "test")
        XCTAssertEqual(Attribute.block(.code("x", language: .c)).codeValue, "x")
        XCTAssertEqual(Attribute.block(.text("test")).textValue, "test")
    }

    /// Test setters for simple types.
    func testSimpleSetters() {
        var bool = Attribute.line(.bool(true))
        bool.boolValue = false
        XCTAssertFalse(bool.boolValue)
        var integer = Attribute.line(.integer(5))
        integer.integerValue = 12
        XCTAssertEqual(integer.integerValue, 12)
        var float = Attribute.line(.float(2.0))
        float.floatValue = 7.5
        XCTAssertEqual(float.floatValue, 7.5)
        var expression = Attribute.line(.expression("x", language: .c))
        expression.expressionValue = "y"
        XCTAssertEqual(expression.expressionValue, "y")
        var enumerated = Attribute.line(.enumerated("1", validValues: ["1", "2"]))
        enumerated.enumeratedValue = "2"
        XCTAssertEqual(enumerated.enumeratedValue, "2")
        enumerated.enumeratedValidValues = ["2"]
        XCTAssertEqual(enumerated.enumeratedValidValues, ["2"])
        var line = Attribute.line(.line("test"))
        line.lineValue = "new"
        XCTAssertEqual(line.lineValue, "new")
        var code = Attribute.block(.code("x", language: .c))
        code.codeValue = "y"
        XCTAssertEqual(code.codeValue, "y")
        var text = Attribute.block(.text("test"))
        text.textValue = "new"
        XCTAssertEqual(text.textValue, "new")
    }

    /// Test complex getters.
    func testComplexGetter() {
        let collection = Attribute.block(.collection([.bool(true), .bool(false)], display: nil, type: .bool))
        XCTAssertEqual(collection.collectionValue, [.bool(true), .bool(false)])
        let complex = Attribute.block(
            .complex(["Name": .line("test")], layout: [Field(name: "Name", type: .line)])
        )
        XCTAssertEqual(complex.complexFields, [Field(name: "Name", type: .line)])
        XCTAssertEqual(complex.complexValue, ["Name": .line("test")])
        let enumerableCollection = Attribute.block(.enumerableCollection(["1"], validValues: ["1", "2"]))
        XCTAssertEqual(enumerableCollection.enumerableCollectionValue, ["1"])
        XCTAssertEqual(enumerableCollection.enumerableCollectionValidValues, ["1", "2"])
        let table = Attribute.block(
            .table([[.line("test")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)])
        )
        XCTAssertEqual(table.tableValue, [[.line("test")]])
    }

    /// Test complex setters.
    func testComplexSetters() {
        var collection = Attribute.block(.collection([.bool(true), .bool(false)], display: nil, type: .bool))
        collection.collectionValue = [.bool(false), .bool(false)]
        XCTAssertEqual(collection.collectionValue, [.bool(false), .bool(false)])
        var complex = Attribute.block(
            .complex(["Name": .line("test")], layout: [Field(name: "Name", type: .line)])
        )
        complex.complexValue = ["Name": .line("new")]
        XCTAssertEqual(complex.complexValue, ["Name": .line("new")])
        complex.complexFields = [Field(name: "Name2", type: .line)]
        XCTAssertEqual(complex.complexFields, [Field(name: "Name2", type: .line)])
        var enumerableCollection = Attribute.block(.enumerableCollection(["1"], validValues: ["1", "2"]))
        enumerableCollection.enumerableCollectionValue = ["2"]
        XCTAssertEqual(enumerableCollection.enumerableCollectionValue, ["2"])
        enumerableCollection.enumerableCollectionValidValues = ["2"]
        XCTAssertEqual(enumerableCollection.enumerableCollectionValidValues, ["2"])
        var table = Attribute.block(
            .table([[.line("test")]], columns: [BlockAttributeType.TableColumn(name: "Name", type: .line)])
        )
        table.tableValue = [[.line("new")]]
        XCTAssertEqual(table.tableValue, [[.line("new")]])
    }

    /// Test simple collection getters.
    func testSimpleCollectionGetters() {
        let boolCollection = Attribute.block(.collection(
            [.bool(true), .bool(false)], display: linePath, type: .bool
        ))
        XCTAssertEqual(boolCollection.collectionBools, [true, false])
        let integerCollection = Attribute.block(.collection(
            [.integer(1), .integer(2)], display: linePath, type: .integer
        ))
        XCTAssertEqual(integerCollection.collectionIntegers, [1, 2])
        let floatCollection = Attribute.block(.collection(
            [.float(10.0), .float(11.1)], display: linePath, type: .float
        ))
        XCTAssertEqual(floatCollection.collectionFloats, [10.0, 11.1])
        let expressionCollection = Attribute.block(.collection(
            [.expression("x", language: .c), .expression("y", language: .c)],
            display: linePath,
            type: .expression(language: .cxx)
        ))
        XCTAssertEqual(expressionCollection.collectionExpressions, ["x", "y"])
        let lineCollection = Attribute.block(.collection(
            [.line("a"), .line("b")], display: linePath, type: .line
        ))
        XCTAssertEqual(lineCollection.collectionLines, ["a", "b"])
        let codeCollection = Attribute.block(.collection(
            [.code("X()", language: .cxx), .code("Y()", language: .cxx)],
            display: linePath,
            type: .code(language: .cxx)
        ))
        XCTAssertEqual(codeCollection.collectionCode, ["X()", "Y()"])
        let textCollection = Attribute.block(.collection(
            [.text("a b c"), .text("d e f")], display: linePath, type: .text
        ))
        XCTAssertEqual(textCollection.collectionText, ["a b c", "d e f"])
        XCTAssertEqual(boolCollection.collectionDisplay, linePath)
    }

    /// Test simple collection setters.
    func testSimpleCollectionSetters() {
        var boolCollection = Attribute.block(.collection(
            [.bool(true), .bool(false)], display: linePath, type: .bool
        ))
        boolCollection.collectionBools = [true, true]
        XCTAssertEqual(boolCollection.collectionBools, [true, true])
        var integerCollection = Attribute.block(.collection(
            [.integer(1), .integer(2)], display: linePath, type: .integer
        ))
        integerCollection.collectionIntegers = [5, 6]
        XCTAssertEqual(integerCollection.collectionIntegers, [5, 6])
        var floatCollection = Attribute.block(.collection(
            [.float(10.0), .float(11.1)], display: linePath, type: .float
        ))
        floatCollection.collectionFloats = [1.0, 2.0]
        XCTAssertEqual(floatCollection.collectionFloats, [1.0, 2.0])
        var expressionCollection = Attribute.block(.collection(
            [.expression("x", language: .c), .expression("y", language: .c)],
            display: linePath,
            type: .expression(language: .cxx)
        ))
        expressionCollection.collectionExpressions = ["a", "b"]
        XCTAssertEqual(expressionCollection.collectionExpressions, ["a", "b"])
        var lineCollection = Attribute.block(.collection(
            [.line("a"), .line("b")], display: linePath, type: .line
        ))
        lineCollection.collectionLines = ["x", "y"]
        XCTAssertEqual(lineCollection.collectionLines, ["x", "y"])
        var codeCollection = Attribute.block(.collection(
            [.code("X()", language: .cxx), .code("Y()", language: .cxx)],
            display: linePath,
            type: .code(language: .cxx)
        ))
        codeCollection.collectionCode = ["1", "2"]
        XCTAssertEqual(codeCollection.collectionCode, ["1", "2"])
        var textCollection = Attribute.block(.collection(
            [.text("a b c"), .text("d e f")], display: linePath, type: .text
        ))
        textCollection.collectionText = ["1", "2"]
        XCTAssertEqual(textCollection.collectionText, ["1", "2"])
        XCTAssertEqual(boolCollection.collectionDisplay, linePath)
    }

    /// Test complex collection getters.
    func testComplexCollectionGetters() {
        let enumeratedCollection = Attribute.block(.collection(
            [.enumerated("1", validValues: ["1", "2"]), .enumerated("2", validValues: ["1", "2"])],
            display: linePath,
            type: .enumerated(validValues: ["1", "2"])
        ))
        XCTAssertEqual(enumeratedCollection.collectionEnumerated, ["1", "2"])
        let complexCollection = Attribute.block(.collection(
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
        ))
        XCTAssertEqual(
            complexCollection.collectionComplex, [["Name": .line("complex")], ["Name2": .line("complex2")]]
        )
        let enumCollCollection = Attribute.block(.collection(
            [
                .enumerableCollection(["1"], validValues: ["1", "2"]),
                .enumerableCollection(["2"], validValues: ["1", "2"])
            ],
            display: linePath,
            type: .enumerableCollection(validValues: ["1", "2"])
        ))
        XCTAssertEqual(enumCollCollection.collectionEnumerableCollection, [["1"], ["2"]])
        let tableCollection = Attribute.block(.collection(
            [
                .table([[.line("first")]], columns: [(name: "Name", type: .line)]),
                .table([[.line("second")]], columns: [(name: "Name", type: .line)])
            ],
            display: linePath,
            type: .table(columns: [(name: "Name", type: .line)])
        ))
        XCTAssertEqual(tableCollection.collectionTable, [[[.line("first")]], [[.line("second")]]])
    }

    /// Test complex collection setters.
    func testComplexCollectionSetters() {
        var enumeratedCollection = Attribute.block(.collection(
            [.enumerated("1", validValues: ["1", "2"]), .enumerated("2", validValues: ["1", "2"])],
            display: linePath,
            type: .enumerated(validValues: ["1", "2"])
        ))
        enumeratedCollection.collectionEnumerated = ["1", "1"]
        XCTAssertEqual(enumeratedCollection.collectionEnumerated, ["1", "1"])
        var complexCollection = Attribute.block(.collection(
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
        ))
        complexCollection.collectionComplex = [["Name": .line("1")], ["Name2": .line("2")]]
        XCTAssertEqual(
            complexCollection.collectionComplex, [["Name": .line("1")], ["Name2": .line("2")]]
        )
        var enumCollCollection = Attribute.block(.collection(
            [
                .enumerableCollection(["1"], validValues: ["1", "2"]),
                .enumerableCollection(["2"], validValues: ["1", "2"])
            ],
            display: linePath,
            type: .enumerableCollection(validValues: ["1", "2"])
        ))
        enumCollCollection.collectionEnumerableCollection = [["1"], ["1"]]
        XCTAssertEqual(enumCollCollection.collectionEnumerableCollection, [["1"], ["1"]])
        var tableCollection = Attribute.block(.collection(
            [
                .table([[.line("first")]], columns: [(name: "Name", type: .line)]),
                .table([[.line("second")]], columns: [(name: "Name", type: .line)])
            ],
            display: linePath,
            type: .table(columns: [(name: "Name", type: .line)])
        ))
        tableCollection.collectionTable = [[[.line("1")]], [[.line("1")]]]
        XCTAssertEqual(tableCollection.collectionTable, [[[.line("1")]], [[.line("1")]]])
    }

    /// Test decode and encode functions.
    func testDecodeEncode() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        all.forEach {
            guard let data = try? encoder.encode($0) else {
                XCTFail("Failed to encode data for \($0)")
                return
            }
            guard let obj = try? decoder.decode(Attribute.self, from: data) else {
                XCTFail("Failed to decode data for \($0)")
                return
            }
            XCTAssertEqual(obj, $0)
        }
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
