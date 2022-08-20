// ChainValidatorTests.swift 
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

/// Test class for ChainValidator.
final class ChainValidatorTests: XCTestCase {

    /// How many times the validate function is called.
    var timesCalled = 0

    /// The parameter given to the validate function.
    var pointsReceived: [OptionalPoint]?

    /// The values received in the validate function.
    var valuesReceived: [Int?]?

    /// Some test data.
    let line = OptionalLine(point0: OptionalPoint(x: 3, y: nil), point1: nil)

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

    /// The path to a point in an OptionalLine.
    let chainPath = ReadOnlyPath(
        keyPath: \OptionalLine.point0.wrappedValue,
        ancestors: [
            AnyPath(Path(OptionalLine.self)),
            AnyPath(Path(path: \OptionalLine.point0, ancestors: [AnyPath(Path(OptionalLine.self))]))
        ]
    )

    /// A required validator acting on the x-coordinate of an OptionalPoint.
    var requiredValidator: RequiredValidator<ReadOnlyPath<OptionalPoint, Int?>> {
        RequiredValidator(path, _validate: f)
    }

    // swiftlint:disable empty_xctest_method

    /// Reset test parameters.
    override func setUp() {
        timesCalled = 0
        pointsReceived = nil
        valuesReceived = nil
    }

    // swiftlint:enable empty_xctest_method

    /// Test init.
    func testInit() {
        let validator = ChainValidator(path: chainPath, validator: requiredValidator)
        XCTAssertEqual(validator.path, chainPath)
        XCTAssertEqual(validator.validator.path, requiredValidator.path)
    }

    /// Test performValidation function.
    func testPerformValidation() {
        let validator = ChainValidator(path: chainPath, validator: requiredValidator)
        XCTAssertNoThrow(try validator.performValidation(line))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointsReceived?.count, 1)
        XCTAssertEqual(pointsReceived?.first, line.point0)
        XCTAssertEqual(valuesReceived?.count, 1)
        XCTAssertEqual(valuesReceived?.first, line.point0?.x)
    }

    /// Test performValidation function here validator throws an error.
    func testPerformValidationWithThrows() {
        let validator = ChainValidator(path: chainPath, validator: requiredValidator)
        let newLine = OptionalLine(point0: OptionalPoint(x: nil, y: 1), point1: OptionalPoint(x: 3, y: 4))
        do {
            try validator.performValidation(newLine)
            XCTFail("Failed to throw error for nil value.")
        } catch {
            guard let error = error as? AttributeError<OptionalLine> else {
                XCTFail("Failed to cast error to correct type.")
                return
            }
            XCTAssertEqual(error.message, "Required")
            XCTAssertEqual(error.path, AnyPath(chainPath))
        }
    }

}
