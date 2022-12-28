// ValidatorTests.swift 
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

/// Test class for Validator.
final class ValidatorTests: XCTestCase {

    /// Test path for validation.
    let path = ReadOnlyPath(keyPath: \Point.x, ancestors: [])

    /// Test point.
    let point = Point(x: 3, y: 4)

    /// Test path init.
    func testPathInit() {
        let validator = Validator(path: path)
        XCTAssertEqual(validator.path, path)
    }

    /// Test init used validation function.
    func testInitWithValidation() {
        var timesCalled = 0
        var pointPassed: Point?
        var valuePassed: Int?
        let validate: (Point, Int) throws -> Void = {
            timesCalled += 1
            pointPassed = $0
            valuePassed = $1
        }
        let validator = Validator(path, _validate: validate)
        XCTAssertEqual(validator.path, path)
        let result: ()? = try? validator.performValidation(point)
        XCTAssertNotNil(result)
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointPassed, point)
        XCTAssertEqual(valuePassed, point.x)
    }

    /// Test validate method.
    func testValidate() {
        var timesCalled = 0
        var validatorGiven: Validator<ReadOnlyPath<Point, Int>>?
        let builder: (Validator<ReadOnlyPath<Point, Int>>) -> [AnyValidator<Point>] = {
            timesCalled += 1
            validatorGiven = $0
            return [AnyValidator($0)]
        }
        let validator = Validator(path: path)
        let result = validator.validate(builder: builder)
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(validatorGiven?.path, validator.path)
        XCTAssertNotNil(try? result.performValidation(point))
    }

    /// Test validator throws correct error for a nil path.
    func testValidatorThrowsErrorForNilPath() {
        let path = Path([Point].self)[0]
        let validator = Validator(path) { _, _ in }
        XCTAssertThrowsError(try validator.performValidation([])) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Failed to cast error.")
                return
            }
            XCTAssertEqual(error.message, "Path is nil!")
            XCTAssertEqual(error.path, AnyPath(path))
        }
    }

}
