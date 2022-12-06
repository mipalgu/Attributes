// AttributableTests.swift
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

/// Test class for ``Attributable`` default implementations.
final class AttributableTests: XCTestCase {

    /// The persons properties.
    let properties: [SchemaAttribute] = [
        SchemaAttribute(label: "first_name", type: .line),
        SchemaAttribute(label: "last_name", type: .line),
        SchemaAttribute(label: "age", type: .integer),
        SchemaAttribute(label: "is_male", type: .bool)
    ]

    /// Path from the data.
    let path = Path(EmptyModifiable.self)

    /// The person under test.
    var person = AttributablePerson()

    /// Initialise the person before every test.
    override func setUp() {
        let personFields = [
            Field(name: "first_name", type: .line),
            Field(name: "last_name", type: .line),
            Field(name: "age", type: .integer),
            Field(name: "is_male", type: .bool)
        ]
        let modifiable = EmptyModifiable(
            attributes: [
                AttributeGroup(
                    name: "Details",
                    fields: [Field(name: "person", type: .complex(layout: personFields))],
                    attributes: [
                        "person": .complex(
                            [
                                "first_name": .line("John"),
                                "last_name": .line("Smith"),
                                "age": .integer(21),
                                "is_male": .bool(true)
                            ],
                            layout: personFields
                        )
                    ],
                    metaData: [:]
                )
            ],
            metaData: [],
            errorBag: ErrorBag()
        )
        person = AttributablePerson(data: modifiable)
    }

    /// Test properties getter matches expected.
    func testProperties() {
        let sortedProperties = properties.sorted()
        let personProperties = person.properties.sorted()
        XCTAssertEqual(sortedProperties.count, personProperties.count)
        let indices = sortedProperties.count > personProperties.count ? sortedProperties.indices :
            personProperties.indices
        indices.forEach {
            let p0 = sortedProperties[$0]
            let p1 = personProperties[$0]
            XCTAssertEqual(p0.label, p1.label)
            XCTAssertEqual(p0.type, p1.type)
        }
    }

    /// Test available getter matches expected.
    func testAvailable() {
        XCTAssertEqual(person.available, Set(properties.map(\.label)))
    }

    /// Test default trigger performs no function.
    func testNullTriggerByDefault() throws {
        let before = person
        XCTAssertFalse(try person.triggers.performTrigger(&person.data, for: AnyPath(path)).get())
        XCTAssertEqual(person, before)
    }

    /// Test group validator passes by default.
    func testNullGroupValidatorByDefault() throws {
        guard let attribute = person.data.attributes[0].attributes["person"] else {
            XCTFail("Attribute not set in person.")
            return
        }
        XCTAssertNoThrow(try person.groupValidation.performValidation(attribute))
    }

    /// Test root validator passes by default.
    func testRootValidatorPassedByDefault() throws {
        XCTAssertNoThrow(try person.rootValidation.performValidation(person.data))
    }

    /// Test properties validator passes by default.
    func testPropertiesValidatorPassesByDefault() throws {
        guard let attribute = person.data.attributes[0].attributes["person"] else {
            XCTFail("Attribute not set in person.")
            return
        }
        XCTAssertNoThrow(try person.propertiesValidator.performValidation(attribute))
    }

    /// Test additional properties has no effect on default validation.
    func testPropertiesValidatorPassesForUnknownAttribute() throws {
        guard let attribute = person.data.attributes[0].attributes["person"] else {
            XCTFail("Attribute not set in person.")
            return
        }
        var newAttribute = attribute.complexValue
        newAttribute["unknown"] = .line("Fake attribute")
        person.data.attributes[0].attributes["person"] = .complex(
            newAttribute, layout: attribute.complexFields
        )
        XCTAssertNoThrow(try person.propertiesValidator.performValidation(attribute))
    }

    /// Test path returns correct path.
    func testPathReturnsCorrectSearchablePath() {
        let path = person.path(for: SchemaAttribute(label: "first_name", type: .line))
        let expected = Path(EmptyModifiable.self)
            .attributes[0].attributes["person"].wrappedValue.complexValue["first_name"].wrappedValue
        XCTAssertTrue(path.isAncestorOrSame(of: AnyPath(expected), in: person.data))
        let paths = path.paths(in: person.data)
        XCTAssertEqual(paths.count, 1)
        guard let first = paths.first else {
            XCTFail("Invalid paths")
            return
        }
        let result = person.data[keyPath: first.keyPath]
        let expectedData = person.data[keyPath: expected.keyPath]
        XCTAssertEqual(result, expectedData)
    }

    /// Test `findProperty` returns correct property.
    func testFindProperty() {
        let path = AnyPath(
            Path(EmptyModifiable.self)
                .attributes[0].attributes["person"].wrappedValue.complexValue["first_name"].wrappedValue
        )
        let property = person.findProperty(path: path, in: person.data)
        XCTAssertEqual(property, SchemaAttribute(label: "first_name", type: .line))
    }

    /// Test `findProperty` returns nil for invalid property.
    func testFindPropertyReturnsNil() {
        let path = AnyPath(
            Path(EmptyModifiable.self)
                .attributes[0].attributes["person"].wrappedValue.complexValue["unknown"].wrappedValue
        )
        XCTAssertNil(person.findProperty(path: path, in: person.data))
    }

    /// Test `findProperty` returns nil for block property.
    func testFindPropertyReturnsNilForBlock() {
        let path = AnyPath(
            Path(EmptyModifiable.self)
                .attributes[0].attributes["person"].wrappedValue
        )
        XCTAssertNil(person.findProperty(path: path, in: person.data))
    }

    /// Test whenChanged creates correct trigger.
    func testWhenChangedPerformsCallback() throws {
        let trigger = person.WhenChanged(SchemaAttribute(label: "first_name", type: .line)).makeUnavailable(
            field: Field(name: "last_name", type: .line),
            fields: Path(EmptyModifiable.self).attributes[0].attributes["person"].wrappedValue.complexFields
        )
        XCTAssertTrue(
            try trigger.performTrigger(&person.data, for: AnyPath(Path(EmptyModifiable.self))).get()
        )
        guard let fields = person.data.attributes.first?.attributes["person"]?.complexFields else {
            XCTFail("Cannot get fields")
            return
        }
        XCTAssertEqual(
            fields,
            [
                Field(name: "first_name", type: .line),
                Field(name: "age", type: .integer),
                Field(name: "is_male", type: .bool)
            ]
        )
    }

}
