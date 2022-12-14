// ValidationPushProtocolComparableTests.swift
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

/// Test class for ``ValidationPushProtocol`` methods where Value is `Equatable`, `Hashable`, or `Comparable`.
final class ValidationPushProtocolComparableTests: XCTestCase {

    /// Test equals function.
    func testEquals() throws {
        let readPath = ReadOnlyPath(EquatablePoint.self)
        let point = EquatablePoint(x: 1, y: 2)
        let validator = NullValidator<EquatablePoint>()
        let path = TestValidationPath(path: readPath).push {root, _ in
            try validator.performValidation(root)
        }
        .equals(point)
        try path.performValidation(point)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, point)
        let point2 = EquatablePoint(x: 2, y: 3)
        XCTAssertThrowsError(try path.performValidation(point2)) {
            guard let error = $0 as? AttributeError<EquatablePoint> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(point).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, point2)
    }

    /// Test notEquals function.
    func testNotEquals() throws {
        let readPath = ReadOnlyPath(EquatablePoint.self)
        let point = EquatablePoint(x: 1, y: 2)
        let point2 = EquatablePoint(x: 2, y: 3)
        let validator = NullValidator<EquatablePoint>()
        let path = TestValidationPath(path: readPath).push {root, _ in
            try validator.performValidation(root)
        }
        .notEquals(point)
        try path.performValidation(point2)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, point2)
        XCTAssertThrowsError(try path.performValidation(point)) {
            guard let error = $0 as? AttributeError<EquatablePoint> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must not equal \(point).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, point)
    }

    /// Test equalsTrue method.
    func testEqualsTrue() throws {
        let readPath = ReadOnlyPath(Bool.self)
        let value = true
        let notValue = false
        let validator = NullValidator<Bool>()
        let path = TestValidationPath(path: readPath).push {root, _ in
            try validator.performValidation(root)
        }
        .equalsTrue()
        try path.performValidation(value)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, value)
        XCTAssertThrowsError(try path.performValidation(notValue)) {
            guard let error = $0 as? AttributeError<Bool> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(value).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, notValue)
    }

    /// Test equalsFalse method.
    func testEqualsFalse() throws {
        let readPath = ReadOnlyPath(Bool.self)
        let value = true
        let notValue = false
        let validator = NullValidator<Bool>()
        let path = TestValidationPath(path: readPath).push {root, _ in
            try validator.performValidation(root)
        }
        .equalsFalse()
        try path.performValidation(notValue)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, notValue)
        XCTAssertThrowsError(try path.performValidation(value)) {
            guard let error = $0 as? AttributeError<Bool> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must equal \(notValue).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, value)
    }

    /// Test between method.
    func testBetween() throws {
        let readPath = ReadOnlyPath(Int.self)
        let validator = NullValidator<Int>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .between(min: 3, max: 7)
        try path.performValidation(5)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 5)
        try path.performValidation(3)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, 3)
        try path.performValidation(7)
        XCTAssertEqual(validator.timesCalled, 3)
        XCTAssertEqual(validator.lastParameter, 7)
        XCTAssertThrowsError(try path.performValidation(1)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be between \(3) and \(7).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 4)
        XCTAssertEqual(validator.lastParameter, 1)
    }

    /// Test `lessThan` method.
    func testLessThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let validator = NullValidator<Int>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .lessThan(5)
        try path.performValidation(4)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 4)
        XCTAssertThrowsError(try path.performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than \(5).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, 5)
    }

    /// Test `lessThanEqual` method.
    func testLessThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let validator = NullValidator<Int>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .lessThanEqual(5)
        try path.performValidation(4)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 4)
        try path.performValidation(5)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, 5)
        XCTAssertThrowsError(try path.performValidation(6)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 3)
        XCTAssertEqual(validator.lastParameter, 6)
    }

    /// Test `greaterThan` method.
    func testGreaterThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let validator = NullValidator<Int>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .greaterThan(5)
        try path.performValidation(6)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 6)
        XCTAssertThrowsError(try path.performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than \(5).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, 5)
    }

    /// Test `greaterThanEqual` method.
    func testGreaterThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let validator = NullValidator<Int>()
        let path = TestValidationPath(path: readPath).push { root, _ in
            try validator.performValidation(root)
        }
        .greaterThanEqual(5)
        try path.performValidation(5)
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, 5)
        try path.performValidation(6)
        XCTAssertEqual(validator.timesCalled, 2)
        XCTAssertEqual(validator.lastParameter, 6)
        XCTAssertThrowsError(try path.performValidation(4)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(path.path))
        }
        XCTAssertEqual(validator.timesCalled, 3)
        XCTAssertEqual(validator.lastParameter, 4)
    }

}
