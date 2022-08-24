// CollectionSearchPathTests.swift 
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

/// Test class for CollectionSearchPath.
final class CollectionSearchPathTests: XCTestCase {

    /// Person test data.
    let person = Person(
        fields: [Field(name: "Name", type: .line), Field(name: "Age", type: .integer)],
        attributes: ["Name": .line("Test Name"), "Age": .integer(21)]
    )

    /// A Path to a Person object.
    let personPath = Path(Person.self)

    /// A Path to the fields in Person.
    var collectionPath: Path<Person, [Field]> {
        Path(path: \Person.fields, ancestors: [AnyPath(personPath)])
    }

    /// A Path to a Field object.
    let fieldPath = Path(Field.self)

    /// A Path to the name in a field.
    var fieldNamePath: Path<Field, String> {
        Path(path: \Field.name, ancestors: [AnyPath(fieldPath)])
    }

    // swiftlint:disable implicitly_unwrapped_optional

    /// The unit under test.
    var collectionSearchPath: CollectionSearchPath<Person, [Field], String>!

    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        collectionSearchPath = CollectionSearchPath(
            collectionPath: collectionPath, elementPath: fieldNamePath
        )
    }

    /// Test element path init stored properties successfully.
    func testElementInit() {
        XCTAssertEqual(collectionSearchPath.collectionPath, collectionPath)
        XCTAssertEqual(collectionSearchPath.elementPath, fieldNamePath)
    }

    /// Test init where element path is not specified.
    func testCollectionInit() {
        let newPath = CollectionSearchPath(collectionPath)
        let expectedElement = Path(Field.self)
        XCTAssertEqual(newPath.collectionPath, collectionPath)
        XCTAssertEqual(newPath.elementPath, expectedElement)
    }

    /// Test isAncestorOrSame returns true for ancestor path.
    func testIsAncestor() {
        XCTAssertTrue(collectionSearchPath.isAncestorOrSame(of: AnyPath(personPath), in: person))
    }

    /// Test isAncestorOrSame returns true for same path.
    func testIsSame() {
        XCTAssertTrue(collectionSearchPath.isAncestorOrSame(of: AnyPath(collectionPath), in: person))
    }

    /// Test paths function returns the correct paths.
    func testPaths() {
        let ancestors = [AnyPath(personPath), AnyPath(collectionPath)]
        let field0 = Path(path: \Person.fields[0], ancestors: ancestors)
        let field1 = Path(path: \Person.fields[1], ancestors: ancestors)
        let expected: [Path<Person, String>] = [
            Path(path: \Person.fields[0].name, ancestors: ancestors + [AnyPath(field0)]),
            Path(path: \Person.fields[1].name, ancestors: ancestors + [AnyPath(field1)])
        ]
        XCTAssertEqual(collectionSearchPath.paths(in: person), expected)
        // print("Collection Paths: \(collectionSearchPath.paths(in: person).map(\.ancestors).count)")
        // print("Expected Paths: \(expected.map(\.ancestors).count)")
    }

    /// Test appending method correctly appends the new path.
    func testAppending() {
        let newPath = CollectionSearchPath(collectionPath)
        let newCollectionPath = newPath.appending(
            path: fieldNamePath
        )
        XCTAssertEqual(
            newCollectionPath.paths(in: person), AnySearchablePath(collectionSearchPath).paths(in: person)
        )
    }

    /// Test toNewRoot function correctly changes root.
    func testToNewRoot() {
        let newRoot = Path([Person].self)
        let person0 = Path(path: \[Person][0], ancestors: [AnyPath(newRoot)])
        let newPath = collectionSearchPath.toNewRoot(path: person0)
        let data = [person]
        let paths = newPath.paths(in: data)
        let expectedPaths = collectionSearchPath.paths(in: person).flatMap {
            $0.toNewRoot(path: person0).paths(in: data)
        }
        XCTAssertEqual(paths, expectedPaths)
    }

}
