// AttributableTriggerTests.swift
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

/// Test class for ``Attributable`` trigger functions.
final class AttributableTriggerTests: XCTestCase {

    /// The fields in the person complex attribute.
    let personFields = [
        Field(name: "first_name", type: .line),
        Field(name: "last_name", type: .line),
        Field(name: "is_male", type: .bool)
    ]

    /// The persons properties.
    let properties: [SchemaAttribute] = [
        SchemaAttribute(label: "first_name", type: .line),
        SchemaAttribute(label: "last_name", type: .line),
        SchemaAttribute(label: "age", type: .integer),
        SchemaAttribute(label: "is_male", type: .bool),
        SchemaAttribute(
            label: "friends",
            type: .table(columns: [("first_name", .line), ("last_name", .line)])
        )
    ]

    /// Path from the data.
    let path = Path(EmptyModifiable.self)

    /// The person under test.
    lazy var person = AttributablePerson(
        data: EmptyModifiable(
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
                                "is_male": .bool(true),
                                "friends": .table(
                                    [[.line("Jane"), .line("Smith")]],
                                    columns: [("first_name", .line), ("last_name", .line)]
                                )
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
    )

    /// Initialise the person before every test.
    override func setUp() {
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
                                "is_male": .bool(true),
                                "friends": .table(
                                    [[.line("Jane"), .line("Smith")]],
                                    columns: [("first_name", .line), ("last_name", .line)]
                                )
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
                Field(name: "is_male", type: .bool)
            ]
        )
    }

    /// Test fields become available when a bool is true.
    func testWhenTrueMakeAvailable() throws {
        let trigger = person.WhenTrue(
            SchemaAttribute(label: "is_male", type: .bool),
            makeAvailable: SchemaAttribute(label: "age", type: .integer)
        )
        XCTAssertTrue(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        guard let fields = person.data.attributes.first?.attributes["person"]?.complexFields else {
            XCTFail("Cannot get fields")
            return
        }
        let expectedFields = [Field(name: "age", type: .integer)] + personFields
        XCTAssertEqual(fields, expectedFields)
    }

    /// Checks whether the WhenTrue trigger works when a false value is present.
    func testWhenTrueMakeAvailableWithFalseValue() throws {
        let trigger = person.WhenTrue(
            SchemaAttribute(label: "is_male", type: .bool),
            makeAvailable: SchemaAttribute(label: "age", type: .integer)
        )
        guard var attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        attribute["is_male"] = .bool(false)
        person.data.attributes[0].attributes["person"] = .complex(attribute, layout: personFields)
        XCTAssertFalse(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexValue, attribute)
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexFields, personFields)
    }

    /// Test fields become available when a bool is false.
    func testWhenFalseMakeAvailable() throws {
        let trigger = person.WhenFalse(
            SchemaAttribute(label: "is_male", type: .bool),
            makeAvailable: SchemaAttribute(label: "age", type: .integer)
        )
        guard var attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        attribute["is_male"] = .bool(false)
        person.data.attributes[0].attributes["person"] = .complex(attribute, layout: personFields)
        XCTAssertTrue(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        guard let fields = person.data.attributes.first?.attributes["person"]?.complexFields else {
            XCTFail("Cannot get fields")
            return
        }
        let expectedFields = [Field(name: "age", type: .integer)] + personFields
        XCTAssertEqual(fields, expectedFields)
    }

    /// Checks whether the WhenFalse trigger works when a true value is present.
    func testWhenFalseMakeAvailableWithTrueValue() throws {
        let trigger = person.WhenFalse(
            SchemaAttribute(label: "is_male", type: .bool),
            makeAvailable: SchemaAttribute(label: "age", type: .integer)
        )
        guard let attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        XCTAssertFalse(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexValue, attribute)
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexFields, personFields)
    }

    /// Test fields become unavailable when a bool is true.
    func testWhenTrueMakeUnavailable() throws {
        let trigger = person.WhenTrue(
            SchemaAttribute(label: "is_male", type: .bool),
            makeUnavailable: SchemaAttribute(label: "first_name", type: .line)
        )
        XCTAssertTrue(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        guard let fields = person.data.attributes.first?.attributes["person"]?.complexFields else {
            XCTFail("Cannot get fields")
            return
        }
        let expectedFields = [Field(name: "last_name", type: .line), Field(name: "is_male", type: .bool)]
        XCTAssertEqual(fields, expectedFields)
    }

    /// Checks whether the WhenTrue trigger works when a false value is present.
    func testWhenTrueMakeUnavailableWithFalseValue() throws {
        let trigger = person.WhenTrue(
            SchemaAttribute(label: "is_male", type: .bool),
            makeUnavailable: SchemaAttribute(label: "first_name", type: .line)
        )
        guard var attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        attribute["is_male"] = .bool(false)
        person.data.attributes[0].attributes["person"] = .complex(attribute, layout: personFields)
        XCTAssertFalse(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexValue, attribute)
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexFields, personFields)
    }

    /// Test fields become unavailable when a bool is false.
    func testWhenFalseMakeUnavailable() throws {
        let trigger = person.WhenFalse(
            SchemaAttribute(label: "is_male", type: .bool),
            makeUnavailable: SchemaAttribute(label: "first_name", type: .line)
        )
        guard var attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        attribute["is_male"] = .bool(false)
        person.data.attributes[0].attributes["person"] = .complex(attribute, layout: personFields)
        XCTAssertTrue(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        guard let fields = person.data.attributes.first?.attributes["person"]?.complexFields else {
            XCTFail("Cannot get fields")
            return
        }
        let expectedFields = [Field(name: "last_name", type: .line), Field(name: "is_male", type: .bool)]
        XCTAssertEqual(fields, expectedFields)
    }

    /// Checks whether the WhenFalse trigger works when a true value is present.
    func testWhenFalseMakeUnavailableWithTrueValue() throws {
        let trigger = person.WhenFalse(
            SchemaAttribute(label: "is_male", type: .bool),
            makeUnavailable: SchemaAttribute(label: "first_name", type: .line)
        )
        guard let attribute = person.data.attributes[0].attributes["person"]?.complexValue else {
            XCTFail("Cannot get attribute.")
            return
        }
        XCTAssertFalse(
            try trigger.performTrigger(
                &person.data,
                for: AnyPath(
                    Path(EmptyModifiable.self)
                        .attributes[0]
                        .attributes["person"]
                        .wrappedValue
                        .blockAttribute
                        .complexValue["is_male"]
                        .wrappedValue
                )
            )
            .get()
        )
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexValue, attribute)
        XCTAssertEqual(person.data.attributes.first?.attributes["person"]?.complexFields, personFields)
    }

    /// Test whenChanged function for table.
    func testWhenChangedTable() throws {
        let path = Path([LineAttribute].self)
        let trigger = person.WhenChanged(
            path,
            in: SchemaAttribute(
                label: "friends",
                type: .table(columns: [("first_name", .line), ("last_name", .line)])
            )
        ) { _ in
            .success(false)
        }
        XCTAssertFalse(
            try trigger.performTrigger(&person.data, for: AnyPath(Path(EmptyModifiable.self))).get()
        )
    }

}
