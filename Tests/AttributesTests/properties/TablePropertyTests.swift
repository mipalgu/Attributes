// TablePropertyTests.swift 
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

/// Test class for ``TableProperty``.
final class TablePropertyTests: XCTestCase {

    /// The tables validator.
    var attributeValidator = NullValidator<Attribute>()

    /// The columns within the table.
    var columns: [TableColumn] {
        [
            TableColumn.bool(
                label: "A", validation: ValidatorFactory.required().equalsTrue()
            ),
            TableColumn.line(
                label: "B", validation: ValidatorFactory.required().notEmpty()
            )
        ]
    }

    /// The equivalent ``SchemaAttribute``.
    var schemaAttribute: SchemaAttribute {
        SchemaAttribute(
            label: "Table",
            type: .table(columns: columns.map { ($0.label, $0.type) }),
            validate: AnyValidator(attributeValidator)
        )
    }

    /// Create validator before every test.
    override func setUp() {
        attributeValidator = NullValidator<Attribute>()
    }

    /// Test property init.
    func testInit() throws {
        let table = TableProperty(label: "Table", columns: columns) { _ in
            attributeValidator
        }
        let attribute = schemaAttribute
        let wrapped = table.wrappedValue
        XCTAssertEqual(wrapped.label, attribute.label)
        XCTAssertEqual(wrapped.type, attribute.type)
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        try wrapped.validate.performValidation(tableAttribute)
        XCTAssertEqual(attributeValidator.timesCalled, 1)
        XCTAssertEqual(attributeValidator.lastParameter, tableAttribute)
        let copy = table.projectedValue
        let wrapped2 = copy.wrappedValue
        XCTAssertEqual(wrapped2.label, attribute.label)
        XCTAssertEqual(wrapped2.type, attribute.type)
        try wrapped2.validate.performValidation(tableAttribute)
        XCTAssertEqual(attributeValidator.timesCalled, 2)
        XCTAssertEqual(attributeValidator.parameters, [tableAttribute, tableAttribute])
    }

    /// Test wrapped init.
    func testWrappedInit() throws {
        let attribute = schemaAttribute
        let table = TableProperty(wrappedValue: attribute)
        let wrapped = table.wrappedValue
        XCTAssertEqual(wrapped.label, attribute.label)
        XCTAssertEqual(wrapped.type, attribute.type)
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        try wrapped.validate.performValidation(tableAttribute)
        XCTAssertEqual(attributeValidator.timesCalled, 1)
        XCTAssertEqual(attributeValidator.lastParameter, tableAttribute)
        let copy = table.projectedValue
        let wrapped2 = copy.wrappedValue
        XCTAssertEqual(wrapped2.label, attribute.label)
        XCTAssertEqual(wrapped2.type, attribute.type)
        try wrapped2.validate.performValidation(tableAttribute)
        XCTAssertEqual(attributeValidator.timesCalled, 2)
        XCTAssertEqual(attributeValidator.parameters, [tableAttribute, tableAttribute])
    }

    /// Test the validation fails when a column value is incorrect.
    func testColumnValidatorThrowsForInvalidColumn() {
        let table = TableProperty(label: "Table", columns: columns) { _ in
            attributeValidator
        }
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(false), .line("test")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(tableAttribute))
    }

    /// Test the validation fails when the second column value is incorrect.
    func testColumnValidatorThrowsForInvalidSecondColumn() {
        let table = TableProperty(label: "Table", columns: columns) { _ in
            attributeValidator
        }
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(tableAttribute))
    }

    /// Test the validation fails when both column values are incorrect.
    func testColumnValidatorThrowsForBothColumnsInvalid() {
        let table = TableProperty(label: "Table", columns: columns) { _ in
            attributeValidator
        }
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(false), .line("")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(tableAttribute))
    }

    /// Test the validation fails when both column values are incorrect in the second row.
    func testColumnValidatorThrowsForBothColumnsInvalidSecondRow() {
        let table = TableProperty(label: "Table", columns: columns) { _ in
            attributeValidator
        }
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test")], [.bool(false), .line("")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(tableAttribute))
    }

    /// Test the validator checks the row lengths by default.
    func testColumnLengthValidationRule() {
        let table = TableProperty(label: "Table", columns: columns)
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        let validator = table.wrappedValue.validate
        XCTAssertNoThrow(try validator.performValidation(tableAttribute))
        let attribute2 = Attribute.block(BlockAttribute.table(
            [[.bool(true)]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line)
            ]
        ))
        XCTAssertThrowsError(try validator.performValidation(attribute2))
    }

    /// Test that makes sure validator still works when updating the columns.
    func testValidatorStillWorksWhenColumnsAreAdded() {
        var table = TableProperty(label: "Table", columns: columns)
        let tableAttribute = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line),
                BlockAttributeType.TableColumn(name: "C", type: .integer)
            ]
        ))
        XCTAssertNoThrow(try table.wrappedValue.validate.performValidation(tableAttribute))
        table = TableProperty(
            label: "Table",
            columns: columns + [TableColumn(label: "C", type: .integer, validator: AnyValidator())]
        )
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(tableAttribute))
        let attribute2 = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test"), .integer(5)]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line),
                BlockAttributeType.TableColumn(name: "C", type: .integer)
            ]
        ))
        XCTAssertNoThrow(try table.wrappedValue.validate.performValidation(attribute2))
        let attribute3 = Attribute.block(BlockAttribute.table(
            [[.bool(true), .line("test"), .integer(5), .line("hello")]],
            columns: [
                BlockAttributeType.TableColumn(name: "A", type: .bool),
                BlockAttributeType.TableColumn(name: "B", type: .line),
                BlockAttributeType.TableColumn(name: "C", type: .integer)
            ]
        ))
        XCTAssertThrowsError(try table.wrappedValue.validate.performValidation(attribute3))
    }

}
