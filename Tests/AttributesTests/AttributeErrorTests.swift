// AttributeErrorTests.swift 
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

/// Test class for AttributeError.
final class AttributeErrorTests: XCTestCase {

    /// Test message.
    let message = "Error!"

    /// Test member initialiser.
    func testAnyPathInit() {
        let path = AnyPath(Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))]))
        let error = AttributeError(message: message, path: path)
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.path, path)
    }

    /// Test init that uses ReadOnlyPath's.
    func testReadPathInit() {
        let path = ReadOnlyPath(keyPath: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let anyPath = AnyPath(path)
        let error = AttributeError(message: message, path: path)
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.path, anyPath)
        XCTAssertEqual(anyPath.ancestors, [AnyPath(Path(Point.self))])
    }

    /// Test init that uses Path's.
    func testPathInit() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let anyPath = AnyPath(path)
        let error = AttributeError(message: message, path: path)
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.path, anyPath)
        XCTAssertEqual(anyPath.ancestors, [AnyPath(Path(Point.self))])
    }

    /// Test isError function that takes a Path.
    func testErrorPath() {
        let path = Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let error = AttributeError(message: message, path: path)
        XCTAssertTrue(error.isError(forPath: path))
    }

    /// Test isError function that takes an AnyPath.
    func testErrorAnyPath() {
        let path = AnyPath(Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))]))
        let error = AttributeError(message: message, path: path)
        XCTAssertTrue(error.isError(forPath: path))
    }

    /// Test isError function that takes a ReadOnlyPath.
    func testErrorReadOnlyPath() {
        let path = ReadOnlyPath(keyPath: \Point.x, ancestors: [AnyPath(Path(Point.self))])
        let error = AttributeError(message: message, path: path)
        XCTAssertTrue(error.isError(forPath: path))
    }

    /// Test description.
    func testDescription() {
        let path = AnyPath(Path(path: \Point.x, ancestors: [AnyPath(Path(Point.self))]))
        let error = AttributeError(message: message, path: path)
        let expected = "\(path): \(message)"
        XCTAssertEqual(error.description, expected)
    }

}
