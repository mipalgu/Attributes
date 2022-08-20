// RequiredValidatorTests.swift 
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

/// Test class for RequiredValidator.
final class RequiredValidatorTests: XCTestCase {

    /// How many times the validate function is called.
    var timesCalled = 0

    /// The parameter given to the validate function.
    var pointsReceived: [OptionalPoint]?

    /// The values received in the validate function.
    var valuesReceived: [Int?]?

    /// Some test data.
    let point = OptionalPoint(x: 3, y: nil)

    /// The validate function.
    var f: (OptionalPoint, Int?) throws -> Void {
        {
            self.timesCalled += 1
            guard self.pointsReceived != nil else {
                self.pointsReceived = [$0]
                guard self.valuesReceived != nil else {
                    self.valuesReceived = [$1]
                    return
                }
                self.valuesReceived?.append($1)
                return
            }
            self.pointsReceived?.append($0)
            self.valuesReceived?.append($1)
        }
    }

    /// A path that points to the x-value of an OptionalPoint.
    let path = ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: [AnyPath(Path(OptionalPoint.self))])

    /// Reset test parameters.
    override func setUp() {
        timesCalled = 0
        pointsReceived = nil
        valuesReceived = nil
    }

    /// Test init using Path initialiser.
    func testPathInit() {
        let validator = RequiredValidator(path: path)
        XCTAssertEqual(validator.path, path)
    }

    /// Test init which takes a validation function.
    func testValidateInit() {
        let v1 = RequiredValidator(path, _validate: f)
        XCTAssertEqual(v1.path, path)
        XCTAssertNoThrow(try v1.performValidation(point))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, point)
        XCTAssertEqual(valuesReceived?.count, 1)
        XCTAssertEqual(valuesReceived?.first ?? (nil as Int?), point.x)
    }

    /// Test performValidation when the path points to nil values.
    func testPerformValidationNilValue() {
        let newPoint = OptionalPoint(x: nil, y: 5)
        let v1 = RequiredValidator(path, _validate: f)
        do {
            try v1.performValidation(newPoint)
            XCTFail("Validation succeeded for nil case.")
        } catch {
            guard let error = error as? ValidationError<OptionalPoint> else {
                XCTFail("Failed to cast error.")
                return
            }
            XCTAssertEqual(error.message, "Required")
            XCTAssertEqual(error.path, AnyPath(path))
        }
    }

    /// Test validate function.
    func testValidateFunction() {
        let v1 = RequiredValidator(path, _validate: f)
        let builder: (
            RequiredValidator<ReadOnlyPath<OptionalPoint, Int?>>
        ) -> [AnyValidator<OptionalPoint>] = {
            [AnyValidator([$0])]
        }
        let v2 = v1.validate(builder: builder)
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, point)
        XCTAssertEqual(valuesReceived?.count, 1)
        XCTAssertEqual(valuesReceived?.first ?? (nil as Int?), point.x)
    }

    /// Test push function.
    func testPush() {
        let v1 = RequiredValidator(path, _validate: f)
        let v2 = v1.push(f)
        XCTAssertEqual(v2.path, path)
        XCTAssertNoThrow(try v2.performValidation(point))
        XCTAssertEqual(timesCalled, 2)
        XCTAssertEqual(pointsReceived?.count, 2)
        pointsReceived?.forEach {
            XCTAssertEqual($0, point)
        }
        XCTAssertEqual(valuesReceived?.count, 2)
        valuesReceived?.forEach {
            XCTAssertEqual($0, point.x)
        }
    }

}
