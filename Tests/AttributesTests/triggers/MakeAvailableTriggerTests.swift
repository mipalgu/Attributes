// MakeAvailableTriggerTests.swift 
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

/// Test class for MakeAvailableTrigger.
final class MakeAvailableTriggerTests: XCTestCase {

    /// Person test data.
    let person = Person(
        fields: [Field(name: "Name", type: .line), Field(name: "Age", type: .integer)],
        attributes: ["Name": .line("Test Person"), "Age": .integer(21)]
    )

    /// A path to the person.
    let personPath = ReadOnlyPath(Person.self)

    /// The fields in the Person struct.
    var fieldsPath: Path<Person, [Field]> {
        Path(path: \Person.fields, ancestors: [AnyPath(personPath)])
    }

    /// A path to the attributes.
    var attributesPath: Path<Person, [String: Attribute]> {
        Path(path: \Person.attributes, ancestors: [AnyPath(personPath)])
    }

    /// The new field to add to the person struct.
    let newField = Field(name: "Gender", type: .enumerated(validValues: ["Male", "Female", "Other"]))

    /// The fields to place the newField after (priority order). 
    let order = ["Age", "Name"]

    // swiftlint:disable implicitly_unwrapped_optional

    /// The trigger under test.
    var trigger: MakeAvailableTrigger<
        ReadOnlyPath<Person, Person>,
        Path<Person, [Field]>,
        Path<Person, [String: Attribute]>
    >!

    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        trigger = MakeAvailableTrigger(
            field: newField,
            after: order,
            source: personPath,
            fields: fieldsPath,
            attributes: attributesPath
        )
    }

    /// Test initialiser.
    func testInit() {
        XCTAssertEqual(trigger.field, newField)
        XCTAssertEqual(trigger.attributes, attributesPath)
        XCTAssertEqual(trigger.fields, fieldsPath)
        XCTAssertEqual(trigger.order, order)
        XCTAssertEqual(trigger.path, AnyPath(personPath))
        XCTAssertEqual(trigger.source, personPath)
    }

    /// Test isTriggerForPath returns true when the path points to the root object.
    func testIsPathRoot() {
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(personPath), in: person))
    }

    /// Test isTriggerForPath returns true when the path points to a child of the root object.
    func testIsPathChild() {
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(attributesPath), in: person))
    }

    /// Test isTriggerForPath returns false for invalid path.
    func testIsPathOther() {
        let fieldPath = Path(path: \Person.fields[0], ancestors: [AnyPath(personPath), AnyPath(fieldsPath)])
        let newPath = Path(
            path: \Person.fields[0].name,
            ancestors: [AnyPath(personPath), AnyPath(fieldsPath), AnyPath(fieldPath)]
        )
        let newTrigger = MakeAvailableTrigger(
            field: newField,
            after: order,
            source: attributesPath,
            fields: fieldsPath,
            attributes: attributesPath
        )
        XCTAssertFalse(newTrigger.isTriggerForPath(AnyPath(newPath), in: person))
    }

    /// Test the trigger returns .success(false) for a field that is already available.
    func testPerformTriggerForFieldThatExists() {
        var person = person
        person.fields.append(
            Field(name: "Gender", type: .enumerated(validValues: ["Male", "Female", "Other"]))
        )
        let result = trigger.performTrigger(&person, for: AnyPath(personPath))
        XCTAssertEqual(result, .success(false))
    }

    /// Perform trigger for new field that has an existing value in the attributes dictionary,
    func testPerformTriggerNewFieldWithValue() {
        var person = person
        let validValues: Set<String> = ["Male", "Female", "Other"]
        person.attributes["Gender"] = .enumerated("Male", validValues: validValues)
        let expectedAttributes = person.attributes
        let expectedFields = [
            Field(name: "Name", type: .line),
            Field(name: "Gender", type: .enumerated(validValues: validValues)),
            Field(name: "Age", type: .integer)
        ]
        let result = trigger.performTrigger(&person, for: AnyPath(personPath))
        XCTAssertEqual(result, .success(true))
        XCTAssertEqual(person.fields, expectedFields)
        XCTAssertEqual(person.attributes, expectedAttributes)
    }

    /// Perform trigger for new field that has no value in the attributes dictionary.
    func testPerformTriggerNewFieldWithoutValue() {
        var person = person
        let validValues: Set<String> = ["Male", "Female", "Other"]
        var expectedAttributes = person.attributes
        expectedAttributes["Gender"] = .enumerated("Female", validValues: validValues)
        let expectedFields = [
            Field(name: "Name", type: .line),
            Field(name: "Gender", type: .enumerated(validValues: validValues)),
            Field(name: "Age", type: .integer)
        ]
        let result = trigger.performTrigger(&person, for: AnyPath(personPath))
        XCTAssertEqual(result, .success(true))
        XCTAssertEqual(person.fields, expectedFields)
        XCTAssertEqual(person.attributes, expectedAttributes)
    }

}
