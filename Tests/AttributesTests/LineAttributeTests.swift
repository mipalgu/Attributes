// LineAttributeTests.swift 
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

/// Test class for LineAttribute.
final class LineAttributeTests: XCTestCase {

    /// Attributes under test.
    let attributes: [LineAttribute] = [
        .bool(true),
        .enumerated("1", validValues: ["1", "2"]),
        .expression("x", language: .c),
        .float(5.5),
        .integer(5),
        .line("test")
    ]

    /// Valid values for enumerated attributes.
    let validValues: Set<String> = ["1", "2"]

    /// Test getter for values.
    func testValues() {
        XCTAssertTrue(LineAttribute.bool(true).boolValue)
        XCTAssertEqual(LineAttribute.enumerated("1", validValues: validValues).enumeratedValue, "1")
        XCTAssertEqual(
            LineAttribute.enumerated("1", validValues: validValues).enumeratedValidValues, validValues
        )
        XCTAssertEqual(LineAttribute.expression("x", language: .c).expressionValue, "x")
        XCTAssertEqual(LineAttribute.float(5.0).floatValue, 5.0)
        XCTAssertEqual(LineAttribute.integer(2).integerValue, 2)
        XCTAssertEqual(LineAttribute.line("test").lineValue, "test")
    }

    /// Test init from string.
    func tesStringInit() {
        XCTAssertEqual(LineAttribute(type: .bool, value: "true")?.boolValue, true)
        XCTAssertEqual(
            LineAttribute(type: .enumerated(validValues: validValues), value: "1")?.enumeratedValue, "1"
        )
        XCTAssertEqual(LineAttribute(type: .expression(language: .c), value: "x")?.expressionValue, "x")
        XCTAssertEqual(LineAttribute(type: .float, value: "5.0")?.floatValue, 5.0)
        XCTAssertEqual(LineAttribute(type: .integer, value: "2")?.integerValue, 2)
        XCTAssertEqual(LineAttribute(type: .line, value: "test")?.lineValue, "test")
    }

    /// Test equivalent string values.
    func testStrValues() {
        XCTAssertEqual(LineAttribute.bool(true).strValue, "true")
        XCTAssertEqual(LineAttribute.enumerated("1", validValues: validValues).strValue, "1")
        XCTAssertEqual(LineAttribute.expression("x", language: .c).strValue, "x")
        XCTAssertEqual(LineAttribute.float(5.0).strValue, "5.0")
        XCTAssertEqual(LineAttribute.integer(2).strValue, "2")
        XCTAssertEqual(LineAttribute.line("test").strValue, "test")
    }

    /// Test decode and encode functions.
    func testDecodeEncode() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        attributes.forEach {
            print("Coding \($0)")
            fflush(stdout)
            guard let data = try? encoder.encode($0) else {
                XCTFail("Failed to encode data for \($0)")
                return
            }
            guard let obj = try? decoder.decode(LineAttribute.self, from: data) else {
                XCTFail("Failed to decode data for \($0)")
                return
            }
            XCTAssertEqual(obj, $0)
        }
    }

    /// Test xmiName function.
    func testXMIName() {
        XCTAssertEqual(LineAttribute.bool(true).xmiName, "BoolAttribute")
        XCTAssertEqual(LineAttribute.enumerated("1", validValues: validValues).xmiName, "EnumeratedAttribute")
        XCTAssertEqual(LineAttribute.expression("x", language: .c).xmiName, "ExpressionAttribute")
        XCTAssertEqual(LineAttribute.float(5.0).xmiName, "FloatAttribute")
        XCTAssertEqual(LineAttribute.integer(2).xmiName, "IntegerAttribute")
        XCTAssertEqual(LineAttribute.line("test").xmiName, "LineAttribute")
    }

}
