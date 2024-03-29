// AnyPathTests.swift 
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

/// Test class for AnyPath.
final class AnyPathTests: XCTestCase {

    /// Point test data.
    let point = Point(x: 3, y: 4)

    /// Test data with nil values.
    let optionalPoint = OptionalPoint()

    /// Test path init.
    func testPathInit() {
        let ancestors = [AnyPath(Path(Point.self))]
        let keyPath = Path(path: \Point.x, ancestors: ancestors)
        let anyPath = AnyPath(keyPath)
        XCTAssertFalse(anyPath._isNil(point))
        XCTAssertEqual(anyPath.value(point) as? Int, point.x)
        XCTAssertFalse(anyPath.isOptional)
        XCTAssertEqual(anyPath.ancestors, ancestors)
        let partialPath = anyPath.partialKeyPath
        XCTAssertEqual(point[keyPath: partialPath] as? Int, point.x)
    }

    /// Test optional path init.
    func testOptionalPathInit() {
        let ancestors = [AnyPath(Path(OptionalPoint.self))]
        let keyPath = Path(path: \OptionalPoint.x, ancestors: ancestors)
        let anyPath = AnyPath(optional: keyPath)
        XCTAssertTrue(anyPath._isNil(optionalPoint))
        XCTAssertEqual(anyPath.value(optionalPoint) as? Int?, optionalPoint.x)
        XCTAssertTrue(anyPath.isOptional)
        XCTAssertEqual(anyPath.ancestors, ancestors)
        let partialPath = anyPath.partialKeyPath
        XCTAssertEqual(optionalPoint[keyPath: partialPath] as? Int, optionalPoint.x)
    }

    /// Test isParent functions.
    func testIsParent() {
        let parent = AnyPath(Path(path: \Point.self, ancestors: []))
        let child = Path<Point, Int>(path: \.x, ancestors: [parent])
        let readChild = ReadOnlyPath<Point, Int>(keyPath: \.x, ancestors: [parent])
        XCTAssertTrue(parent.isParent(of: AnyPath(child)))
        XCTAssertTrue(parent.isParent(of: AnyPath(readChild)))
        XCTAssertTrue(parent.isParent(of: child))
        XCTAssertTrue(parent.isParent(of: readChild))
        let newParent = AnyPath(Path(path: \Point.y, ancestors: [parent]))
        XCTAssertFalse(newParent.isParent(of: child))
        XCTAssertFalse(newParent.isParent(of: readChild))
        XCTAssertFalse(newParent.isParent(of: AnyPath(child)))
        XCTAssertFalse(newParent.isParent(of: AnyPath(readChild)))
        XCTAssertEqual(newParent.ancestors, [parent])
    }

    /// Test isChild functions.
    func testIsChild() {
        let parent = AnyPath(Path(path: \Point.self, ancestors: []))
        let readParent = ReadOnlyPath(keyPath: \Point.self, ancestors: [])
        let newParent = AnyPath(Path(path: \Point.y, ancestors: [parent]))
        let newReadParent = ReadOnlyPath(keyPath: \Point.y, ancestors: [parent])
        let child = Path<Point, Int>(path: \.x, ancestors: [parent])
        XCTAssertTrue(AnyPath(child).isChild(of: parent))
        XCTAssertTrue(AnyPath(child).isChild(of: readParent))
        XCTAssertTrue(AnyPath(child).isChild(of: parent.partialKeyPath))
        XCTAssertFalse(AnyPath(child).isChild(of: newParent))
        XCTAssertFalse(AnyPath(child).isChild(of: newReadParent))
        XCTAssertFalse(AnyPath(child).isChild(of: newParent.partialKeyPath))
    }

    /// Test value functions.
    func testValue() {
        let parent = AnyPath(Path(Point.self))
        let optionalParent = AnyPath(Path(OptionalPoint.self))
        let path = AnyPath(Path(path: \Point.y, ancestors: [parent]))
        XCTAssertTrue(path.hasValue(point))
        XCTAssertEqual(path.value(point) as? Int, point.y)
        let optionalPath = AnyPath(
            optional: ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: [optionalParent])
        )
        XCTAssertFalse(optionalPath.hasValue(optionalPoint))
    }

    /// Test isNil.
    func testIsNil() {
        let optionalParent = AnyPath(Path(OptionalPoint.self))
        let optionalPath = AnyPath(
            optional: ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: [optionalParent])
        )
        XCTAssertTrue(optionalPath.isNil(optionalPoint))
    }

    /// Test isSame functions.
    func testIsSame() {
        let parent = AnyPath(Path(Point.self))
        let readPath = ReadOnlyPath(keyPath: \Point.y, ancestors: [parent])
        let anyPath = AnyPath(readPath)
        XCTAssertTrue(anyPath.isSame(as: AnyPath(readPath)))
        XCTAssertTrue(anyPath.isSame(as: anyPath.partialKeyPath))
        XCTAssertTrue(anyPath.isSame(as: readPath))
        let newPath = ReadOnlyPath(keyPath: \Point.x, ancestors: [parent])
        XCTAssertFalse(anyPath.isSame(as: AnyPath(newPath)))
        XCTAssertFalse(anyPath.isSame(as: AnyPath(newPath).partialKeyPath))
        XCTAssertFalse(anyPath.isSame(as: newPath))
        XCTAssertEqual(anyPath.ancestors, newPath.ancestors)
    }

    /// Test appending method.
    func testAppending() {
        let path = AnyPath(Path(path: \Point.self, ancestors: []))
        let child = AnyPath(
            Path(path: \.x, ancestors: [AnyPath(Path(path: \Point.self, ancestors: []))])
        )
        let newPath = path.appending(child)
        XCTAssertEqual(path.value(point) as? Point, point)
        XCTAssertEqual(newPath?.value(point) as? Int, point.x)
        XCTAssertEqual(newPath?.ancestors, [AnyPath(Path(Point.self))])
    }

    /// Test changeRoot function.
    func testChangeRoot() {
        let parent = AnyPath(Path(Line.self))
        let path = AnyPath(Path(path: \Point.self, ancestors: []))
        let newRootPath = ReadOnlyPath(keyPath: \Line.point0, ancestors: [parent])
        let newPath = path.changeRoot(path: newRootPath)
        XCTAssertEqual(newPath.ancestors, [parent])
        let line = Line(point0: point, point1: Point(x: 5, y: 6))
        XCTAssertEqual(path.value(point) as? Point, point)
        XCTAssertEqual(newPath.value(line) as? Point, point)
    }

}
