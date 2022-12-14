// BlockAttributeTypeTests.swift 
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

/// Test class for BlockAttributeType.
final class BlockAttributeTypeTests: XCTestCase {

    /// The recursive BlockAttribute types.
    let recursiveTypes: [BlockAttributeType] = [
        .collection(type: .line(.bool)),
        .complex(layout: [Field(name: "Name", type: .line(.line))]),
        .table(columns: [BlockAttributeType.TableColumn(name: "Column1", type: .line)])
    ]

    /// The non-recursive BlockAttribute types.
    let nonRecursiveTypes: [BlockAttributeType] = [
        .code(language: .c),
        .text,
        .enumerableCollection(validValues: ["1", "2"])
    ]

    /// Test data for all values of BlockAttributeType.
    var allTypes: [BlockAttributeType] {
        recursiveTypes + nonRecursiveTypes
    }

    /// All xmiNames
    let xmiNames: [String] = [
        "CollectionAttributeType",
        "ComplexAttributeType",
        "TableAttributeType",
        "CodeAttributeType",
        "TextAttributeType",
        "EnumCollectionAttributeType"
    ]

    /// All default values.
    let defaultValues: [BlockAttribute] = [
        .collection([], display: nil, type: .line(.bool)),
        .complex(
            ["Name": .line(.line(""))],
            layout: [Field(name: "Name", type: .line(.line))]
        ),
        .table([], columns: [BlockAttributeType.TableColumn(name: "Column1", type: .line)]),
        .code("", language: .c),
        .text(""),
        .enumerableCollection([], validValues: ["1", "2"])
    ]

    /// The types with their default values.
    var zippedValues: [(BlockAttributeType, BlockAttribute)] {
        Array(zip(allTypes, defaultValues))
    }

    /// The types with thei xmi names.
    var zippedNames: [(BlockAttributeType, String)] {
        Array(zip(allTypes, xmiNames))
    }

    /// Test TableColumn init.
    func testTableColumnInit() {
        let column = BlockAttributeType.TableColumn(name: "test", type: .integer)
        XCTAssertEqual(column.name, "test")
        XCTAssertEqual(column.type, .integer)
    }

    /// Test TableColumn getters and setters.
    func testTableColumnGetterAndSetter() {
        var column = BlockAttributeType.TableColumn(name: "test", type: .integer)
        column.name = "name"
        column.type = .float
        XCTAssertEqual(column.name, "name")
        XCTAssertEqual(column.type, .float)
    }

    /// Test isRecursive property.
    func testIsRecursive() {
        recursiveTypes.forEach {
            XCTAssertTrue($0.isRecursive)
        }
        nonRecursiveTypes.forEach {
            XCTAssertFalse($0.isRecursive)
        }
    }

    /// Test isTable property.
    func testIsTable() {
        let nonTableTypes = nonRecursiveTypes + [
            .collection(type: .line(.bool)),
            .complex(layout: [Field(name: "Name", type: .line(.line))])
        ]
        let table = BlockAttributeType.table(
            columns: [BlockAttributeType.TableColumn(name: "Column1", type: .line)]
        )
        XCTAssertTrue(table.isTable)
        nonTableTypes.forEach {
            XCTAssertFalse($0.isTable)
        }
    }

    /// Test defaultValue property.
    func testDefaultValue() {
        zippedValues.forEach {
            XCTAssertEqual($0.defaultValue, $1)
        }
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
            guard let obj = try? decoder.decode(BlockAttributeType.self, from: data) else {
                XCTFail("Failed to decode data for \($0)")
                return
            }
            XCTAssertEqual(obj, $0)
        }
    }

    /// Test xmiName property.
    func testXMINames() {
        zippedNames.forEach {
            XCTAssertEqual($0.xmiName, $1)
        }
    }

}
