// ValidationPushProtocolStringTests.swift
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

/// Test class for ``ValidationPushProtocol`` where the Value is a String.
final class ValidationPushProtocolStringTests: XCTestCase {

    /// A path to a string.
    let readPath = ReadOnlyPath(String.self)

    /// A validator tracking parameters passed.
    var validator = NullValidator<String>()

    /// A test validator under test.
    var testValidator: Validator<ReadOnlyPath<String, String>> {
        TestValidationPath(path: readPath).push { root, _ in
            try self.validator.performValidation(root)
        }
    }

    /// Initialise properties before every test case.
    override func setUp() {
        validator = NullValidator()
    }

    /// Test alpha rule.
    func testAlpha() throws {
        let path = testValidator.alpha()
        try path.performValidation("abc")
        try path.performValidation("aBc")
        try path.performValidation("")
        XCTAssertThrowsError(try path.performValidation("abc1")) {
            handleError($0, message: "Must be alphabetic.")
        }
    }

    /// Test `alphaDash` rule.
    func testAlphaDash() throws {
        let path = testValidator.alphadash()
        try path.performValidation("abc")
        try path.performValidation("aBc")
        try path.performValidation("")
        try path.performValidation("abc123")
        try path.performValidation("123")
        try path.performValidation("abc_123")
        try path.performValidation("abc-123")
        XCTAssertThrowsError(try path.performValidation("abc*!")) {
            handleError($0, message: "Must be alphabetic with underscores and dashes allowed.")
        }
    }

    /// Test `alphaFirst` rule.
    func testAlphaFirst() throws {
        let path = testValidator.alphafirst()
        try path.performValidation("abc")
        try path.performValidation("aBc")
        try path.performValidation("abc123")
        try path.performValidation("abc_123")
        try path.performValidation("abc-123")
        try path.performValidation("")
        try path.performValidation("abc*!")
        XCTAssertThrowsError(try path.performValidation("*!abc")) {
            handleError($0, message: "First Character must be alphabetic.")
        }
        XCTAssertThrowsError(try path.performValidation("123")) {
            handleError($0, message: "First Character must be alphabetic.")
        }
    }

    /// Test `alphanumeric` rule.
    func testAlphaNumeric() throws {
        try doTest(
            accepted: [
                "123",
                "abc123",
                "aBc",
                "",
                "abc"
            ],
            errorsValues: [
                "abc*!",
                "*!abc",
                "abc-123",
                "abc_123"
            ],
            path: testValidator.alphanumeric(),
            message: "Must be alphanumeric."
        )
    }

    /// Test `alphaUnderscore` rule.
    func testAlphaUnderscore() throws {
        try doTest(
            accepted: [
                "123",
                "abc123",
                "aBc",
                "",
                "abc",
                "abc_123"
            ],
            errorsValues: [
                "abc*!",
                "*!abc",
                "abc-123"
            ],
            path: testValidator.alphaunderscore(),
            message: "Must be alphabetic with underscores allowed."
        )
    }

    /// Test `alphaunderscorefirst` rule.
    func testAlphaUnderscoreFirst() throws {
        try doTest(
            accepted: [
                "abc123",
                "aBc",
                "",
                "abc",
                "abc_123",
                "_abc123*!",
                "abc*!",
                "abc-123"
            ],
            errorsValues: [
                "123",
                "*!abc"
            ],
            path: testValidator.alphaunderscorefirst(),
            message: "First Character must be alphabetic or an underscore."
        )
    }

    /// Test `numeric` rule.
    func testNumeric() throws {
        try doTest(
            accepted: [
                "123",
                ""
            ],
            errorsValues: [
                "abc123",
                "aBc",
                "abc",
                "abc_123",
                "_abc123*!",
                "abc*!",
                "abc-123",
                "*!abc"
            ],
            path: testValidator.numeric(),
            message: "Must be numeric."
        )
    }

    // swiftlint:disable inclusive_language

    /// Test blacklist.
    func testBlacklist() throws {
        let banned: Set<String> = [
            "abc123",
            "aBc",
            "",
            "abc",
            "abc_123",
            "_abc123*!",
            "abc*!",
            "abc-123"
        ]
        let path = testValidator.blacklist(banned)
        try path.performValidation("123")
        try path.performValidation("!*abc")
        XCTAssertThrowsError(try path.performValidation("abc*!")) {
            handleError($0, message: "abc*! is a banned word.")
        }
    }

    /// Test `whitelist` rule.
    func testWhitelist() throws {
        let allowed: Set<String> = [
            "abc123",
            "aBc",
            "",
            "abc",
            "abc_123",
            "_abc123*!",
            "abc*!",
            "abc-123"
        ]
        let path = testValidator.whitelist(allowed)
        try path.performValidation("")
        try path.performValidation("abc*!")
        XCTAssertThrowsError(try path.performValidation("*!abc")) {
            handleError(
                $0, message: "*!abc is not valid, you must use pre-existing words. Candidates: \(allowed)"
            )
        }
    }

    /// Test `greyList` rule.
    func testGreyList() throws {
        let allowed: Set<String> = [
            "abc123",
            "aBc",
            "abc",
            "abc_123",
            "_abc123*!",
            "abc*!",
            "abc-123",
            "123"
        ]
        let path = testValidator.greyList(allowed)
        try path.performValidation("abcd")
        try path.performValidation("1234")
        XCTAssertThrowsError(try path.performValidation("xyz")) {
            handleError(
                $0, message: "xyz is not valid, it must contain pre-existing words. Candidates: \(allowed)"
            )
        }
    }

    // swiftlint:enable inclusive_language

    /// Perform the test function.
    /// - Parameters:
    ///   - accepted: The values that pass validation.
    ///   - errorsValues: The values that fail validation.
    ///   - path: The validator performing the validation.
    ///   - message: The error message when failing validation.
    private func doTest(
        accepted: [String],
        errorsValues: [String],
        path: Validator<ReadOnlyPath<String, String>>,
        message: String
    ) throws {
        try accepted.forEach {
            try path.performValidation($0)
        }
        try errorsValues.forEach { val in
            XCTAssertThrowsError(try path.performValidation(val)) {
                handleError($0, message: message)
            }
        }
    }

    /// Handle the case where the validator throws a validation error during a string validation.
    /// - Parameters:
    ///   - error: The abstract Error.
    ///   - message: The message contained within the ``ValidationError``.
    ///   - path: The path contained within the ``ValidationError``
    private func handleError(
        _ error: Error, message: String, path: AnyPath<String> = AnyPath(ReadOnlyPath(String.self))
    ) {
        guard let error = error as? ValidationError<String> else {
            XCTFail("Incorrect error thrown.")
            return
        }
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.path, path)
    }

}
