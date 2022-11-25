// ValidationPushProtocolTests.swift 
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

/// Test class for ``ValidationPushProtocol`` default implementations.
final class ValidationPushProtocolTests: XCTestCase {

    /// A path under test.
    let pointPath = TestValidationPath(path: ReadOnlyPath(Point.self))

    /// A path to a Person under test.
    let personPath = TestValidationPath(path: ReadOnlyPath(Person.self))

    /// A point test data.
    var point = Point(x: 1, y: 2)

    /// A validator for a point.
    var pointValidator = NullValidator<Point>()

    override func setUp() {
        point = Point(x: 1, y: 2)
        pointValidator = NullValidator()
    }

    /// Test push method incorporates new validator.
    func testPush() throws {
        let newValidator = pointPath.push { point, _ in try self.pointValidator.performValidation(point) }
        try newValidator.performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point)
    }

    /// Test validation is performed when if condition is true.
    func testIf() throws {
        let newPath = pointPath.if({
                $0.x.isMultiple(of: 2)
            },
            then: {
                self.pointValidator
            }
        )
        try newPath.performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 0)
        XCTAssertNil(pointValidator.lastParameter)
        let point1 = Point(x: 2, y: 3)
        try newPath.performValidation(point1)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point1)
    }

    /// Test if-else calls correct validators.
    func testIfElse() throws {
        let validator2 = NullValidator<Point>()
        let newPath = pointPath.if({
                $0.x.isMultiple(of: 2)
            },
            then: {
                self.pointValidator
            },
            else: {
                validator2
            }
        )
        try newPath.performValidation(point)
        XCTAssertEqual(pointValidator.timesCalled, 0)
        XCTAssertNil(pointValidator.lastParameter)
        XCTAssertEqual(validator2.timesCalled, 1)
        XCTAssertEqual(validator2.lastParameter, point)
        let point1 = Point(x: 2, y: 3)
        try newPath.performValidation(point1)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, point1)
        XCTAssertEqual(validator2.timesCalled, 1)
        XCTAssertEqual(validator2.lastParameter, point)
    }

    /// Test `in` sequence performs validation without throwing.
    func testInSequence() throws {
        let readPath = ReadOnlyPath([EquatablePoint].self)
        let path = TestValidationPath(path: readPath[0])
        let newPath = path.in(readPath)
        let points = [EquatablePoint(x: 1, y: 2)]
        try newPath.performValidation(points)
    }

    /// Test `in` sequence with transform performs validation without throwing.
    func testInSequenceWithTransform() throws {
        let readPath = ReadOnlyPath([EquatablePoint].self)
        let path = TestValidationPath(path: readPath[0])
        let val = NullValidator<EquatablePoint>()
        let newPath = path.push { _, value in try val.performValidation(value) }.in(readPath) {
            $0.sorted { p0, p1 in
                p0.x < p1.x
            }
        }
        let points = [EquatablePoint(x: 2, y: 3), EquatablePoint(x: 1, y: 2)]
        try newPath.performValidation(points)
        XCTAssertEqual(val.timesCalled, 1)
        XCTAssertEqual(val.lastParameter, EquatablePoint(x: 2, y: 3))
    }

    /// Test `in` sequence with transform throws correct error.
    func testInSequenceWithTransformThrowingError() {
        let readPath = ReadOnlyPath([EquatablePoint].self)
        let path = TestValidationPath(path: readPath[0])
        let val = NullValidator<EquatablePoint>()
        let newPath = path.push { _, value in try val.performValidation(value) }.in(readPath) {
            $0.dropFirst()
        }
        let points = [EquatablePoint(x: 2, y: 3), EquatablePoint(x: 1, y: 2)]
        XCTAssertThrowsError(try newPath.performValidation(points)) {
            guard let error = $0 as? ValidationError<[EquatablePoint]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal one of the following: '\(EquatablePoint(x: 1, y: 2))'.")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(val.timesCalled, 1)
        XCTAssertEqual(val.lastParameter, EquatablePoint(x: 2, y: 3))
    }

    /// Test `in` method doesn't throw when the Sequence element is hashable.
    func testHashableInSequence() throws {
        let readPath = ReadOnlyPath([Point].self)
        let path = TestValidationPath(path: readPath[0])
        let newPath = path.in(readPath)
        let points = [Point(x: 1, y: 2)]
        try newPath.performValidation(points)
    }

    /// Test `in` sequence with hashable elements using transform doesn't throw error.
    func testHashableInSeuenceWithTransform() throws {
        let readPath = ReadOnlyPath([Point].self)
        let path = TestValidationPath(path: readPath[0])
        let val = NullValidator<Point>()
        let newPath = path.push { _, value in try val.performValidation(value) }.in(readPath) {
            $0.sorted { p0, p1 in
                p0.x < p1.x
            }
        }
        let points = [Point(x: 2, y: 3), Point(x: 1, y: 2)]
        try newPath.performValidation(points)
        XCTAssertEqual(val.timesCalled, 1)
        XCTAssertEqual(val.lastParameter, Point(x: 2, y: 3))
    }

    /// Test `in` sequence with hashable elements using transform throws correct error.
    func testHashableInSequenceWithTransformThrowingError() {
        let readPath = ReadOnlyPath([Point].self)
        let path = TestValidationPath(path: readPath[0])
        let val = NullValidator<Point>()
        let newPath = path.push { _, value in try val.performValidation(value) }.in(readPath) {
            $0.dropFirst()
        }
        let points = [Point(x: 2, y: 3), Point(x: 1, y: 2)]
        XCTAssertThrowsError(try newPath.performValidation(points)) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal one of the following: '\(Point(x: 1, y: 2))'.")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(val.timesCalled, 1)
        XCTAssertEqual(val.lastParameter, Point(x: 2, y: 3))
    }

    /// Test in method when value in path is a Set.
    func testHashableInSetPath() throws {
        let readPath = ReadOnlyPath(Set<Point>.self)
        let path = TestValidationPath(path: readPath.first.unsafelyUnwrapped)
        let points: Set<Point> = [Point(x: 2, y: 3), Point(x: 1, y: 2)]
        let newPath = path.push { _, value in try self.pointValidator.performValidation(value) }.in(readPath)
        try newPath.performValidation(points)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertNotNil(pointValidator.lastParameter)
        XCTAssertTrue(points.contains(pointValidator.lastParameter ?? Point(x: 3, y: 4)))
    }

    /// Test in method taking Set doesn't throw error.
    func testHashableInSet() throws {
        let readPath = ReadOnlyPath(Set<Point>.self)
        let path = TestValidationPath(path: readPath.first)
        let points: Set<Point> = [Point(x: 1, y: 2)]
        let newPath = path.push { _, value in
            try self.pointValidator.performValidation(value.unsafelyUnwrapped)
        }
        .in(points)
        try newPath.performValidation(points)
        XCTAssertEqual(pointValidator.timesCalled, 1)
        XCTAssertEqual(pointValidator.lastParameter, Point(x: 1, y: 2))
    }

    /// Test in method taking set throws correct error for empty set.
    func testHashableInSetThrowsError() {
        let readPath = ReadOnlyPath(Set<Point>.self)
        let path = TestValidationPath(path: readPath.first)
        let points: Set<Point> = [Point(x: 1, y: 2)]
        let newPath = path.in(points)
        XCTAssertThrowsError(try newPath.performValidation(Set<Point>())) {
            guard let error = $0 as? ValidationError<Set<Point>> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(
                error.message, "Must equal one of the following: '\([Optional.some(Point(x: 1, y: 2))])'."
            )
            XCTAssertEqual(error.path, AnyPath(newPath.path))
        }
    }

    /// Test unique method.
    func testUnique() throws {
        let readPath = ReadOnlyPath([Point].self)
        let validator = NullValidator<[Point]>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .unique()
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4), Point(x: 5, y: 6)]
        try path.performValidation(points)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, points)
        let points2 = points + [Point(x: 1, y: 2)]
        XCTAssertThrowsError(try path.performValidation(points2)) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be unique")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, points2)
    }

    /// Test unique function with transform.
    func testUniqueWithTransform() throws {
        let readPath = ReadOnlyPath([Point].self)
        let validator = NullValidator<[Point]>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .unique { $0.dropFirst() }
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4), Point(x: 5, y: 6)]
        try path.performValidation(points)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, points)
        let points2 = points + [Point(x: 1, y: 2)]
        try path.performValidation(points2)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, points2)
        let points3 = points + [Point(x: 3, y: 4)]
        XCTAssertThrowsError(try path.performValidation(points3)) {
            guard let error = $0 as? ValidationError<[Point]> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be unique")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 3)
        XCTAssertEqual(validator.lastParameter, points3)
    }

}
