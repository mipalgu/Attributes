// AnyValidatorTests.swift 
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

/// Test class for AnyValidator.
final class AnyValidatorTests: XCTestCase {

    /// How many times the validate function is called.
    var timesCalled = 0

    /// The parameter given to the validate function.
    var pointsReceived: [Point]?

    /// Some test data.
    let point = Point(x: 3, y: 4)

    /// The validate function.
    var f: (Point) throws -> Void {
        {
            self.timesCalled += 1
            guard self.pointsReceived != nil else {
                self.pointsReceived = [$0]
                return
            }
            self.pointsReceived?.append($0)
        }
    }

    // swiftlint:disable empty_xctest_method

    /// Reset test parameters.
    override func setUp() {
        timesCalled = 0
        pointsReceived = nil
    }

    // swiftlint:enable empty_xctest_method

    /// Test init that takes the validate function.
    func testValidateInit() {
        let validator = AnyValidator(validate: f)
        XCTAssertNoThrow(try validator.performValidation(point))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, point)
    }

    /// Test init that takes another AnyValidator.
    func testAnyValidatorInit() {
        let v1 = AnyValidator(validate: f)
        let v2 = AnyValidator(v1)
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, point)
    }

    /// Test AnyValidator array init.
    func testValidatorArrayInit() {
        let v1 = AnyValidator(validate: f)
        let v2 = AnyValidator([v1, v1])
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 2)
        XCTAssertEqual(pointsReceived?.count, 2)
        pointsReceived?.forEach {
            XCTAssertEqual($0, point)
        }
    }

    /// Test init that uses a builder function.
    func testBuilderInit() {
        let builder: () -> [AnyValidator<Point>] = {
            let v1 = AnyValidator(validate: self.f)
            return [v1, v1]
        }
        let v2 = AnyValidator(builder: builder)
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 2)
        XCTAssertEqual(pointsReceived?.count, 2)
        pointsReceived?.forEach {
            XCTAssertEqual($0, point)
        }
    }

    /// Test init that uses variadic parameters.
    func testVariadicInit() {
        let v1 = AnyValidator(validate: f)
        let v2 = AnyValidator(arrayLiteral: v1, v1)
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 2)
        XCTAssertEqual(pointsReceived?.count, 2)
        pointsReceived?.forEach {
            XCTAssertEqual($0, point)
        }
    }

    /// Test init that takes a sequence of other validators.
    func testCustomValidatorInits() {
        var timesCalled = 0
        var pointsReceived: [OptionalPoint]?
        let f: (OptionalPoint) throws -> Void = {
            timesCalled += 1
            guard pointsReceived != nil else {
                pointsReceived = [$0]
                return
            }
            pointsReceived?.append($0)
        }
        let v1 = RequiredValidator(
            ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: [AnyPath(Path(OptionalPoint.self))])
        ) { op, _ in
            try f(op)
        }
        let v2 = AnyValidator([v1, v1])
        let op = OptionalPoint(x: 5, y: nil)
        XCTAssertNoThrow(try v2.performValidation(op))
        XCTAssertEqual(timesCalled, 2)
        XCTAssertEqual(pointsReceived?.count, 2)
        pointsReceived?.forEach {
            XCTAssertEqual($0, op)
        }
    }

    /// Test toNewRoot function.
    func testToNewRoot() {
        let v1 = AnyValidator(validate: f)
        let path = ReadOnlyPath(keyPath: \Line.point0, ancestors: [AnyPath(Path(Line.self))])
        let line = Line(point0: Point(x: 10, y: 20), point1: Point(x: 30, y: 40))
        let v2 = v1.toNewRoot(path: path)
        XCTAssertNoThrow(try v2.performValidation(line))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, line.point0)
    }

}
