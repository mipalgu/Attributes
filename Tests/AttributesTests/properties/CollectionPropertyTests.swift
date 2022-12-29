// CollectionPropertyTests.swift 
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

/// Test class for ``CollectionProperty``.
final class CollectionPropertyTests: XCTestCase {

    /// Test wrapped initialiser sets wrappedValue correctly.
    func testWrappedInitialiser() throws {
        let validator = NullValidator<Attribute>()
        let label = "Property"
        let type = AttributeType.collection(type: .bool)
        let schemaAttribute = SchemaAttribute(
            label: label, type: type, validate: AnyValidator(validator)
        )
        let property = CollectionProperty(wrappedValue: schemaAttribute)
        let value = true
        let attribute = Attribute.collection(bools: [value])
        let wrapped = property.wrappedValue
        XCTAssertEqual(wrapped.label, label)
        XCTAssertEqual(wrapped.type, type)
        try wrapped.validate.performValidation(attribute)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, .collection(bools: [value]))
        let wrapped2 = property.projectedValue.wrappedValue
        XCTAssertEqual(wrapped2.label, label)
        XCTAssertEqual(wrapped2.type, type)
        try wrapped2.validate.performValidation(attribute)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.parameters, [.collection(bools: [value]), .collection(bools: [value])])
    }

    /// Test bool initialiser.
    func testBool() throws {
        let validator = NullValidator<Bool>()
        let property = CollectionProperty(
            label: "Property", bools: ValidatorFactory.required().push { _ in validator }
        )
        let value = true
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(bools: [value]),
            type: .collection(type: .bool)
        )
    }

    /// Test Int initialiser.
    func testInts() throws {
        let validator = NullValidator<Int>()
        let property = CollectionProperty(
            label: "Property", integers: ValidatorFactory.required().push { _ in validator }
        )
        let value = 5
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(integers: [value]),
            type: .collection(type: .integer)
        )
    }

    /// Test float initialiser.
    func testFloat() throws {
        let validator = NullValidator<Double>()
        let property = CollectionProperty(
            label: "Property", floats: ValidatorFactory.required().push { _ in validator }
        )
        let value = 5.0
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(floats: [value]),
            type: .collection(type: .float)
        )
    }

    /// Test line initialiser.
    func testLine() throws {
        let validator = NullValidator<String>()
        let property = CollectionProperty(
            label: "Property", lines: ValidatorFactory.required().push { _ in validator }
        )
        let value = "Hello World!"
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(lines: [value]),
            type: .collection(type: .line)
        )
    }

    /// Test expression initialiser.
    func testExpression() throws {
        let validator = NullValidator<String>()
        let property = CollectionProperty(
            label: "Property", expressions: ValidatorFactory.required().push { _ in validator }, language: .c
        )
        let value = "int x;"
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(expressions: [value], language: .c),
            type: .collection(type: .expression(language: .c))
        )
    }

    /// Test enumeration initialiser.
    func testEnumeration() throws {
        let validator = NullValidator<String>()
        let validValues: Set<String> = ["int x;", "abc", "def"]
        let property = CollectionProperty(
            label: "Property",
            enumerations: ValidatorFactory.required().push { _ in validator },
            validValues: validValues
        )
        let value = "int x;"
        try doTestCase(
            validator: validator,
            property: property,
            value: value,
            attribute: .collection(enumerated: [value], validValues: validValues),
            type: .collection(type: .enumerated(validValues: validValues))
        )
    }

    /// Test validator uses default enumerated rule.
    func testEnumerationValidation() {
        let validValues: Set<String> = ["int x;", "abc", "def"]
        let property = CollectionProperty(
            label: "Property",
            enumerations: ValidatorFactory.required(),
            validValues: validValues
        )
        let validator = property.wrappedValue.validate
        XCTAssertNoThrow(
            try validator.performValidation(
                .collection(enumerated: ["int x;", "abc"], validValues: validValues)
            )
        )
        XCTAssertThrowsError(
            try validator.performValidation(
                .collection(enumerated: ["int x;", "abc", "cc", "def"], validValues: validValues)
            )
        )
    }

    /// Perform test case for a CollectionProperty.
    /// - Parameters:
    ///   - validator: The validator used by the property.
    ///   - label: The name of the property.
    ///   - property: The property to test.
    ///   - value: The value to validate.
    ///   - attribute: The attribute value to validate.
    ///   - type: The type of the collection.
    private func doTestCase<T>(
        validator: NullValidator<T>,
        label: String = "Property",
        property: CollectionProperty,
        value: T,
        attribute: Attribute,
        type: AttributeType
    ) throws where T: Equatable {
        let wrapped = property.wrappedValue
        XCTAssertEqual(wrapped.label, label)
        XCTAssertEqual(wrapped.type, type)
        try wrapped.validate.performValidation(attribute)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, value)
        let wrapped2 = property.projectedValue.wrappedValue
        XCTAssertEqual(wrapped2.label, label)
        XCTAssertEqual(wrapped2.type, type)
        try wrapped2.validate.performValidation(attribute)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.parameters, [value, value])
    }

}
