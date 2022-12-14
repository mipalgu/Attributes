// ReadOnlyPathTests.swift 
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

/// Test class for ReadOnlyPath.
final class ReadOnlyPathTests: XCTestCase {

    /// Test data.
    let point = Point(x: 3, y: 4)

    /// Optional test data.
    let optionalPoint = OptionalPoint()

    /// Test init that takes an isNil function.
    func testInit() {
        var timesCalled = 0
        var pointCalled: OptionalPoint?
        let isNil: (OptionalPoint) -> Bool = { timesCalled += 1; pointCalled = $0; return true }
        let keyPath = \OptionalPoint.x
        let path = ReadOnlyPath(
            keyPath: keyPath, ancestors: [AnyPath(Path(OptionalPoint.self))], isNil: isNil
        )
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointCalled, optionalPoint)
        XCTAssertEqual(keyPath, path.keyPath)
        XCTAssertEqual(path.ancestors, [AnyPath(Path(OptionalPoint.self))])
        let typePath = ReadOnlyPath(Point.self)
        let ancestors = [AnyPath(typePath)]
        let newPath = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: ancestors)
        XCTAssertEqual(newPath.keyPath, \Point.x)
        XCTAssertEqual(newPath.ancestors, ancestors)
    }

    /// Test init that points to a non-optional value.
    func testNonOptionalInit() {
        let keyPath = \Point.x
        let path = ReadOnlyPath(keyPath: keyPath, ancestors: [AnyPath(Path(Point.self))])
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertFalse(path.isNil(point))
        XCTAssertEqual(path.ancestors, [AnyPath(Path(Point.self))])
    }

    /// Test init that is used for optional values.
    func testOptionalInit() {
        let keyPath = \OptionalPoint.x
        let path = ReadOnlyPath(keyPath: keyPath, ancestors: [AnyPath(Path(OptionalPoint.self))])
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertEqual(path.ancestors, [AnyPath(Path(OptionalPoint.self))])
    }

    /// Test isNil still works when appending members.
    func testIsNilAppendingPath() {
        let path = ReadOnlyPath(OptionalPoint.self).x
        XCTAssertTrue(path.isNil(OptionalPoint()))
    }

    /// Test isNil function when ancestor is nil.
    func testIsNilForNilAncestor() {
        let path = ReadOnlyPath(Optional<OptionalPoint>.self)
        XCTAssertTrue(path.isNil(nil))
        let newPath = path.wrappedValue.x
        XCTAssertTrue(newPath.isNil(nil))
    }

    /// Test isNil for nested arrays.
    func testIsNilForArrayAncestor() {
        let path = ReadOnlyPath([[Point]].self)[1][0]
        XCTAssertTrue(path.isNil([[Point(x: 1, y: 2)]]))
        XCTAssertFalse(path.isNil([[Point(x: 1, y: 2)], [Point(x: 3, y: 4)]]))
    }

    /// Test isNil for multiple optional paths.
    func testIsNilForAppendedOptionalPath() {
        let path = ReadOnlyPath(Optional<OptionalPoint>.self).wrappedValue.x.wrappedValue
        XCTAssertTrue(path.isNil(OptionalPoint()))
        XCTAssertTrue(path.isNil(nil))
        XCTAssertFalse(path.isNil(OptionalPoint(x: 1, y: 2)))
    }

    /// Check isNil works when converting Path.
    func testIsNilWithNilAncestorAfterChangingRoot() {
        let path = Path([Point].self)[0].x
        let path2 = Path([[Point]].self)[1]
        let newPath = path.changeRoot(path: path2)
        let root = [[Point(x: 1, y: 2)]]
        let root2 = root + [[Point(x: 3, y: 4)]]
        let readPath = ReadOnlyPath(keyPath: newPath.keyPath, ancestors: newPath.ancestors) {
            newPath.isNil($0)
        }
        XCTAssertTrue(readPath.isNil(root))
        XCTAssertFalse(readPath.isNil(root2))
    }

    /// Test isNil for optional append.
    func testIsNilForOptionalAppend() {
        let path = ReadOnlyPath([Point].self).first
        XCTAssertTrue(path.isNil([]))
    }

    /// Test isNil for optional append containing nil ancestor.
    func testIsNilForOptionalAppendWithNilAncestor() {
        let path = ReadOnlyPath([[Point]].self)[1].first
        XCTAssertTrue(path.isNil([]))
        XCTAssertTrue(path.isNil([[]]))
        XCTAssertTrue(path.isNil([[Point(x: 1, y: 2)], []]))
        XCTAssertTrue(path.isNil([[], []]))
        XCTAssertFalse(path.isNil([[], [Point(x: 1, y: 2)]]))
    }

    /// Test isNil function works when using a keypath to an optional value.
    func testIsNilOptionalKeyPathCreationWithoutAncestors() {
        let path = ReadOnlyPath(keyPath: \Optional<Point>.self, ancestors: [])
        XCTAssertTrue(path.isNil(nil))
        XCTAssertFalse(path.isNil(Point(x: 1, y: 2)))
    }

    /// Test type initialiser.
    func testTypeInit() {
        let keyPath = \Point.self
        let path = ReadOnlyPath(Point.self)
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertTrue(path.ancestors.isEmpty)
    }

    /// Test appending subscript.
    func testAppendSubscript() {
        let path = ReadOnlyPath(Point.self)
        let newPath = path[dynamicMember: \.x]
        let expected = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: [AnyPath(path)])
        XCTAssertEqual(newPath, expected)
    }

    /// Test == operation.
    func testEquality() {
        let path = ReadOnlyPath(Point.self)
        let newPath = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: [AnyPath(path)])
        let otherPath = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: [AnyPath(path)])
        XCTAssertEqual(newPath, otherPath)
    }

    /// Test fullPath.
    func testFullPath() {
        let path = ReadOnlyPath(Point.self)
        let newPath = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: [AnyPath(path)])
        let fullPath = newPath.ancestors + [AnyPath(newPath)]
        XCTAssertEqual(newPath.fullPath, fullPath)
    }

    /// Test hashable conformance.
    func testHash() {
        let val = ReadOnlyPath(Point.self).x
        let val2 = ReadOnlyPath(Point.self).x
        let values: Set<ReadOnlyPath<Point, Int>> = [val, val2]
        XCTAssertTrue(values.contains(val))
        XCTAssertEqual(values.count, 1)
    }

    /// Test path init.
    func testPathInit() {
        let path = Path(Point.self).x
        let readPath = ReadOnlyPath(path: path)
        XCTAssertEqual(path.keyPath, readPath.keyPath)
        XCTAssertEqual(path.ancestors, readPath.ancestors)
        XCTAssertFalse(readPath.isNil(point))
    }

    /// Test copied isNil function still works.
    func testPathInitOptionalValue() {
        let path = Path(OptionalPoint.self).x
        let readPath = ReadOnlyPath(path: path)
        XCTAssertEqual(path.keyPath, readPath.keyPath)
        XCTAssertEqual(path.ancestors, readPath.ancestors)
        XCTAssertTrue(readPath.isNil(optionalPoint))
        let point2 = OptionalPoint(x: 5, y: 6)
        XCTAssertFalse(readPath.isNil(point2))
    }

    /// Test dictionary subscript access.
    func testDictionaryAccess() {
        let path = ReadOnlyPath([String: String].self)["key"]
        var dict = ["A": "a"]
        XCTAssertTrue(path.isNil(dict))
        dict["key"] = "b"
        XCTAssertFalse(path.isNil(dict))
        XCTAssertEqual("b", dict[keyPath: path.keyPath])
    }

}
