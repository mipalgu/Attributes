// TriggerBuilderTests.swift
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

/// Test class for ``TriggerBuilder``.
final class TriggerBuilderTests: XCTestCase {

    /// The builder under test.
    let builder = TriggerBuilder<Person>()

    /// A path to the root object.
    let path = AnyPath(ReadOnlyPath(Person.self))

    /// Null person.
    var person = Person(fields: [], attributes: [:])

    /// The trigger to build dynamically.
    var triggers: [MockTrigger<Person>] = [
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>(),
        MockTrigger<Person>()
    ]

    /// Reinitialise the triggers before every test case.
    override func setUp() {
        triggers = [
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>(),
            MockTrigger<Person>()
        ]
        person = Person(fields: [], attributes: [:])
    }

    /// Test buildBlock method.
    func testBuild0() {
        let trigger = builder.buildBlock()
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 0)
    }

    /// Test buildBlock method.
    func testBuild1() {
        @TriggerBuilder<Person>
        var trigger: MockTrigger<Person> {
            triggers[0]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 1)
    }

    /// Test buildBlock method.
    func testBuild2() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 2)
    }

    /// Test buildBlock method.
    func testBuild3() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 3)
    }

    /// Test buildBlock method.
    func testBuild4() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 4)
    }

    /// Test buildBlock method.
    func testBuild5() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 5)
    }

    /// Test buildBlock method.
    func testBuild6() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 6)
    }

    /// Test buildBlock method.
    func testBuild7() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 7)
    }

    /// Test buildBlock method.
    func testBuild8() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
            triggers[7]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 8)
    }

    /// Test buildBlock method.
    func testBuild9() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
            triggers[7]
            triggers[8]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 9)
    }

    /// Test buildBlock method.
    func testBuild10() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
            triggers[7]
            triggers[8]
            triggers[9]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 10)
    }

    /// Test buildBlock method.
    func testBuild11() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
            triggers[7]
            triggers[8]
            triggers[9]
            triggers[10]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 11)
    }

    /// Test buildBlock method.
    func testBuild12() {
        @TriggerBuilder<Person>
        var trigger: AnyTrigger<Person> {
            triggers[0]
            triggers[1]
            triggers[2]
            triggers[3]
            triggers[4]
            triggers[5]
            triggers[6]
            triggers[7]
            triggers[8]
            triggers[9]
            triggers[10]
            triggers[11]
        }
        guard case .success(let redraw) = trigger.performTrigger(&person, for: path), !redraw else {
            XCTFail("Invalid return type from trigger")
            return
        }
        assertTriggers(numTriggers: 12)
    }

    /// Check that the right triggers are called when built by a trigger builder.
    /// - Parameter numTriggers: The number of triggers that should have been called.
    private func assertTriggers(numTriggers: Int) {
        triggers.enumerated().forEach {
            guard $0 < numTriggers else {
                XCTAssertEqual($1.timesCalled, 0)
                XCTAssertNil($1.rootPassed)
                XCTAssertNil($1.pathPassed)
                return
            }
            XCTAssertEqual($1.timesCalled, 1)
            XCTAssertEqual($1.rootPassed, person)
            XCTAssertEqual($1.pathPassed, path)
        }
    }

}
