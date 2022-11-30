// ValidatorFactoryTests.swift 
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

/// Test class for ``ValidationFactory``.
final class ValidationFactoryTests: XCTestCase {

    /// A path to a point.
    let path = ReadOnlyPath(Point.self)

    /// A point test data.
    var point = Point(x: 1, y: 2)

    /// A validator for a point.
    var pointValidator = NullValidator<Point>()

    /// The factory under test.
    var factory = ValidatorFactory<Point>.required()

    override func setUp() {
        point = Point(x: 1, y: 2)
        pointValidator = NullValidator()
    }

    /// Test push method incorporates new validator.
    func testPush() throws {
        let newValidator = factory.push { _ in self.pointValidator }
        try newValidator.make(path: path).performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point)
    }

    /// Test make creates validator.
    func testMake() throws {
        try factory.make(path: path).performValidation(point)
    }

    /// Test make throws correct error for nil value in root.
    func testOptionalMake() throws {
        let newFactory = ValidatorFactory<Int?>.required()
        let point = OptionalPoint()
        let path = ReadOnlyPath(OptionalPoint.self).x
        XCTAssertNil(point.x)
        XCTAssertTrue(point[keyPath: path.keyPath].isNil)
        XCTAssertTrue(path.isNil(point))
        XCTAssertThrowsError(
            try newFactory.make(path: path).performValidation(point)
        ) {
            guard let error = $0 as? AttributeError<OptionalPoint> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Does not exist")
            XCTAssertEqual(error.path, AnyPath(path))
        }
    }

    /// Test make optional creates validator that isn't used for nil value.
    func testOptionalMakeNotRequired() throws {
        let validator = NullValidator<Int?>()
        let newFactory = ValidatorFactory<Int?>.optional().push { _ in
            validator
        }
        let point = OptionalPoint()
        let path = ReadOnlyPath(OptionalPoint.self).x
        XCTAssertNil(point.x)
        XCTAssertTrue(path.isNil(point))
        try newFactory.make(path: path).performValidation(point)
        XCTAssertEqual(validator.timesCalled, 0)
        XCTAssertNil(validator.lastParameter as Any?)
    }

    /// Test validate function creates correct validator.
    func testValidate() throws {
        let validator = ValidatorFactory<Point>.validate { _ in
            AnyValidator(self.pointValidator)
        }
        try validator.performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point)
    }

    /// Test validation is performed when if condition is true.
    func testIf() throws {
        let newFactory = factory.if({
                $0.x.isMultiple(of: 2)
            },
            then: {
                self.pointValidator
            }
        )
        try newFactory.make(path: path).performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 0)
        XCTAssertNil(pointValidator.lastParameter)
        let point1 = Point(x: 2, y: 3)
        try newFactory.make(path: path).performValidation(point1)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point1)
    }

    /// Test if-else calls correct validators.
    func testIfElse() throws {
        let validator2 = NullValidator<Point>()
        let newFactory = factory.if({
                $0.x.isMultiple(of: 2)
            },
            then: {
                self.pointValidator
            },
            else: {
                validator2
            }
        )
        try newFactory.make(path: path).performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 0)
        XCTAssertNil(pointValidator.lastParameter)
        XCTAssertEqual(validator2.timesCalled, 1)
        XCTAssertEqual(validator2.lastParameter, point)
        let point1 = Point(x: 2, y: 3)
        try newFactory.make(path: path).performValidation(point1)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point1)
        XCTAssertEqual(validator2.timesCalled, 1)
        XCTAssertEqual(validator2.lastParameter, point)
    }

    /// Test unique method.
    func testUnique() throws {
        let readPath = ReadOnlyPath([Point].self)
        let factory = ValidatorFactory<[Point]>.required().unique()
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4), Point(x: 5, y: 6)]
        try factory.make(path: readPath).performValidation(points)
        let points2 = points + [Point(x: 1, y: 2)]
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(points2)) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be unique")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test unique function with transform.
    func testUniqueWithTransform() throws {
        let readPath = ReadOnlyPath([Point].self)
        let factory = ValidatorFactory<[Point]>.required().unique {
            $0.dropFirst()
        }
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4), Point(x: 5, y: 6)]
        try factory.make(path: readPath).performValidation(points)
        let points2 = points + [Point(x: 1, y: 2)]
        try factory.make(path: readPath).performValidation(points2)
        let points3 = points + [Point(x: 3, y: 4)]
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(points3)) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be unique")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test equals function.
    func testEquals() throws {
        let readPath = ReadOnlyPath(EquatablePoint.self)
        let point = EquatablePoint(x: 1, y: 2)
        let factory = ValidatorFactory<EquatablePoint>.required().equals(point)
        try factory.make(path: readPath).performValidation(point)
        let point2 = EquatablePoint(x: 2, y: 3)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(point2)) {
            guard let error = $0 as? AttributeError<EquatablePoint> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(point).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test notEquals function.
    func testNotEquals() throws {
        let readPath = ReadOnlyPath(EquatablePoint.self)
        let point = EquatablePoint(x: 1, y: 2)
        let point2 = EquatablePoint(x: 2, y: 3)
        let factory = ValidatorFactory<EquatablePoint>.required().notEquals(point)
        try factory.make(path: readPath).performValidation(point2)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(point)) {
            guard let error = $0 as? AttributeError<EquatablePoint> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must not equal \(point).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test equalsTrue method.
    func testEqualsTrue() throws {
        let readPath = ReadOnlyPath(Bool.self)
        let value = true
        let notValue = false
        let factory = ValidatorFactory<Bool>.required().equalsTrue()
        try factory.make(path: readPath).performValidation(value)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(notValue)) {
            guard let error = $0 as? AttributeError<Bool> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(value).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test equalsFalse method.
    func testEqualsFalse() throws {
        let readPath = ReadOnlyPath(Bool.self)
        let value = true
        let notValue = false
        let factory = ValidatorFactory<Bool>.required().equalsFalse()
        try factory.make(path: readPath).performValidation(notValue)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(value)) {
            guard let error = $0 as? AttributeError<Bool> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(notValue).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test between method.
    func testBetween() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().between(min: 3, max: 7)
        try factory.make(path: readPath).performValidation(5)
        try factory.make(path: readPath).performValidation(3)
        try factory.make(path: readPath).performValidation(7)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(1)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be between \(3) and \(7).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `lessThan` method.
    func testLessThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().lessThan(5)
        try factory.make(path: readPath).performValidation(4)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `lessThanEqual` method.
    func testLessThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().lessThanEqual(5)
        try factory.make(path: readPath).performValidation(4)
        try factory.make(path: readPath).performValidation(5)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(6)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `greaterThan` method.
    func testGreaterThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().greaterThan(5)
        try factory.make(path: readPath).performValidation(6)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `greaterThanEqual` method.
    func testGreaterThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().greaterThanEqual(5)
        try factory.make(path: readPath).performValidation(5)
        try factory.make(path: readPath).performValidation(6)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(4)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

}
