// ValidatorPushTests.swift 
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

/// Test class for ``_PathValidator`` default implementations.
final class ValidatorPushTests: XCTestCase {

    /// A helper validator.
    var validator0 = NullValidator<Person>()

    /// A helper validator.
    var validator1 = NullValidator<Person>()

    /// A person to validate.
    let person = Person(fields: [], attributes: [:])

    /// Initialise the validators before every test case.
    override func setUp() {
        validator0 = NullValidator<Person>()
        validator1 = NullValidator<Person>()
    }

    /// Test push function adds new validator onto stack.
    func testPush() throws {
        let validator = Validator(path: Path(Person.self).readOnly)
        let pushedValidator = validator.push { root, _ in
            try self.validator0.performValidation(root)
        }
        try pushedValidator.performValidation(person)
        XCTAssertEqual(validator0.timesCalled, 1)
        XCTAssertEqual(validator0.lastParameter, person)
        XCTAssertEqual(validator1.timesCalled, 0)
        XCTAssertNil(validator1.lastParameter)
    }

    /// Test push function adds both validators onto stack.
    func testPushTwoValidators() throws {
        let validator = Validator(path: Path(Person.self).readOnly).push { root, _ in
            try self.validator0.performValidation(root)
        }
        .push { root, _ in
            try self.validator1.performValidation(root)
        }
        try validator.performValidation(person)
        XCTAssertEqual(validator0.timesCalled, 1)
        XCTAssertEqual(validator0.lastParameter, person)
        XCTAssertEqual(validator1.timesCalled, 1)
        XCTAssertEqual(validator1.lastParameter, person)
    }

}
