// SchemaProtocolTests.swift
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

/// Test class for ``SchemaProtocol`` default implementations.
final class SchemaProtocolTests: XCTestCase {

    /// The fields in the person complex attribute.
    let personFields = [
        Field(name: "first_name", type: .line),
        Field(name: "last_name", type: .line),
        Field(name: "age", type: .integer),
        Field(name: "is_male", type: .bool),
        Field(name: "friends", type: .table(columns: [("first_name", .line), ("last_name", .line)]))
    ]

    /// Test data.
    lazy var data = EmptyModifiable(
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

    /// The schema under test.
    var schema = TestSchema()

    /// Reset schema before every test.
    override func setUp() {
        data = EmptyModifiable(
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
                ),
                AttributeGroup(name: "Group 2")
            ],
            metaData: [],
            errorBag: ErrorBag()
        )
        schema = TestSchema()
    }

    /// Test groups gets property groups correctly.
    func testGroups() {
        let groups = schema.groups.compactMap {
            $0.base as? MockGroup
        }
        let expected = [schema.mock1, schema.mock2]
        XCTAssertEqual(groups, expected)
    }

    /// Test trigger gets triggers in groups.
    func testTrigger() throws {
        let path = AnyPath(Path(EmptyModifiable.self))
        XCTAssertFalse(try schema.trigger.performTrigger(&data, for: path).get())
        let trigger1 = schema.mock1.mockTriggers
        let trigger2 = schema.mock2.mockTriggers
        XCTAssertEqual(trigger1.timesCalled, 1)
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger1.pathPassed, path)
        XCTAssertEqual(trigger2.pathPassed, path)
        XCTAssertEqual(trigger1.rootPassed, data)
        XCTAssertEqual(trigger2.rootPassed, data)
    }

    /// Test makeValidator uses all validators within all groups.
    func testMakeValidator() throws {
        let validator = schema.makeValidator(root: data)
        try validator.performValidation(data)
        [schema.mock1, schema.mock2].enumerated().forEach {
            let groupValidator = $1.groupValidator
            let rootValidator = $1.rootValidator
            let propertyValidator = $1.propertyValidator
            XCTAssertEqual(groupValidator.timesCalled, 1)
            XCTAssertEqual(groupValidator.lastParameter, data.attributes[$0])
            XCTAssertEqual(rootValidator.timesCalled, 1)
            XCTAssertEqual(rootValidator.lastParameter, data)
            XCTAssertEqual(propertyValidator.timesCalled, 1)
            XCTAssertEqual(propertyValidator.lastParameter, data.attributes[$0])
        }
    }

}
