// TableColumnTests.swift 
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
import AttributesTestUtils
import XCTest

/// Test class for ``TableColumn``.
final class TableColumnTests: XCTestCase {

    /// Test bool initialisation.
    func testBool() throws {
        let validator = NullValidator<Bool>()
        let column = TableColumn.bool(
            label: "A", validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .bool)
        try column.validator.performValidation(.bool(true))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertTrue(validator.lastParameter ?? false)
    }

    /// Test integer initialisation.
    func testInteger() throws {
        let validator = NullValidator<Int>()
        let column = TableColumn.integer(
            label: "A", validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .integer)
        try column.validator.performValidation(.integer(10))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 10)
    }

    /// Test float initialisation.
    func testFloat() throws {
        let validator = NullValidator<Double>()
        let column = TableColumn.float(
            label: "A", validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .float)
        try column.validator.performValidation(.float(10.0))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 10.0)
    }

    /// Test expression initialisation.
    func testExpression() throws {
        let validator = NullValidator<Expression>()
        let column = TableColumn.expression(
            label: "A", language: .c, validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .expression(language: .c))
        try column.validator.performValidation(.expression("int x;", language: .c))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, "int x;")
    }

    /// Test line initialisation.
    func testLine() throws {
        let validator = NullValidator<String>()
        let column = TableColumn.line(
            label: "A", validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .line)
        try column.validator.performValidation(.line("B"))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, "B")
    }

    /// Test enumerated initialisation.
    func testEnumerated() throws {
        let validator = NullValidator<String>()
        let validValues: Set<String> = ["A", "B"]
        let column = TableColumn.enumerated(
            label: "A",
            validValues: validValues,
            validation: ValidatorFactory.required().push { _ in validator }
        )
        XCTAssertEqual(column.label, "A")
        XCTAssertEqual(column.type, .enumerated(validValues: validValues))
        try column.validator.performValidation(.enumerated("B", validValues: validValues))
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, "B")
    }

}
