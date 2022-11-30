// ArrayPathTests.swift 
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

/// Test class for subscript and each method extensions on custom paths.
final class ArrayPathTests: XCTestCase {

    /// Test subscript operator correctly appends path and updates ancestors for nonmutating collection.
    func testReadOnlySubscriptNonMutatingCollection() {
        let pointArray = ReadOnlyPath(NonMutatingPoint.self)
        let point0 = pointArray[0]
        let expected = getReadPath(to: NonMutatingPoint.self)
        XCTAssertEqual(point0, expected)
    }

    /// Test isNil for ReadOnlyPath array subscripts.
    func testReadIsNilMutatingCollection() throws {
        let path = ReadOnlyPath([Point?].self)
        let points = [nil, nil, Point(x: 1, y: 2)]
        XCTAssertTrue(path[0].isNil(points))
        XCTAssertTrue(path[4].isNil(points))
        XCTAssertTrue(path[-1].isNil(points))
        XCTAssertFalse(path[2].isNil(points))
    }

    /// Test isNil for Path array subscripts.
    func testPathIsNilMutatingCollection() throws {
        let path = Path([Point?].self)
        let points = [nil, nil, Point(x: 1, y: 2)]
        XCTAssertTrue(path[0].isNil(points))
        XCTAssertTrue(path[4].isNil(points))
        XCTAssertTrue(path[-1].isNil(points))
        XCTAssertFalse(path[2].isNil(points))
    }

    /// Test subscript operator correctly appends path and updates ancestors for mutating collection.
    func testReadOnlySubscriptMutatingCollection() {
        // We get WritableKeyPath from accessing an Array through a KeyPath since Array is a
        // MutableCollection. You can verify this with type(of: path).
        let path: KeyPath<[Point], [Point]> = \[Point].self
        let pointArray = ReadOnlyPath(keyPath: path, ancestors: [])
        let point0: ReadOnlyPath<[Point], Point> = pointArray[0]
        let expected = getMutatingReadPath(to: [Point].self)
        XCTAssertEqual(point0, expected)
    }

    /// Test subscript operator for PathProtocol.
    func testPathSubscript() {
        let pointArray = Path([Point].self)
        let point0: Path<[Point], Point> = pointArray[0]
        let expected = getPath(to: [Point].self)
        XCTAssertEqual(point0, expected)
    }

    /// Test path `each` method applies function to all elements.
    func testPathEach() {
        let path = Path([Point].self)
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
        let f = path.each { index, pPath in
            (index, points[keyPath: pPath.keyPath])
        }
        let result = f(points)
        let expected = [(0, Point(x: 1, y: 2)), (1, Point(x: 3, y: 4))]
        guard result.count == expected.count else {
            XCTFail("Incorrect result.")
            return
        }
        result.forEach { index, point in
            let exp = expected[index]
            XCTAssertEqual(exp.0, index)
            XCTAssertEqual(exp.1, point)
        }
    }

    /// Test each method on ``ValidationPath`` where `Value` is a `MutableCollection`.
    func testValidationPathMutableEach() throws {
        let path = ValidationPath(path: Path([Point].self))
        let validator = NullValidator<[Point]>()
        let f = path.each { _, _ in
            validator
        }
        let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
        XCTAssertEqual(validator.timesCalled, 0)
        XCTAssertNil(validator.lastParameter)
        try f.performValidation(points)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.parameters, [points, points])
    }

    /// Test each method on ``ValidationPath`` where `Value` is a `Collection`.
    func testValidationPathEach() throws {
        let path = ValidationPath(path: Path([NonMutatingPoint].self))
        let validator = NullValidator<[NonMutatingPoint]>()
        let f = path.each { _, _ in
            validator
        }
        let points = [NonMutatingPoint(x: 1, y: 2), NonMutatingPoint(x: 3, y: 4)]
        XCTAssertEqual(validator.timesCalled, 0)
        XCTAssertNil(validator.lastParameter)
        try f.performValidation(points)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.parameters, [points, points])
    }

    /// Test keyPath semantics.
    func testKeyPath() {
        /// Get keyPath
        func path<R, C: MutableCollection>(
            from source: ReadOnlyPath<R, C>,
            toIndex index: C.Index
        ) -> ReadOnlyPath<R, C.Element> where C.Index: BinaryInteger {
            ReadOnlyPath(
                keyPath: source.keyPath.appending(path: \.[index]),
                ancestors: source.ancestors + [AnyPath(source)]
            )
        }
        let basePath = ReadOnlyPath([Int].self)
        let expectedPath = path(from: basePath, toIndex: 0)
        let result = basePath[0]
        XCTAssertEqual(expectedPath, result)
    }

    /// Creates a ReadOnlyPath for a mutable collection.
    /// - Parameter type: Root type.
    /// - Returns: ReadOnlyPath to the first element in `type`.
    private func getReadPath<T>(
        to type: T.Type
    ) -> ReadOnlyPath<T, T.Element> where T: Collection, T.Index: BinaryInteger {
        ReadOnlyPath(keyPath: (\T.self).appending(path: \.[0]), ancestors: [AnyPath(ReadOnlyPath(T.self))])
    }

    /// Creates a ReadOnlyPath for a collection.
    /// - Parameter type: Root type.
    /// - Returns: ReadOnlyPath to the first element in `type`.
    private func getMutatingReadPath<T>(
        to type: T.Type
    ) -> ReadOnlyPath<T, T.Element> where T: MutableCollection, T.Index: BinaryInteger {
        ReadOnlyPath(keyPath: (\T.self).appending(path: \.[0]), ancestors: [AnyPath(ReadOnlyPath(T.self))])
    }

    /// Creates a Path for a collection.
    /// - Parameter type: Root type.
    /// - Returns: Path to the first element in `type`.
    private func getPath<T>(
        to type: T.Type
    ) -> Path<T, T.Element> where T: MutableCollection, T.Index: BinaryInteger {
        Path(path: (\T.self).appending(path: \.[0]), ancestors: [AnyPath(ReadOnlyPath(T.self))])
    }

}

/// `CustomStringConvertible` conformance.
extension ReadOnlyPath: CustomStringConvertible {

    /// Provide keyPath definition-style description.
    public var description: String {
        "\\" + (self.ancestors).map {
            "\($0.targetType)"
        }
        .joined(separator: ".") + " -> \(keyPath)"
    }

}

// extension KeyPath: CustomStringConvertible  {

//     public var description: String {
//         "\(type(of: self))(\(Self.rootType) -> \(Self.valueType))"
//     }

// }
