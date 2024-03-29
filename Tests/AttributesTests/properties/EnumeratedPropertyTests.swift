// ComplexPropertyTests.swift 
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

/// Test class for EnumeratedProperty.
final class EnumeratedPropertyTests: XCTestCase, PropertyTestable {

    /// Testing String.
    typealias PropertyType = String

    /// The valid values for the enumeration.
    let validValues: Set<String> = ["1", "2"]

    /// Type is Set<String>.
    let type = AttributeType.enumerated(validValues: ["1", "2"])

    /// Path to Set<String>.
    var path: Path<Attribute, PropertyType> {
        Path(path: \Attribute.enumeratedValue, ancestors: [AnyPath(Path(Attribute.self))])
    }

    // swiftlint:disable implicitly_unwrapped_optional

    /// A mock validator.
    var validator: MockValidator<ReadOnlyPath<Attribute, PropertyType>>!

    // swiftlint:enable implicitly_unwrapped_optional

    /// Set validator every test.
    override func setUp() {
        setup()
    }

    /// Test init
    func testInit() {
        let property = EnumeratedProperty(label: label, validValues: validValues, validation: builder)
        XCTAssertEqual(property.wrappedValue, schema)
        XCTAssertEqual(property.projectedValue.wrappedValue, schema)
    }

    /// Test init without builder.
    func testInitWithoutBuilder() {
        let property = EnumeratedProperty(label: label, validValues: validValues)
        XCTAssertEqual(property.wrappedValue.label, schema.label)
        XCTAssertEqual(property.wrappedValue.type, schema.type)
        XCTAssertEqual(property.projectedValue.wrappedValue.label, schema.label)
        XCTAssertEqual(property.projectedValue.wrappedValue.type, schema.type)
    }

    /// Test init from wrapped value.
    func testWrappedValueInit() {
        let property = EnumeratedProperty(wrappedValue: schema)
        XCTAssertEqual(property.wrappedValue, schema)
        XCTAssertEqual(property.projectedValue.wrappedValue, schema)
    }

    /// Test validator passes for value that exists within the `validValues` Set.
    func testValidatorPassesWithValidValue() {
        let property = EnumeratedProperty(label: label, validValues: validValues)
        XCTAssertNoThrow(
            try property.wrappedValue.validate.performValidation(.enumerated("1", validValues: validValues))
        )
    }

    /// Test validator throws an error when the value does not exist within the `validValues` Set.
    func testValidatorFailsWithInvalidValue() {
        let property = EnumeratedProperty(label: label, validValues: validValues)
        XCTAssertThrowsError(
            try property.wrappedValue.validate.performValidation(.enumerated("abc", validValues: validValues))
        )
    }

    /// Test validator works when valid values are mutated in wrapper.
    func testValidatorWorksWhenUpdatingValidValues() {
        var property = EnumeratedProperty(label: label, validValues: validValues)
        XCTAssertNoThrow(
            try property.wrappedValue.validate.performValidation(.enumerated("1", validValues: validValues))
        )
        property.update(validValues: ["3", "4"])
        XCTAssertThrowsError(
            try property.wrappedValue.validate.performValidation(.enumerated("1", validValues: validValues))
        )
    }

}
