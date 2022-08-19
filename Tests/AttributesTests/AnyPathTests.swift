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
        let keyPath = Path(path: \Point.x, ancestors: [])
        let anyPath = AnyPath(keyPath)
        XCTAssertFalse(anyPath._isNil(point))
        XCTAssertEqual(anyPath.value(point) as? Int, point.x)
        XCTAssertFalse(anyPath.isOptional)
        XCTAssertTrue(anyPath.ancestors.isEmpty)
        let partialPath = anyPath.partialKeyPath
        XCTAssertEqual(point[keyPath: partialPath] as? Int, point.x)
    }

    /// Test optional path init.
    func testOptionalPathInit() {
        let keyPath = Path(path: \OptionalPoint.x, ancestors: [])
        let anyPath = AnyPath(optional: keyPath)
        XCTAssertTrue(anyPath._isNil(optionalPoint))
        XCTAssertEqual(anyPath.value(optionalPoint) as? Int?, optionalPoint.x)
        XCTAssertTrue(anyPath.isOptional)
        XCTAssertTrue(anyPath.ancestors.isEmpty)
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
        let newParent = AnyPath(Path(path: \Point.y, ancestors: []))
        XCTAssertFalse(newParent.isParent(of: child))
        XCTAssertFalse(newParent.isParent(of: readChild))
        XCTAssertFalse(newParent.isParent(of: AnyPath(child)))
        XCTAssertFalse(newParent.isParent(of: AnyPath(readChild)))
    }

    /// Test isChild functions.
    func testIsChild() {
        let parent = AnyPath(Path(path: \Point.self, ancestors: []))
        let readParent = ReadOnlyPath(keyPath: \Point.self, ancestors: [])
        let newParent = AnyPath(Path(path: \Point.y, ancestors: []))
        let newReadParent = ReadOnlyPath(keyPath: \Point.y, ancestors: [])
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
        let path = AnyPath(Path(path: \Point.y, ancestors: []))
        XCTAssertTrue(path.hasValue(point))
        XCTAssertEqual(path.value(point) as? Int, point.y)
        let optionalPath = AnyPath(optional: ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: []))
        XCTAssertFalse(optionalPath.hasValue(optionalPoint))
    }

    /// Test isNil.
    func testIsNil() {
        let optionalPath = AnyPath(optional: ReadOnlyPath(keyPath: \OptionalPoint.x, ancestors: []))
        XCTAssertTrue(optionalPath.isNil(optionalPoint))
    }

    /// Test isSame functions.
    func testIsSame() {
        let readPath = ReadOnlyPath(keyPath: \Point.y, ancestors: [])
        let anyPath = AnyPath(readPath)
        XCTAssertTrue(anyPath.isSame(as: AnyPath(readPath)))
        XCTAssertTrue(anyPath.isSame(as: anyPath.partialKeyPath))
        XCTAssertTrue(anyPath.isSame(as: readPath))
        let newPath = ReadOnlyPath(keyPath: \Point.x, ancestors: [])
        XCTAssertFalse(anyPath.isSame(as: AnyPath(newPath)))
        XCTAssertFalse(anyPath.isSame(as: AnyPath(newPath).partialKeyPath))
        XCTAssertFalse(anyPath.isSame(as: newPath))
    }

}
