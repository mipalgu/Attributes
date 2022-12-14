// ValidatorFactoryComparableTests.swift 
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

/// Test class for ``ValidatorFactory`` comparable implementations.
final class ValidatorFactoryComparableTests: XCTestCase {

        /// Test between method.
    func testBetween() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().between(min: 3, max: 7)
        try factory.make(path: readPath).performValidation(5)
        try factory.make(path: readPath).performValidation(3)
        try factory.make(path: readPath).performValidation(7)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(1)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be between \(3) and \(7).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `lessThan` method.
    func testLessThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().lessThan(5)
        try factory.make(path: readPath).performValidation(4)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `lessThanEqual` method.
    func testLessThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().lessThanEqual(5)
        try factory.make(path: readPath).performValidation(4)
        try factory.make(path: readPath).performValidation(5)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(6)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be less than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `greaterThan` method.
    func testGreaterThan() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().greaterThan(5)
        try factory.make(path: readPath).performValidation(6)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(5)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `greaterThanEqual` method.
    func testGreaterThanEqual() throws {
        let readPath = ReadOnlyPath(Int.self)
        let factory = ValidatorFactory<Int>.required().greaterThanEqual(5)
        try factory.make(path: readPath).performValidation(5)
        try factory.make(path: readPath).performValidation(6)
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation(4)) {
            guard let error = $0 as? ValidationError<Int> else {
                XCTFail("Incorrect error thrown.")
                return
            }
            XCTAssertEqual(error.message, "Must be greater than or equal to \(5).")
            XCTAssertEqual(error.path, AnyPath(readPath))
        }
    }

    /// Test `empty` rule.
    func testEmpty() throws {
        let readPath = ReadOnlyPath([Int].self)
        let factory = ValidatorFactory<[Int]>.required().empty()
        try factory.make(path: readPath).performValidation([])
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([1, 2, 3])) {
            handleError($0, message: "Must be empty.")
        }
    }

    /// Test `notEmpty` rule.
    func testNotEmpty() throws {
        let readPath = ReadOnlyPath([Int].self)
        let factory = ValidatorFactory<[Int]>.required().notEmpty()
        try factory.make(path: readPath).performValidation([1, 2, 3])
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([])) {
            handleError($0, message: "Cannot be empty.")
        }
    }

    /// Test `length` rule.
    func testLength() throws {
        let readPath = ReadOnlyPath([Int].self)
        let factory = ValidatorFactory<[Int]>.required().length(3)
        try factory.make(path: readPath).performValidation([1, 2, 3])
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([1, 2])) {
            handleError($0, message: "Must have exactly 3 elements.")
        }
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([])) {
            handleError($0, message: "Must have exactly 3 elements.")
        }
    }

    /// Test `minLength` rule.
    func testMinLength() throws {
        let readPath = ReadOnlyPath([Int].self)
        let factory = ValidatorFactory<[Int]>.required().minLength(2)
        try factory.make(path: readPath).performValidation([1, 2])
        try factory.make(path: readPath).performValidation([1, 2, 3])
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([1])) {
            handleError($0, message: "Must provide at least 2 values.")
        }
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([])) {
            handleError($0, message: "Must provide at least 2 values.")
        }
    }

    /// Test `maxLength` rule.
    func testMaxLength() throws {
        let readPath = ReadOnlyPath([Int].self)
        let factory = ValidatorFactory<[Int]>.required().maxLength(3)
        try factory.make(path: readPath).performValidation([])
        try factory.make(path: readPath).performValidation([1])
        try factory.make(path: readPath).performValidation([1, 2])
        try factory.make(path: readPath).performValidation([1, 2, 3])
        XCTAssertThrowsError(try factory.make(path: readPath).performValidation([1, 2, 3, 4])) {
            handleError($0, message: "Must provide no more than 3 values.")
        }
    }

    /// Handle the case where the validator throws a validation error during a collection validation.
    /// - Parameters:
    ///   - error: The abstract Error.
    ///   - message: The message contained within the ``ValidationError``.
    ///   - path: The path contained within the ``ValidationError``
    private func handleError(
        _ error: Error, message: String, path: AnyPath<[Int]> = AnyPath(ReadOnlyPath([Int].self))
    ) {
        guard let error = error as? ValidationError<[Int]> else {
            XCTFail("Incorrect error thrown.")
            return
        }
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.path, path)
    }

}
