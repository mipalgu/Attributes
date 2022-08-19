// PathTests.swift 
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

/// Test class for Path.
final class PathTests: XCTestCase {

    /// Test data.
    let point = Point(x: 3, y: 4)

    /// Optional test data.
    let optionalPoint = OptionalPoint()

    /// Test init that takes an isNil function.
    func testInit() {
        var timesCalled = 0
        var pointCalled: OptionalPoint?
        let isNil: (OptionalPoint) -> Bool = { timesCalled += 1; pointCalled = $0; return true }
        let keyPath: WritableKeyPath<OptionalPoint, Int?> = \OptionalPoint.x
        let path = Path(path: keyPath, ancestors: [], isNil: isNil)
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointCalled, optionalPoint)
        XCTAssertEqual(keyPath, path.keyPath)
        XCTAssertTrue(path.ancestors.isEmpty)
        let typePath = Path(Point.self)
        let ancestors = [AnyPath(typePath)]
        let newPath = Path<Point, Int>(path: \.x, ancestors: ancestors)
        XCTAssertEqual(newPath.keyPath, \Point.x)
        XCTAssertEqual(newPath.ancestors, ancestors)
    }

    /// Test init that points to a non-optional value.
    func testNonOptionalInit() {
        let keyPath: WritableKeyPath<Point, Int> = \Point.x
        let path = Path(path: keyPath, ancestors: [])
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertFalse(path.isNil(point))
        XCTAssertTrue(path.ancestors.isEmpty)
    }

    /// Test init that is used for optional values.
    func testOptionalInit() {
        let keyPath = \OptionalPoint.x
        let path = Path(path: keyPath, ancestors: [])
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertTrue(path.ancestors.isEmpty)
    }

    /// Test type initialiser.
    func testTypeInit() {
        let keyPath = \Point.self
        let path = Path(Point.self)
        XCTAssertEqual(path.keyPath, keyPath)
    }

    /// Test readOnly property.
    func testReadOnly() {
        let readPath = ReadOnlyPath(Point.self)
        let path = Path(Point.self)
        XCTAssertEqual(path.readOnly, readPath)
    }

    /// Test appending methods and subscript operations.
    func testAppending() {
        let path = Path(Point.self)
        // let keyPath: KeyPath<Point, Int> = \.x
        let writePath: WritableKeyPath<Point, Int> = \.x
        let appendPath = Path(path: writePath, ancestors: [])
        let expected = Path(path: \Point.self.x, ancestors: [])
        // XCTAssertEqual(expected, path[dynamicMember: keyPath])
        XCTAssertEqual(expected, path[dynamicMember: writePath])
        XCTAssertEqual(expected, path.appending(path: appendPath))
    }

    /// Test changeRoot method.
    func testChangeRoot() {
        let path = Path(path: \Point.x, ancestors: [])
        let linePath = Path(path: \Line.point0, ancestors: [])
        let newPath = path.changeRoot(path: linePath)
        XCTAssertEqual(newPath, Path(path: \Line.point0.x, ancestors: []))
    }

    /// Test == operator.
    func testEquality() {
        let keyPath = \Point.x
        let ancestors = [AnyPath(Path(path: \Point.self, ancestors: []))]
        let newPath = Path(path: keyPath, ancestors: ancestors)
        let path2 = Path(path: keyPath, ancestors: ancestors)
        XCTAssertEqual(newPath, path2)
    }

}
