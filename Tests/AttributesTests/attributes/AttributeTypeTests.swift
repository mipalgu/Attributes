// AttributeTypeTests.swift 
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

/// Test class for AttributeType.
final class AttributeTypeTests: XCTestCase {

    /// The line attribute types.
    let lineAttributes: [LineAttributeType] = [
        .bool,
        .enumerated(validValues: ["1", "2"]),
        .expression(language: .c),
        .float,
        .integer,
        .line
    ]

    /// A table block type.
    let tableAttribute = BlockAttributeType.table(
        columns: [BlockAttributeType.TableColumn(name: "Column1", type: .line)]
    )

    /// The recursive BlockAttribute types.
    let recursiveAttributes: [BlockAttributeType] = [
        .collection(type: .line(.bool)),
        .complex(layout: [Field(name: "Name", type: .line(.line))])
    ]

    /// The non-recursive BlockAttribute types.
    let nonRecursiveAttributes: [BlockAttributeType] = [
        .code(language: .c),
        .text,
        .enumerableCollection(validValues: ["1", "2"])
    ]

    /// The non-recursive Block types as AttributeTypes.
    var nonRecursiveTypes: [AttributeType] {
        nonRecursiveAttributes.map {
            AttributeType.block($0)
        }
    }

    /// The recursive Block types as AttributeTypes.
    var recursiveTypes: [AttributeType] {
        recursiveAttributes.map {
            AttributeType.block($0)
        } + [AttributeType.block(tableAttribute)]
    }

    /// The block attribute types.
    var blockAttributes: [BlockAttributeType] {
        nonRecursiveAttributes + recursiveAttributes + [tableAttribute]
    }

    /// The line types as AttributeTypes.
    var lineTypes: [AttributeType] {
        lineAttributes.map {
            AttributeType.line($0)
        }
    }

    /// The block types as AttributeTypes.
    var blockTypes: [AttributeType] {
        nonRecursiveTypes + recursiveTypes
    }

    /// All the AttributeTypes.
    var allTypes: [AttributeType] {
        lineTypes + blockTypes
    }

    /// Test isLine property.
    func testIsLine() {
        lineTypes.forEach {
            XCTAssertTrue($0.isLine)
        }
        blockTypes.forEach {
            XCTAssertFalse($0.isLine)
        }
    }

    /// Test isBlock property.
    func testIsBlock() {
        lineTypes.forEach {
            XCTAssertFalse($0.isBlock)
        }
        blockTypes.forEach {
            XCTAssertTrue($0.isBlock)
        }
    }

    /// Test isRecursive property.
    func testIsRecursive() {
        (lineTypes + nonRecursiveTypes).forEach {
            XCTAssertFalse($0.isRecursive)
        }
        recursiveTypes.forEach {
            XCTAssertTrue($0.isRecursive)
        }
    }

    /// Test isTable.
    func testIsTable() {
        let table = AttributeType.block(tableAttribute)
        XCTAssertTrue(table.isTable)
        (recursiveAttributes + nonRecursiveAttributes).forEach {
            XCTAssertFalse(AttributeType.block($0).isTable)
        }
    }

    /// Test defaultValue property.
    func testDefaultValue() {
        let testData = Array(zip(blockTypes, blockAttributes))
        XCTAssertEqual(blockTypes.count, blockAttributes.count)
        XCTAssertEqual(testData.count, blockAttributes.count)
        testData.forEach {
            XCTAssertEqual($0.defaultValue, Attribute.block($1.defaultValue))
        }
        let lineTestData = Array(zip(lineTypes, lineAttributes))
        XCTAssertEqual(lineTestData.count, lineTypes.count)
        XCTAssertEqual(lineTypes.count, lineAttributes.count)
        lineTestData.forEach {
            XCTAssertEqual($0.defaultValue, Attribute.line($1.defaultValue))
        }
    }

    /// Test XMI name.
    func testXMIName() {
        let testData = Array(zip(blockTypes, blockAttributes))
        XCTAssertEqual(blockTypes.count, blockAttributes.count)
        XCTAssertEqual(testData.count, blockAttributes.count)
        testData.forEach {
            XCTAssertEqual($0.xmiName, $1.xmiName)
        }
        let lineTestData = Array(zip(lineTypes, lineAttributes))
        XCTAssertEqual(lineTestData.count, lineTypes.count)
        XCTAssertEqual(lineTypes.count, lineAttributes.count)
        lineTestData.forEach {
            XCTAssertEqual($0.xmiName, $1.xmiName)
        }
    }

    /// Test the static functions.
    func testStaticFunctions() {
        XCTAssertEqual(AttributeType.bool, .line(.bool))
        XCTAssertEqual(AttributeType.integer, .line(.integer))
        XCTAssertEqual(AttributeType.float, .line(.float))
        XCTAssertEqual(AttributeType.line, .line(.line))
        XCTAssertEqual(AttributeType.text, .block(.text))
        XCTAssertEqual(AttributeType.expression(language: .c), .line(.expression(language: .c)))
        XCTAssertEqual(
            AttributeType.enumerated(validValues: ["1", "2"]), .line(.enumerated(validValues: ["1", "2"]))
        )
        XCTAssertEqual(AttributeType.code(language: .c), .block(.code(language: .c)))
        XCTAssertEqual(AttributeType.collection(type: .line), .block(.collection(type: .line)))
        XCTAssertEqual(
            AttributeType.complex(layout: [Field(name: "Name", type: .line(.line))]),
            .block(.complex(layout: [Field(name: "Name", type: .line(.line))]))
        )
        XCTAssertEqual(
            AttributeType.enumerableCollection(validValues: ["1", "2"]),
            .block(.enumerableCollection(validValues: ["1", "2"]))
        )
        XCTAssertEqual(
            AttributeType.table(columns: [("Column1", .line)]),
            .block(.table(columns: [BlockAttributeType.TableColumn(name: "Column1", type: .line)]))
        )
    }

    /// Test decode and encode functions.
    func testDecodeEncode() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        allTypes.forEach {
            guard let data = try? encoder.encode($0) else {
                XCTFail("Failed to encode data for \($0)")
                return
            }
            print("Encoded data: \(String(data: data, encoding: .utf8) ?? "Failed to get encoded data")")
            guard let obj = try? decoder.decode(AttributeType.self, from: data) else {
                XCTFail("Failed to decode data for \($0)")
                return
            }
            XCTAssertEqual(obj, $0)
        }
    }

}
