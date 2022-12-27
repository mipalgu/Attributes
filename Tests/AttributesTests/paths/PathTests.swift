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
import AttributesTestUtils
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
        let path = Path(path: keyPath, ancestors: [AnyPath(Path(OptionalPoint.self))], isNil: isNil)
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(timesCalled, 1)
        XCTAssertEqual(pointCalled, optionalPoint)
        XCTAssertEqual(keyPath, path.keyPath)
        XCTAssertEqual(path.ancestors, [AnyPath(Path(OptionalPoint.self))])
        let typePath = Path(Point.self)
        let ancestors = [AnyPath(typePath)]
        let newPath = Path<Point, Int>(path: \.x, ancestors: ancestors)
        XCTAssertEqual(newPath.keyPath, \Point.x)
        XCTAssertEqual(newPath.ancestors, ancestors)
    }

    /// Test init that points to a non-optional value.
    func testNonOptionalInit() {
        let keyPath: WritableKeyPath<Point, Int> = \Point.x
        let path = Path(path: keyPath, ancestors: [AnyPath(Path(Point.self))])
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertFalse(path.isNil(point))
        XCTAssertEqual(path.ancestors, [AnyPath(Path(Point.self))])
    }

    /// Test init that is used for optional values.
    func testOptionalInit() {
        let keyPath = \OptionalPoint.x
        let path = Path(path: keyPath, ancestors: [AnyPath(Path(OptionalPoint.self))])
        XCTAssertTrue(path.isNil(optionalPoint))
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertEqual(path.ancestors, [AnyPath(Path(OptionalPoint.self))])
    }

    /// Test isNil still works when appending members.
    func testIsNilAppendingPath() {
        let path = Path(OptionalPoint.self).x
        XCTAssertTrue(path.isNil(OptionalPoint()))
    }

    /// Test isNil function when ancestor is nil.
    func testIsNilForNilAncestor() {
        let path = Path(Optional<OptionalPoint>.self)
        XCTAssertTrue(path.isNil(nil))
        let newPath = path.wrappedValue.x
        XCTAssertTrue(newPath.isNil(nil))
    }

    /// Test isNil for nested arrays.
    func testIsNilForArrayAncestor() {
        let path = Path([[Point]].self)[1][0]
        XCTAssertTrue(path.isNil([[Point(x: 1, y: 2)]]))
        XCTAssertFalse(path.isNil([[Point(x: 1, y: 2)], [Point(x: 3, y: 4)]]))
    }

    /// Test isNil for new root.
    func testIsNilForChangedRoot() {
        let path = Path(OptionalPoint.self).x
        let rootPath = Path([OptionalPoint].self)[0]
        let newPath = path.changeRoot(path: rootPath)
        XCTAssertTrue(newPath.isNil([OptionalPoint()]))
    }

    /// Test isNil for multiple optional paths.
    func testIsNilForAppendedOptionalPath() {
        let path = Path(Optional<OptionalPoint>.self).wrappedValue.x.wrappedValue
        XCTAssertTrue(path.isNil(OptionalPoint()))
        XCTAssertTrue(path.isNil(nil))
        XCTAssertFalse(path.isNil(OptionalPoint(x: 1, y: 2)))
    }

    /// Check isNil works when changing roots with nil ancestors.
    func testIsNilWithNilAncestorAfterChangingRoot() {
        let path = Path([Point].self)[0].x
        let path2 = Path([[Point]].self)[1]
        let newPath = path.changeRoot(path: path2)
        let root = [[Point(x: 1, y: 2)]]
        let isNil = newPath.isNil(root)
        XCTAssertTrue(isNil)
        let root2 = root + [[Point(x: 3, y: 4)]]
        XCTAssertFalse(newPath.isNil(root2))
    }

    /// Test isNil for optional append.
    func testIsNilForOptionalAppend() {
        let path = Path([Point].self).first
        XCTAssertTrue(path.isNil([]))
    }

    /// Test isNil for optional append containing nil ancestor.
    func testIsNilForOptionalAppendWithNilAncestor() {
        let path = Path([[Point]].self)[1].first
        XCTAssertTrue(path.isNil([]))
        XCTAssertTrue(path.isNil([[]]))
        XCTAssertTrue(path.isNil([[Point(x: 1, y: 2)], []]))
        XCTAssertTrue(path.isNil([[], []]))
        XCTAssertFalse(path.isNil([[], [Point(x: 1, y: 2)]]))
    }

    /// Test isNil function works when using a keypath to an optional value.
    func testIsNilOptionalKeyPathCreationWithoutAncestors() {
        let path = Path(path: \Optional<Point>.self, ancestors: [])
        XCTAssertTrue(path.isNil(nil))
        XCTAssertFalse(path.isNil(Point(x: 1, y: 2)))
    }

    /// Test type initialiser.
    func testTypeInit() {
        let keyPath = \Point.self
        let path = Path(Point.self)
        XCTAssertEqual(path.keyPath, keyPath)
        XCTAssertTrue(path.ancestors.isEmpty)
    }

    /// Test readOnly property.
    func testReadOnly() {
        let readPath = ReadOnlyPath(Point.self)
        let path = Path(Point.self)
        XCTAssertEqual(path.readOnly, readPath)
        XCTAssertTrue(path.readOnly.ancestors.isEmpty)
    }

    /// Test appending methods and subscript operations.
    func testAppending() {
        let path = Path(Point.self)
        let keyPath: KeyPath<Point, Int> = \.x
        let writePath: WritableKeyPath<Point, Int> = \.x
        let appendPath = Path(path: writePath, ancestors: [AnyPath(path)])
        let expected = Path(path: \Point.x, ancestors: [AnyPath(path)])
        XCTAssertEqual(expected.readOnly, path[dynamicMember: keyPath])
        XCTAssertEqual(expected, path[dynamicMember: writePath])
        XCTAssertEqual(expected, path.appending(path: appendPath))
    }

    /// Test changeRoot method.
    func testChangeRoot() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let linePath = Path(path: \Line.point0, ancestors: [AnyPath(Path(Line.self))])
        let newPath = path.changeRoot(path: linePath)
        let expected = Path(path: \Line.point0.x, ancestors: [
            AnyPath(Path(Line.self)),
            AnyPath(Path(path: \Line.point0, ancestors: [AnyPath(Path(Line.self))]))
        ])
        XCTAssertEqual(newPath, expected)
    }

    /// Test == operator.
    func testEquality() {
        let keyPath = \Point.x
        let ancestors = [AnyPath(Path(path: \Point.self, ancestors: []))]
        let newPath = Path(path: keyPath, ancestors: ancestors)
        let path2 = Path(path: keyPath, ancestors: ancestors)
        XCTAssertEqual(newPath, path2)
    }

    /// Test fullPath.
    func testFullPath() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let fullPath = path.ancestors + [AnyPath(path)]
        XCTAssertEqual(path.fullPath, fullPath)
    }

    /// Test isAncestorOrSame function for ancestor case.
    func testIsAncestorOrSame() {
        let pointPath = Path(Point.self)
        let path = Path(path: \Point.x, ancestors: [AnyPath(pointPath)])
        XCTAssertTrue(pointPath.isAncestorOrSame(of: AnyPath(path), in: point))
    }

    /// Test isAncestorOrSame for child.
    func testIsAncestorOrSameForChild() {
        let pointPath = Path(Point.self)
        let path = Path(Point.self).x.bigEndian
        XCTAssertTrue(pointPath.isAncestorOrSame(of: AnyPath(path), in: point))
    }

    /// Test isAncestorOrSame returns false for parent path.
    func testIsAncestorOrSameForParent() {
        let xPath = Path(Point.self).x
        let pointPath = Path(Point.self)
        XCTAssertFalse(xPath.isAncestorOrSame(of: AnyPath(pointPath), in: point))
    }

    /// Test same path in isAncestorOrSame function.
    func testIsSame() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        XCTAssertTrue(path.isAncestorOrSame(of: AnyPath(path), in: point))
    }

    /// Test paths returns self in an array.
    func testPaths() {
        let pointPath = Path(Point.self)
        let point = Point(x: 3, y: 4)
        XCTAssertEqual(pointPath.paths(in: point), [pointPath])
        let xPath = Path(path: \Point.x, ancestors: [AnyPath(pointPath)])
        XCTAssertEqual(xPath.paths(in: point), [xPath])
        let pointArray = Path([Point].self)
        let point0 = Path(path: \[Point][0], ancestors: [AnyPath(pointArray)])
        let point0X = Path(path: \[Point][0].x, ancestors: [AnyPath(pointArray), AnyPath(point0)])
        XCTAssertEqual(point0X.paths(in: [point, point]), [point0X])
        XCTAssertEqual(point0X.paths(in: [point]), [point0X])
    }

    /// Test appending method.
    func testAppendingPoint() {
        let pointArray = Path([Point].self)
        let pointPath = Path(path: \[Point][0], ancestors: [AnyPath(pointArray)])
        let pointXPath = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let expectedPath = Path(path: \[Point][0].x, ancestors: [AnyPath(pointArray), AnyPath(pointPath)])
        XCTAssertEqual(pointPath.appending(path: pointXPath), expectedPath)
    }

    /// Test toNewRoot method correctly prepends path.
    func testToNewRoot() {
        let path = Path(Point.self)
        let xPath = Path(path: \Point.x, ancestors: [AnyPath(path)])
        let pointArray = Path([Point].self)
        let point0 = Path(path: \[Point][0], ancestors: [AnyPath(pointArray)])
        let newPath = xPath.changeRoot(path: point0)
        let expected = Path(path: \[Point][0].x, ancestors: [AnyPath(pointArray), AnyPath(point0)])
        XCTAssertEqual(newPath, expected)
    }

    /// Test hashable conformance.
    func testHash() {
        let val = Path(Point.self).x
        let val2 = Path(Point.self).x
        let values: Set<Path<Point, Int>> = [val, val2]
        XCTAssertTrue(values.contains(val))
        XCTAssertEqual(values.count, 1)
    }

    /// Test validate creates correct validator.
    func testValidate() throws {
        let path = Path(Point.self)
        let validator = NullValidator<Point>()
        let newValidator = path.validate { _ in validator }
        let root = Point(x: 1, y: 2)
        try newValidator.performValidation(root)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, root)
    }

    /// Test trigger creates correct trigger.
    func testTrigger() throws {
        let path = Path(Point.self)
        let trigger = MockTrigger<Point>(result: .success(true))
        let newTrigger = path.trigger {
            $0
            trigger
        }
        var root = Point(x: 1, y: 2)
        XCTAssertTrue(try newTrigger.performTrigger(&root, for: AnyPath(path)).get())
        XCTAssertEqual(trigger.timesCalled, 1)
        XCTAssertEqual(trigger.pathPassed, AnyPath(path))
        XCTAssertEqual(trigger.rootPassed, root)
    }

    /// Test dictionary subscript access.
    func testDictionaryAccess() {
        let path = Path([String: String].self)["key"]
        var dict = ["A": "a"]
        XCTAssertTrue(path.isNil(dict))
        dict["key"] = "b"
        XCTAssertFalse(path.isNil(dict))
        XCTAssertEqual("b", dict[keyPath: path.keyPath])
    }

}
