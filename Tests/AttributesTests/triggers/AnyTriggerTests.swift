// AnyTriggerTests.swift 
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

/// Test class for ``AnyTrigger``.
final class AnyTriggerTests: XCTestCase {

    /// An error for a failed trigger.
    var error: AttributeError<Point> {
        AttributeError(message: "error", path: path)
    }

    /// Trigger under test.
    var trigger = MockTrigger<Point>()

    /// Test data.
    var point = Point(x: 1, y: 2)

    /// Test path.
    let path = AnyPath(Path(Point.self).x)

    /// Reinitialise member properties.
    override func setUp() {
        trigger = MockTrigger<Point>()
        point = Point(x: 1, y: 2)
    }

    /// Test arrayLiteral initialisation.
    func testArrayLiteralInit() {
        let trigger2 = MockTrigger<Point>()
        let anyTrigger = AnyTrigger<Point>(arrayLiteral: AnyTrigger(trigger), AnyTrigger(trigger2))
        checkTrigger(root: &point, path: path, trigger: anyTrigger)
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger2.rootPassed, point)
        XCTAssertEqual(trigger2.pathPassed, path)
    }

    /// Test the base init sets the callbacks correctly.
    func testBaseInit() {
        let anyTrigger = AnyTrigger(trigger)
        checkTrigger(root: &point, path: path, trigger: anyTrigger)
    }

    /// Test TriggerBuilder init.
    func testBuilderInit() {
        let anyTrigger = AnyTrigger {
            AnyTrigger(trigger)
        }
        checkTrigger(root: &point, path: path, trigger: anyTrigger)
    }

    /// Test copy initialiser sets callbacks appropriately.
    func testCopyInit() {
        let anyTrigger = AnyTrigger(trigger)
        let newTrigger = AnyTrigger(anyTrigger)
        checkTrigger(root: &point, path: path, trigger: newTrigger)
    }

    /// Test search path init uses correct trigger.
    func testSearchPathInit() {
        let searchPath = CollectionSearchPath(
            collectionPath: Path([Point].self), elementPath: Path(Point.self)
        )
        let mockTrigger = MockTrigger<[Point]>()
        let anyTrigger = AnyTrigger(path: searchPath, trigger: mockTrigger.performTrigger)
        var points: [Point] = [point]
        let anyPath = AnyPath(searchPath.collectionPath)
        XCTAssertTrue(anyTrigger.isTriggerForPath(AnyPath(Path([Point].self)[0].x), in: points))
        guard
            case .success(let bool) = anyTrigger.performTrigger(&points, for: anyPath),
            !bool
        else {
            XCTFail("Invalid return from trigger.")
            return
        }
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.rootPassed, points)
        XCTAssertEqual(mockTrigger.pathPassed, anyPath)
    }

    /// Test sequence init.
    func testSequenceInit() {
        let trigger2 = MockTrigger<Point>()
        let anyTrigger = AnyTrigger([trigger, trigger2])
        checkTrigger(root: &point, path: path, trigger: anyTrigger)
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger2.rootPassed, point)
        XCTAssertEqual(trigger2.pathPassed, path)
    }

    /// Test init using an empty sequence.
    func testEmptySequenceInit() throws {
        let triggers: [MockTrigger<Point>] = []
        let anyTrigger = AnyTrigger(triggers)
        XCTAssertFalse(try anyTrigger.performTrigger(&point, for: path).get())
        XCTAssertFalse(anyTrigger.isTriggerForPath(path, in: point))
        XCTAssertEqual(self.trigger.timesCalled, 0)
        XCTAssertNil(self.trigger.rootPassed)
        XCTAssertNil(self.trigger.pathPassed)
    }

    /// Test sequence init.
    func testSequenceWithSecondFailingTrigger() {
        let trigger2 = MockTrigger<Point>(result: .failure(error))
        let anyTrigger = AnyTrigger([trigger, trigger2])
        checkTrigger(root: &point, path: path, trigger: anyTrigger, result: .failure(error))
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger2.rootPassed, point)
        XCTAssertEqual(trigger2.pathPassed, path)
    }

    /// Test sequence init.
    func testSequenceWithFailingTrigger() {
        let trigger2 = MockTrigger<Point>(result: .failure(error))
        let anyTrigger = AnyTrigger([trigger2, trigger])
        XCTAssertEqual(.failure(error), anyTrigger.performTrigger(&point, for: path))
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger2.rootPassed, point)
        XCTAssertEqual(trigger2.pathPassed, path)
        XCTAssertEqual(self.trigger.timesCalled, 1)
        XCTAssertEqual(self.trigger.rootPassed, point)
        XCTAssertEqual(self.trigger.pathPassed, path)
        trigger2.reset()
        self.trigger.reset()
        XCTAssertTrue(anyTrigger.isTriggerForPath(path, in: point))
        XCTAssertEqual(self.trigger.timesCalled, 0)
        XCTAssertNil(self.trigger.rootPassed)
        XCTAssertNil(self.trigger.pathPassed)
        XCTAssertEqual(trigger2.timesCalled, 1)
        XCTAssertEqual(trigger2.rootPassed, point)
        XCTAssertEqual(trigger2.pathPassed, path)
    }

    /// Check the type-erased trigger succesfully calls the typed triggers functions.
    /// - Parameters:
    ///   - root: A root to act upon.
    ///   - path: A path to use in the trigger.
    ///   - trigger: The type-erased trigger.
    ///   - result: The expected result from the performTrigger method.
    private func checkTrigger(
        root: inout Point,
        path: AnyPath<Point>,
        trigger: AnyTrigger<Point>,
        result: Result<Bool, AttributeError<Point>> = .success(false)
    ) {
        XCTAssertEqual(result, trigger.performTrigger(&root, for: path))
        XCTAssertEqual(self.trigger.timesCalled, 1)
        XCTAssertEqual(self.trigger.rootPassed, root)
        XCTAssertEqual(self.trigger.pathPassed, path)
        guard trigger.isTriggerForPath(path, in: root) else {
            XCTFail("Invalid return from trigger.")
            return
        }
        XCTAssertEqual(self.trigger.timesCalled, 2)
        XCTAssertEqual(self.trigger.rootPassed, root)
        XCTAssertEqual(self.trigger.pathPassed, path)
    }

}
