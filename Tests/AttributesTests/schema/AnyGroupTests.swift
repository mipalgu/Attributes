// AnyGroupTests.swift
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

/// Test class for ``AnyGroup``.
final class AnyGroupTests: XCTestCase {

    /// Test data.
    var data = EmptyModifiable(
        attributes: [AttributeGroup(name: "Attributes")],
        metaData: [],
        errorBag: ErrorBag()
    ) { _ in
        .success(false)
    }

    /// Path to the root.
    let path = AnyPath(Path(EmptyModifiable.self))

    /// Typed group.
    var mock = MockGroup()

    /// The group under test.
    var group: AnyGroup<EmptyModifiable> {
        AnyGroup(mock)
    }

    /// Create group before every test.
    override func setUp() {
        mock = MockGroup()
        data = EmptyModifiable(
            attributes: [AttributeGroup(name: "Attributes")],
            metaData: [],
            errorBag: ErrorBag()
        ) { _ in
            .success(false)
        }
    }

    /// Test properties are set correctly.
    func testProperties() {
        let group = AnyGroup(mock)
        guard let base = group.base as? MockGroup else {
            XCTFail("Failed to get base.")
            return
        }
        XCTAssertEqual(base, mock)
        XCTAssertEqual(group.pathToFields, mock.pathToFields)
        XCTAssertEqual(group.pathToAttributes, mock.pathToAttributes)
        XCTAssertEqual(group.properties, mock.properties)
    }

    /// Test triggers property matches mock trigger.
    func testTriggersMatch() throws {
        XCTAssertFalse(try group.triggers.performTrigger(&data, for: path).get())
        let mockTrigger = mock.mockTriggers
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, path)
        XCTAssertEqual(mockTrigger.rootPassed, data)
    }

    /// Test allTriggers property matches mock trigger.
    func testAllTriggersMatch() throws {
        XCTAssertFalse(try group.allTriggers.performTrigger(&data, for: path).get())
        let mockTrigger = mock.mockTriggers
        XCTAssertEqual(mockTrigger.timesCalled, 1)
        XCTAssertEqual(mockTrigger.pathPassed, path)
        XCTAssertEqual(mockTrigger.rootPassed, data)
    }

    /// Test groupValidation matches mock validator.
    func testGroupValidation() throws {
        try group.groupValidation.performValidation(data.attributes[0])
        let validator = mock.groupValidator
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, data.attributes[0])
    }

    /// Test rootValidation matches mock validator.
    func testRootValidation() throws {
        try group.rootValidation.performValidation(data)
        let validator = mock.rootValidator
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, data)
    }

    /// Test propertiesValidator matches mock validator.
    func testPropertyValidator() throws {
        try group.propertiesValidator.performValidation(data.attributes[0])
        let validator = mock.propertyValidator
        XCTAssertEqual(validator.timesCalled, 1)
        XCTAssertEqual(validator.lastParameter, data.attributes[0])
    }

    /// Test path access correct member.
    func testPathAccessesSameMember() {
        let paths = group.path.paths(in: data)
        XCTAssertEqual(paths.count, 1)
        guard let groupPath = paths.first else {
            XCTFail("failed to get path.")
            return
        }
        let member = data[keyPath: groupPath.keyPath]
        XCTAssertEqual(member, data.attributes[0])
    }

}
