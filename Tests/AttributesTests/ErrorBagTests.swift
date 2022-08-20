// ErrorBagTests.swift 
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

/// Test class for ErrorBag.
final class ErrorBagTests: XCTestCase {

    /// The bag under test.
    var bag: ErrorBag<Point> = ErrorBag()

    /// All the possible errors.
    let errors: [AttributeError<Point>] = [
        AttributeError(message: "Error0", path: AnyPath(Path(Point.self))),
        AttributeError(message: "Error1", path: AnyPath(Path(Point.self))),
        AttributeError(
            message: "Error2", path: AnyPath(Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))]))
        ),
        AttributeError(
            message: "Error3", path: AnyPath(Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))]))
        ),
        AttributeError(
            message: "Error4", path: AnyPath(Path(path: \Point.y, ancestors: [AnyPath(Path(Point.self))]))
        ),
        AttributeError(
            message: "Error5", path: AnyPath(Path(path: \Point.y, ancestors: [AnyPath(Path(Point.self))]))
        )
    ]

    /// All the x-errors.
    var xErrors: [AttributeError<Point>] {
        Array(errors[2...3])
    }

    /// All the y-errors.
    var yErrors: [AttributeError<Point>] {
        Array(errors[4...5])
    }

    /// All the point errors.
    var pointErrors: [AttributeError<Point>] {
        Array(errors[0...1])
    }

    /// Reset the bag before every test.
    override func setUp() {
        bag = ErrorBag()
    }

    /// Test the empty function clears the bag.
    func testEmpty() {
        XCTAssertTrue(bag.allErrors.isEmpty)
        let error = AttributeError(message: "Hello", path: AnyPath(Path(Point.self)))
        bag.insert(error)
        XCTAssertEqual(bag.allErrors, [error])
        bag.empty()
        XCTAssertTrue(bag.allErrors.isEmpty)
    }

    /// Test retrieve errors for the path.
    func testErrorForPath() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let anyPath = AnyPath(path)
        let readOnlyPath = path.readOnly
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        let pathErrors = bag.errors(forPath: path)
        let anyPathErrors = bag.errors(forPath: anyPath)
        let readOnlyErrors = bag.errors(forPath: readOnlyPath)
        XCTAssertEqual(pathErrors.count, anyPathErrors.count)
        XCTAssertEqual(pathErrors.count, readOnlyErrors.count)
        XCTAssertEqual(Set(pathErrors), Set(anyPathErrors))
        XCTAssertEqual(Set(pathErrors), Set(readOnlyErrors))
        let expected = xErrors
        XCTAssertEqual(pathErrors.count, expected.count)
        XCTAssertEqual(Set(pathErrors), Set(expected))
    }

    // func testErrorForPathWithAttributes() {
    //     let parentPath = AnyPath(Path(TestParent.self))
    //     let containerPath = AnyPath(Path(path: \TestParent.container, ancestors: [parentPath]))
    //     let linePath = AnyPath(Path(path: \TestParent.container.line, ancestors: [parentPath, containerPath]))
    //     var bag = ErrorBag<TestParent>()
    //     bag.insert(AttributeError(message: "Error0", path: parentPath))
    //     bag.insert(AttributeError(message: "Error1", path: containerPath))
    //     bag.insert(AttributeError(message: "Error2", path: linePath))
    // }

    /// Test retrieve errors including descendents for the path.
    func testErrorIncludingDescendents() {
        let path = Path(Point.self)
        let anyPath = AnyPath(path)
        let readOnlyPath = path.readOnly
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        let pathErrors = bag.errors(includingDescendantsForPath: path)
        let anyPathErrors = bag.errors(includingDescendantsForPath: anyPath)
        let readOnlyErrors = bag.errors(includingDescendantsForPath: readOnlyPath)
        XCTAssertEqual(pathErrors.count, anyPathErrors.count)
        XCTAssertEqual(pathErrors.count, readOnlyErrors.count)
        XCTAssertEqual(Set(pathErrors), Set(anyPathErrors))
        XCTAssertEqual(Set(pathErrors), Set(readOnlyErrors))
        let expected = errors
        XCTAssertEqual(pathErrors.count, expected.count)
        XCTAssertEqual(Set(pathErrors), Set(expected))
    }

    /// Test remove for Path.
    func testRemoveForPath() {
        let path = Path(Point.self)
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(forPath: path)
        let expected = xErrors + yErrors
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove for AnyPath.
    func testRemoveForAnyPath() {
        let path = AnyPath(Path(Point.self))
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(forPath: path)
        let expected = xErrors + yErrors
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove for ReadOnlyPath.
    func testRemoveForReadOnlyPath() {
        let path = Path(Point.self).readOnly
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(forPath: path)
        let expected = xErrors + yErrors
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove including dependencies for Path.
    func testRemoveIncludingDependenciesForPath() {
        let path = Path(Point.self)
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(includingDescendantsForPath: path)
        let expected: [AttributeError<Point>] = []
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove including dependencies for AnyPath.
    func testRemoveIncludingDependenciesForAnyPath() {
        let path = AnyPath(Path(Point.self))
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(includingDescendantsForPath: path)
        let expected: [AttributeError<Point>] = []
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove including dependencies for ReadOnlyPath.
    func testRemoveIncludingDependenciesForReadOnlyPath() {
        let path = Path(Point.self).readOnly
        errors.forEach {
            bag.insert($0)
        }
        XCTAssertEqual(Set(bag.allErrors), Set(errors))
        XCTAssertEqual(bag.allErrors.count, errors.count)
        bag.remove(includingDescendantsForPath: path)
        let expected: [AttributeError<Point>] = []
        XCTAssertEqual(expected.count, bag.allErrors.count)
        XCTAssertEqual(Set(expected), Set(bag.allErrors))
    }

    /// Test remove including dependencies remaining parents.
    func testRemoveIncludingDependencies() {
        let path = Path(path: \Line.point0, ancestors: [AnyPath(Path(Line.self))])
        var bag = ErrorBag<Line>()
        let linePath = AnyPath(Path(Line.self))
        let pointPath = AnyPath(Path(path: \Line.point0, ancestors: [linePath]))
        let coordinatePath = AnyPath(Path(path: \Line.point0.x, ancestors: [linePath, pointPath]))
        bag.insert(AttributeError(message: "Errror0", path: linePath))
        bag.insert(AttributeError(message: "Errror1", path: pointPath))
        bag.insert(AttributeError(message: "Errror2", path: coordinatePath))
        bag.remove(includingDescendantsForPath: path)
        let expected = [AttributeError(message: "Errror0", path: linePath)]
        XCTAssertEqual(bag.allErrors, expected)
    }

}

/// Helper struct for testing Attribute data.
private struct AttributeTestContainer: Equatable, Hashable {

    /// A line attribute.
    var line: LineAttribute

}

/// A parent struct for testing ErrorBag.
private struct TestParent: Equatable, Hashable {

    /// A container property.
    var container: BlockAttribute

}

/// Equatable and Hashable conformance for AttributeError.
extension AttributeError: Equatable, Hashable where Root: Hashable {

    /// Equatable conformance.
    /// - Parameters:
    ///   - lhs: The lhs of the operator.
    ///   - rhs: The rhs of the operator.
    /// - Returns: Whether lhs == rhs.
    public static func == (lhs: AttributeError, rhs: AttributeError) -> Bool {
        lhs.message == rhs.message && lhs.path == rhs.path
    }

    /// Hashable conformance.
    /// - Parameter hasher: The hasher to use.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(path)
    }

}
