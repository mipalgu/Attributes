// WhenChangedTests.swift 
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

/// Test class for ``WhenChanged``.
final class WhenChangedTests: XCTestCase {

    /// A path to the x-property of a point.
    let path = Path(Point.self).x

    /// A mock trigger.
    var mockTrigger = MockTrigger<Point>(result: .success(true))

    /// The trigger under test.
    lazy var trigger = WhenChanged(actualPath: path, trigger: mockTrigger)

    /// A trigger using an identity trigger in it's implementation.
    lazy var identityTrigger = WhenChanged(path)

    /// Test data.
    var point = Point(x: 1, y: 2)

    /// Reinitialise properties before every test case.
    override func setUp() {
        mockTrigger = MockTrigger(result: .success(true))
        trigger = WhenChanged(actualPath: path, trigger: mockTrigger)
        identityTrigger = WhenChanged(path)
        point = Point(x: 1, y: 2)
    }

    /// Test init sets path correctly.
    func testInit() {
        XCTAssertEqual(trigger.path, AnyPath(path))
        XCTAssertEqual(identityTrigger.path, AnyPath(path))
    }

    /// Test isTriggerForPath returns correct result.
    func testIsTriggerForPath() {
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path), in: point))
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(path), in: point))
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(ReadOnlyPath(Point.self)), in: point))
    }

    /// Test `performTrigger` uses mock trigger when given valid path.
    func testPerformTriggerForValidPath() throws {
        XCTAssertTrue(try trigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.rootPassed, point)
        XCTAssertEqual(mockTrigger.pathPassed, AnyPath(path))
    }

    /// Test `performTrigger` doesn't use trigger when given invalid path.
    func testPerformTriggerForInvalidPath() throws {
        XCTAssertFalse(try trigger.performTrigger(&point, for: AnyPath(ReadOnlyPath(Point.self))).get())
        XCTAssertEqual(mockTrigger.timesCalled, 0)
        XCTAssertNil(mockTrigger.rootPassed)
        XCTAssertNil(mockTrigger.pathPassed)
    }

    /// Test when calls trigger correctly for correct condition.
    func testWhen() throws {
        // swiftlint:disable:next multiline_arguments_brackets
        let falseTrigger = identityTrigger.when({ _ in
                false
            },
            then: { _ in
                mockTrigger
            }
        )
        XCTAssertFalse(try falseTrigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(mockTrigger.timesCalled, 0)
        XCTAssertNil(mockTrigger.pathPassed)
        XCTAssertNil(mockTrigger.rootPassed)
        // swiftlint:disable:next multiline_arguments_brackets
        let newTrigger = identityTrigger.when({ _ in
                true
            },
            then: { _ in
                mockTrigger
            }
        )
        XCTAssertTrue(try newTrigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, AnyPath(path))
        XCTAssertEqual(mockTrigger.rootPassed, point)
    }

    /// Test sync creates correct SyncTrigger.
    func testSync() throws {
        let newTrigger = identityTrigger.sync(target: Path(Point.self).y)
        XCTAssertTrue(try newTrigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(point.y, 1)
        XCTAssertEqual(point.x, 1)
    }

    /// Test sync performs transform correctly.
    func testSyncWithTransform() throws {
        let newTrigger = identityTrigger.sync(target: Path(Point.self).y) { val, _ in
            val + 5
        }
        XCTAssertTrue(try newTrigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(point.x, 1)
        XCTAssertEqual(point.y, 6)
    }

    /// Test `makeAvailable` creates correct trigger.
    func testMakeAvailable() throws {
        let newField = Field(name: "Age", type: .line)
        let fieldsPath = Path(Person.self).fields
        let attributesPath = Path(Person.self).attributes
        let trigger = WhenChanged(Path(Person.self)).makeAvailable(
            field: newField,
            after: ["Name"],
            fields: fieldsPath,
            attributes: attributesPath
        )
        let expected = MakeAvailableTrigger(
            field: newField,
            after: ["Name"],
            source: ReadOnlyPath(Person.self),
            fields: fieldsPath,
            attributes: attributesPath
        )
        XCTAssertEqual(trigger.attributes, expected.attributes)
        XCTAssertEqual(trigger.field, expected.field)
        XCTAssertEqual(trigger.fields, expected.fields)
        XCTAssertEqual(trigger.order, expected.order)
        XCTAssertEqual(trigger.path, expected.path)
        XCTAssertEqual(AnyPath(trigger.source), AnyPath(expected.source))
        var person = Person(fields: [Field(name: "Name", type: .line)], attributes: ["Name": .line("John")])
        var person2 = person
        XCTAssertTrue(try trigger.performTrigger(&person, for: AnyPath(Path(Person.self))).get())
        XCTAssertTrue(try expected.performTrigger(&person2, for: AnyPath(Path(Person.self))).get())
        XCTAssertEqual(person, person2)
        XCTAssertEqual(person.fields, [Field(name: "Age", type: .line), Field(name: "Name", type: .line)])
    }

    /// Test `makeUnavailable` creates correct trigger.
    func testMakeUnavailable() throws {
        let field = Field(name: "Name", type: .line)
        let fieldsPath = Path(Person.self).fields
        let trigger = WhenChanged(Path(Person.self)).makeUnavailable(
            field: field, fields: fieldsPath
        )
        let expected = MakeUnavailableTrigger(
            field: field, source: Path(Person.self), fields: fieldsPath
        )
        XCTAssertEqual(trigger.field, expected.field)
        XCTAssertEqual(trigger.fields, expected.fields)
        XCTAssertEqual(trigger.path, expected.path)
        XCTAssertEqual(AnyPath(trigger.source), AnyPath(expected.source))
        var person = Person(fields: [Field(name: "Name", type: .line)], attributes: ["Name": .line("John")])
        var person2 = person
        XCTAssertTrue(try trigger.performTrigger(&person, for: AnyPath(Path(Person.self))).get())
        XCTAssertTrue(try expected.performTrigger(&person2, for: AnyPath(Path(Person.self))).get())
        XCTAssertEqual(person, person2)
        XCTAssertTrue(person.fields.isEmpty)
    }

    /// Test `custom` created correct trigger.
    func testCustom() throws {
        let trigger = identityTrigger.custom {
            self.mockTrigger.performTrigger(&$0, for: AnyPath(self.path))
        }
        XCTAssertTrue(try trigger.performTrigger(&point, for: AnyPath(path)).get())
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, AnyPath(path))
        XCTAssertEqual(mockTrigger.rootPassed, point)
        XCTAssertEqual(trigger.path, AnyPath(path))
    }

}
