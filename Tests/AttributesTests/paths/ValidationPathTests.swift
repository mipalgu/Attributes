// ValidationPathTests.swift 
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

/// Test class for ValidationPath.
final class ValidationPathTests: XCTestCase {

    /// A path to use for testing.
    let path = ReadOnlyPath(keyPath: \Point.x, ancestors: [AnyPath(Path(Point.self))])

    /// Point test data.
    let point = Point(x: 3, y: 4)

    /// Test path init.
    func testPathInit() {
        let validationPath = ValidationPath(path: path)
        XCTAssertEqual(validationPath.path, path)
        XCTAssertNoThrow(try validationPath._validate(point, point.x))
    }

    /// Test Init with validate function.
    func testValidateInit() {
        var timesCalled = 0
        var root: Point?
        var value: Int?
        let validate: (Point, Int) throws -> Void = { timesCalled += 1; root = $0; value = $1 }
        let validationPath = ValidationPath(path, _validate: validate)
        XCTAssertEqual(validationPath.path, path)
        XCTAssertNoThrow(try validationPath._validate(point, point.x))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(root, point)
        XCTAssertEqual(value, point.x)
    }

    /// Test validate method.
    func testValidate() {
        var timesCalled = 0
        var pathPassed: ValidationPath<ReadOnlyPath<Point, Int>>?
        let builder: (ValidationPath<ReadOnlyPath<Point, Int>>) -> AnyValidator<Point> = {
            timesCalled += 1
            pathPassed = $0
            return AnyValidator()
        }
        let validationPath = ValidationPath(path: path)
        _ = validationPath.validate(builder: builder)
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pathPassed?.path, validationPath.path)
    }

    /// Test append subscript operation.
    func testAppend() {
        let path = ReadOnlyPath(keyPath: \Line.point0, ancestors: [AnyPath(Path(Line.self))])
        let appendingPath = \Point.x
        let validationPath = ValidationPath(path: path)
        let newPath = validationPath[dynamicMember: appendingPath]
        let expectedNewPath = ReadOnlyPath(keyPath: \Line.point0.x, ancestors: [
            AnyPath(Path(Line.self)),
            AnyPath(Path(path: \Line.point0, ancestors: [AnyPath(Path(Line.self))]))
        ])
        XCTAssertEqual(newPath.path, expectedNewPath)
    }

    /// Test methods that are available for paths that point to Nilable values.
    func testNilableMethods() {
        let path = ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: [AnyPath(Path(OptionalPoint.self))])
        let validationPath = ValidationPath(path: path)
        let req = validationPath.required()
        XCTAssertEqual(req.path, path)
        let opt = validationPath.optional()
        XCTAssertEqual(opt.path, path)
    }

    /// Test isNil on new path.
    func testPathIsNil() {
        let path = ReadOnlyPath(OptionalPoint.self)
        let validationPath = ValidationPath(path: path).x
        XCTAssertTrue(validationPath.path.isNil(OptionalPoint()))
    }

}
