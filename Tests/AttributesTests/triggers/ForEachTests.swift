// ForEachTests.swift 
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

/// Test class for ``ForEach``.
final class ForEachTests: XCTestCase {

    /// A path to an array of points.
    let arrayPath = Path([Point].self)

    /// The collection search path used with the trigger.
    lazy var path = CollectionSearchPath(arrayPath)

    /// A mock trigger.
    var mockTrigger = MockTrigger<[Point]>(result: .success(true))

    /// An array of points.
    var points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]

    /// The trigger under test.
    lazy var trigger = ForEach(path) { _ in
        self.mockTrigger
    }

    /// A trigger that does no function.
    lazy var identityTrigger = ForEach(path) { _ in
        WhenChanged(self.arrayPath[1])
    }

    /// Initialise all properties before testing.
    override func setUp() {
        mockTrigger = MockTrigger(result: .success(true))
        trigger = ForEach(path) { _ in
            self.mockTrigger
        }
        points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
        path = CollectionSearchPath(arrayPath)
        identityTrigger = ForEach(path) { _ in
            WhenChanged(self.arrayPath[1])
        }
    }

    /// Test `performTrigger` calls mockTrigger with correct parameters.
    func testPerformTrigger() throws {
        XCTAssertTrue(try trigger.performTrigger(&points, for: AnyPath(arrayPath)).get())
        XCTAssertEqual(mockTrigger.timesCalled, 2)
        XCTAssertEqual(mockTrigger.rootsPassed, [points, points])
        XCTAssertEqual(mockTrigger.pathsPassed, [AnyPath(arrayPath), AnyPath(arrayPath)])
    }

    /// Test isTriggerOrSame returns correctly for paths.
    func testIsTriggerOrSame() {
        XCTAssertFalse(trigger.isTriggerForPath(AnyPath(arrayPath), in: points))
        XCTAssertTrue(trigger.isTriggerForPath(AnyPath(arrayPath[0]), in: points))
    }

    /// Test `when` calls trigger correctly.
    func testWhen() throws {
        let newTrigger = identityTrigger.when({ _ in true }, then: { _ in self.mockTrigger })
        XCTAssertTrue(try newTrigger.performTrigger(&points, for: AnyPath(arrayPath[0])).get())
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.rootsPassed, [points])
        XCTAssertEqual(mockTrigger.pathsPassed, [AnyPath(arrayPath[0])])
        XCTAssertTrue(try newTrigger.performTrigger(&points, for: AnyPath(arrayPath[1])).get())
        XCTAssertEqual(mockTrigger.timesCalled, 2)
        XCTAssertEqual(mockTrigger.rootsPassed, [points, points])
        XCTAssertEqual(mockTrigger.pathsPassed, [AnyPath(arrayPath[0]), AnyPath(arrayPath[1])])
    }

    /// Test `sync` calls trigger correctly.
    func testSync() throws {
        let newTrigger = identityTrigger.sync(target: arrayPath[0])
        XCTAssertTrue(try newTrigger.performTrigger(&points, for: AnyPath(arrayPath[0])).get())
        XCTAssertEqual(points, [Point(x: 3, y: 4), Point(x: 3, y: 4)])
    }

    /// Sync with transform.
    func testSyncWithTransform() throws {
        let newTrigger = identityTrigger.sync(target: arrayPath[0]) { _, _ in
            Point(x: 10, y: 11)
        }
        XCTAssertTrue(try newTrigger.performTrigger(&points, for: AnyPath(arrayPath[0])).get())
        XCTAssertEqual(points, [Point(x: 10, y: 11), Point(x: 3, y: 4)])
    }

    /// Test `makeAvailable` makes field available.
    func testMakeAvailable() throws {
        let path = Path(Person.self)
        let newTrigger = ForEach(path) { _ in
            WhenChanged(path)
        }
        .makeAvailable(
            field: Field(name: "Name", type: .line),
            after: [],
            fields: path.fields,
            attributes: path.attributes
        )
        var person = Person(fields: [], attributes: [:])
        XCTAssertTrue(try newTrigger.performTrigger(&person, for: AnyPath(path)).get())
        XCTAssertEqual(
            person,
            Person(fields: [Field(name: "Name", type: .line)], attributes: ["Name": .line("")])
        )
    }

    /// Test `makeUnavailable` removes field.
    func testMakeUnavailable() throws {
        let path = Path(Person.self)
        let newTrigger = ForEach(path) { _ in
            WhenChanged(path)
        }
        .makeUnavailable(field: Field(name: "Name", type: .line), fields: path.fields)
        var person = Person(
            fields: [Field(name: "Name", type: .line)], attributes: ["Name": .line("John Smith")]
        )
        XCTAssertTrue(try newTrigger.performTrigger(&person, for: AnyPath(path)).get())
        XCTAssertEqual(
            person,
            Person(fields: [], attributes: ["Name": .line("John Smith")])
        )
    }

}
