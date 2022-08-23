// MakeUnavailableTriggerTests.swift 
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

/// Test class for MakeUnavailableTrigger.
final class MakeUnavailableTriggerTests: XCTestCase {

    /// The field to make unavailable.
    let field = Field(name: "Gender", type: .enumerated(validValues: ["Male", "Female", "Other"]))

    /// A path to a person object.
    let personPath = Path(Person.self)

    /// A path to the fields array.
    var fieldsPath: Path<Person, [Field]> {
        Path(path: \Person.fields, ancestors: [AnyPath(personPath)])
    }

    // swiftlint:disable implicitly_unwrapped_optional

    /// The trigger under test.
    var trigger: MakeUnavailableTrigger<Path<Person, [Field]>, Path<Person, [Field]>>!

    // swiftlint:enable implicitly_unwrapped_optional

    /// The default fields.
    var fields: [Field] {
        [Field(name: "Name", type: .line), Field(name: "Age", type: .integer), field]
    }

    /// The default attributes.
    let attributes: [String: Attribute] = [
        "Name": .line("Test Person"),
        "Age": .integer(21),
        "Gender": .enumerated("Male", validValues: ["Male", "Female", "Other"])
    ]

    /// A path to the attributes dictionary.
    var attributesPath: Path<Person, [String: Attribute]> {
        Path(path: \Person.attributes, ancestors: [AnyPath(personPath)])
    }

    /// The test data.
    var person: Person {
        Person(fields: fields, attributes: attributes)
    }

    /// Setup the trigger before every test.
    override func setUp() {
        trigger = MakeUnavailableTrigger(field: field, source: fieldsPath, fields: fieldsPath)
    }

    /// Test init.
    func testInit() {
        XCTAssertEqual(trigger.field, field)
        XCTAssertEqual(trigger.path, AnyPath(fieldsPath))
        XCTAssertEqual(trigger.source, fieldsPath)
        XCTAssertEqual(trigger.fields, fieldsPath)
    }

    /// Test isTriggerForPath returns true when the path points to the root object.
    func testIsPathSource() {
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(fieldsPath), in: person))
    }

    /// Test isTriggerForPath returns true when the path points to a child of the root object.
    func testIsPathChild() {
        let field0 = Path(path: \Person.fields[0], ancestors: [AnyPath(personPath), AnyPath(fieldsPath)])
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(field0), in: person))
    }

    /// Test isTriggerForPath returns false for invalid path.
    func testIsPathOther() {
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(attributesPath), in: person))
    }

    /// Test trigger correctly removes field.
    func testRemovesFieldWhenPerformingTrigger() {
        var person = person
        let expectedFields = Array(person.fields.dropLast())
        let expectedAttributes = person.attributes
        let result = trigger.performTrigger(&person, for: AnyPath(personPath))
        XCTAssertEqual(result, .success(true))
        XCTAssertEqual(person.fields, expectedFields)
        XCTAssertEqual(person.attributes, expectedAttributes)
    }

    /// Test that the fieds remain the same and the trigger returns success with false.
    func testEmptyFieldWhenPerformingTrigger() {
        var person = person
        person.fields = Array(person.fields.dropLast())
        let expectedFields = person.fields
        let expectedAttributes = person.attributes
        let result = trigger.performTrigger(&person, for: AnyPath(personPath))
        XCTAssertEqual(result, .success(false))
        XCTAssertEqual(person.fields, expectedFields)
        XCTAssertEqual(person.attributes, expectedAttributes)
    }

}
