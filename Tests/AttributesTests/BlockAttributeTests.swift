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

}
