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

}
