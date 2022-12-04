// EmptyModifiableTests.swift 
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

/// Test class for ``EmptyModifiable``.
final class EmptyModifiableTests: XCTestCase {

    /// Stored attributes.
    var attributes = [
        AttributeGroup(
            name: "A",
            fields: [Field(name: "I", type: .line)],
            attributes: ["I": .line("i")],
            metaData: ["I": .bool(true)]
        )
    ]

    /// Stored metadata.
    var metaData = [
        AttributeGroup(
            name: "A",
            fields: [Field(name: "I", type: .line)],
            attributes: ["I": .line("i")],
            metaData: [:]
        )
    ]

    /// Stored errors.
    var errorBag = ErrorBag<EmptyModifiable>()

    /// Modifiable under test.
    lazy var modifiable = EmptyModifiable(attributes: attributes, metaData: metaData, errorBag: errorBag)

    /// A path tot he attributes array.
    let attributePath = Path(EmptyModifiable.self).attributes

    /// Initialise modifiable before every test.
    override func setUp() {
        attributes = [
            AttributeGroup(
                name: "A",
                fields: [Field(name: "I", type: .line)],
                attributes: ["I": .line("i")],
                metaData: ["I": .bool(true)]
            )
        ]
        metaData = [
            AttributeGroup(
                name: "A",
                fields: [Field(name: "I", type: .line)],
                attributes: ["I": .line("i")],
                metaData: ["I": .bool(true)]
            )
        ]
        errorBag = ErrorBag<EmptyModifiable>()
        modifiable = EmptyModifiable(attributes: attributes, metaData: metaData, errorBag: errorBag)
    }

    /// Test init sets stored properties correctly.
    func testInit() {
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test add items append correctly.
    func testAddItem() throws {
        let newGroup = AttributeGroup(name: "New Group!")
        XCTAssertFalse(try modifiable.addItem(newGroup, to: attributePath).get())
        XCTAssertEqual(modifiable.attributes, attributes + [newGroup])
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test addItem fails when pointing to a nil path.
    func testAddItemNilPath() throws {
        guard
            case .failure(let error) = modifiable.addItem(
                Field(name: "New", type: .line), to: attributePath[5].fields
            )
        else {
            XCTFail("Add item passed for empty attributes array.")
            return
        }
        XCTAssertEqual(error.message, "Invalid path.")
        XCTAssertEqual(error.path, AnyPath(attributePath[5].fields))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test moveItem moves items correctly.
    func testMoveItem() throws {
        let newGroup = AttributeGroup(name: "New Group!")
        XCTAssertFalse(try modifiable.addItem(newGroup, to: attributePath).get())
        XCTAssertEqual(modifiable.attributes, attributes + [newGroup])
        XCTAssertFalse(
            try modifiable.moveItems(table: attributePath, from: [0], to: 2).get()
        )
        XCTAssertEqual(modifiable.attributes, [newGroup] + attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test move returns correct error when source indexes are invalid.
    func testMoveItemInvalidSourceIndexes() {
        guard case .failure(let error) = modifiable.moveItems(table: attributePath, from: [-1], to: 2) else {
            XCTFail("Successful call for invalid indexes.")
            return
        }
        XCTAssertEqual(error.message, "Invalid source index.")
        XCTAssertEqual(error.path, AnyPath(attributePath[-1]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test move returns correct error when destination index is invalid.
    func testMoveItemInvalidDestination() {
        guard case .failure(let error) = modifiable.moveItems(table: attributePath, from: [0], to: -1) else {
            XCTFail("Successful call for invalid indexes.")
            return
        }
        XCTAssertEqual(error.message, "Invalid destination index.")
        XCTAssertEqual(error.path, AnyPath(attributePath[-1]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test moveItem with destination larger than count.
    func testMoveItemFarDestination() throws {
        guard case .failure(let error) = modifiable.moveItems(table: attributePath, from: [0], to: 100) else {
            XCTFail("Successful call for invalid destination.")
            return
        }
        XCTAssertEqual(error.message, "Invalid destination index.")
        XCTAssertEqual(error.path, AnyPath(attributePath[100]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test delete correctly removes item.
    func testDelete() throws {
        let newGroup = AttributeGroup(name: "New Group!")
        XCTAssertFalse(try modifiable.addItem(newGroup, to: attributePath).get())
        XCTAssertFalse(try modifiable.deleteItem(table: attributePath, atIndex: 0).get())
        XCTAssertEqual(modifiable.attributes, [newGroup])
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test delete returns correct error when index is invalid.
    func testDeleteInvalidIndex() throws {
        guard case .failure(let error) = modifiable.deleteItem(table: attributePath, atIndex: -1) else {
            XCTFail("Succeeded for invalid call.")
            return
        }
        XCTAssertEqual(error.message, "Invalid index.")
        XCTAssertEqual(error.path, AnyPath(attributePath[-1]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test delete removes multiple elements correctly.
    func testDeleteMultiple() throws {
        let newGroup = AttributeGroup(name: "New Group!")
        XCTAssertFalse(try modifiable.addItem(newGroup, to: attributePath).get())
        XCTAssertFalse(try modifiable.deleteItems(table: attributePath, items: [0, 1]).get())
        XCTAssertTrue(modifiable.attributes.isEmpty)
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test deleteItems returns correct error when source index is invalid.
    func testDeleteMultipleInvalidSources() {
        guard case .failure(let error) = modifiable.deleteItems(table: attributePath, items: [-1]) else {
            XCTFail("Successful call for invalid index.")
            return
        }
        XCTAssertEqual(error.message, "Invalid item index.")
        XCTAssertEqual(error.path, AnyPath(attributePath[-1]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test modify mutates element correctly.
    func testModify() throws {
        let newGroup = AttributeGroup(name: "New Group!")
        XCTAssertFalse(try modifiable.modify(attribute: attributePath[0], value: newGroup).get())
        XCTAssertEqual(modifiable.attributes, [newGroup])
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

    /// Test modify returns correct error when invalid index is given.
    func testModifyInvalidIndex() {
        let newGroup = AttributeGroup(name: "New Group!")
        guard
            case .failure(let error) = modifiable.modify(attribute: attributePath[-1], value: newGroup)
        else {
            XCTFail("Successful call for invalid index.")
            return
        }
        XCTAssertEqual(error.message, "Invalid path.")
        XCTAssertEqual(error.path, AnyPath(attributePath[-1]))
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        let allErrors = modifiable.errorBag.allErrors
        guard let firstError = allErrors.first else {
            XCTFail("Empty errors.")
            return
        }
        XCTAssertEqual(error.message, firstError.message)
        XCTAssertEqual(error.path, firstError.path)
    }

    /// Test validate doesn't throw an error.
    func testValidate() {
        XCTAssertNoThrow(try modifiable.validate())
        XCTAssertEqual(modifiable.attributes, attributes)
        XCTAssertEqual(modifiable.metaData, metaData)
        XCTAssertTrue(modifiable.errorBag.allErrors.isEmpty)
    }

}
