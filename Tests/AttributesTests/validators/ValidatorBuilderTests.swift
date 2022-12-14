// ValidatorBuilderTests.swift 
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

/// Test class for ``ValidatorBuilder``.
final class ValidatorBuilderTests: XCTestCase {

    /// The builder under test.
    let builder = ValidatorBuilder<Person>()

    /// Null person.
    let person = Person(fields: [], attributes: [:])

    /// Mock validators.
    var validators: [NullValidator<Person>] = [
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>(),
        NullValidator<Person>()
    ]

    /// Initialise the validators before every test.
    override func setUp() {
        validators = [
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>(),
            NullValidator<Person>()
        ]
    }

    /// Test that `makeValidator` correctly creates an equivalent validator.
    func testMakeValidator() throws {
        let validator: AnyValidator<Person> = builder.makeValidator {
            let vs: [AnyValidator<Person>] = validators.map {
                AnyValidator<Person>($0)
            }
            return vs
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 12)
    }

    /// Test `buildBlock` creates a null Validator when none are specified.
    func testBuilding0() throws {
        let validator = builder.buildBlock()
        try validator.performValidation(person)
        assertValidators(numValidators: 0)
    }

    /// Test buildBlock method.
    func testBuilding1() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 1)
    }

    /// Test buildBlock method.
    func testBuilding2() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 2)
    }

    /// Test buildBlock method.
    func testBuilding3() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 3)
    }

    /// Test buildBlock method.
    func testBuilding4() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 4)
    }

    /// Test buildBlock method.
    func testBuilding5() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 5)
    }

    /// Test buildBlock method.
    func testBuilding6() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 6)
    }

    /// Test buildBlock method.
    func testBuilding7() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 7)
    }

    /// Test buildBlock method.
    func testBuilding8() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
            validators[7]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 8)
    }

    /// Test buildBlock method.
    func testBuilding9() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
            validators[7]
            validators[8]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 9)
    }

    /// Test buildBlock method.
    func testBuilding10() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
            validators[7]
            validators[8]
            validators[9]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 10)
    }

    /// Test buildBlock method.
    func testBuilding11() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
            validators[7]
            validators[8]
            validators[9]
            validators[10]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 11)
    }

    /// Test buildBlock method.
    func testBuilding12() throws {
        @ValidatorBuilder<Person>
        var validator: AnyValidator<Person> {
            validators[0]
            validators[1]
            validators[2]
            validators[3]
            validators[4]
            validators[5]
            validators[6]
            validators[7]
            validators[8]
            validators[9]
            validators[10]
            validators[11]
        }
        try validator.performValidation(person)
        assertValidators(numValidators: 12)
    }

    /// Check that the right validators are called when built by a validator builder.
    /// - Parameter numValidators: The number of validators that should have been called.
    private func assertValidators(numValidators: Int) {
        validators.enumerated().forEach {
            guard $0 < numValidators else {
                XCTAssertEqual($1.timesCalled, 0)
                XCTAssertNil($1.lastParameter)
                return
            }
            XCTAssertEqual($1.timesCalled, 1)
            XCTAssertEqual($1.lastParameter, person)
        }
    }

}
