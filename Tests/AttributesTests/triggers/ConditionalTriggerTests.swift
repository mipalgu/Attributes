// ConditionalTriggerTests.swift 
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

/// Test class for ConditionalTrigger.
final class ConditionalTriggerTests: XCTestCase {

    /// Keep track of function calls.
    var timesCalled = 0

    /// Keep track of value passed to condition functions.
    var valuePassed: Point?

    /// A function that always returns true.
    var trueCondition: (Point) -> Bool {
        { self.timesCalled += 1; self.valuePassed = $0; return true }
    }

    /// A function that always returns false.
    var falseCondition: (Point) -> Bool {
        { self.timesCalled += 1; self.valuePassed = $0; return false }
    }

    /// The trigger the ConditionalTrigger uses.
    let mockTrigger = MockTrigger<Point>()

    /// A path to a Point.
    let path = AnyPath(Path(Point.self))

    /// Reset track data every test.
    override func setUp() {
        timesCalled = 0
        valuePassed = nil
    }

    /// Test init.
    func testInit() {
        let trigger = ConditionalTrigger(condition: trueCondition, trigger: mockTrigger)
        XCTAssertEqual(trigger.trigger, mockTrigger)
    }

    /// Test performTrigger when condition is true.
    func testTriggerForTrue() {
        var point = Point(x: 3, y: 4)
        let trigger = ConditionalTrigger(condition: trueCondition, trigger: mockTrigger)
        XCTAssertEqual(trigger.performTrigger(&point, for: path), .success(false))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(valuePassed, point)
        XCTAssertEqual(mockTrigger.rootPassed, point)
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, path)
    }

    /// Test performTrigger when the condition is false.
    func testTriggerForFalse() {
        var point = Point(x: 3, y: 4)
        let trigger = ConditionalTrigger(condition: falseCondition, trigger: mockTrigger)
        XCTAssertEqual(trigger.performTrigger(&point, for: AnyPath(Path(Point.self))), .success(false))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(valuePassed, point)
        XCTAssertNil(mockTrigger.rootPassed)
        XCTAssertEqual(mockTrigger.timesCalled, 0)
        XCTAssertNil(mockTrigger.pathPassed)
    }

    /// Test isTriggerForPath function.
    func testIsTriggerForPath() {
        let point = Point(x: 3, y: 4)
        let trigger = ConditionalTrigger(condition: falseCondition, trigger: mockTrigger)
        XCTAssertTrue(trigger.isTriggerForPath(path, in: point))
        XCTAssertEqual(mockTrigger.rootPassed, point)
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, path)
    }

}
