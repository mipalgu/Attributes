// AttributablePerson.swift
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

import Attributes

/// A mock struct for a person using schema attributes.
struct AttributablePerson: Attributable {

    /// Underlying data is an empty modifiable.
    typealias Root = EmptyModifiable

    /// Attribute is the AttributeRoot.
    typealias AttributeRoot = Attribute

    /// Path to fields.
    var pathToFields: Path<Attribute, [Field]> {
        Path(Attribute.self).blockAttribute.complexFields
    }

    /// Path to attributes.
    var pathToAttributes: Path<Attribute, [String: Attribute]> {
        Path(Attribute.self).blockAttribute.complexValue
    }

    /// The data.
    var data: EmptyModifiable

    /// The first name type information.
    @LineProperty(label: "first_name")
    var firstName

    /// The last name type information.
    @LineProperty(label: "last_name")
    var lastName

    /// The age type information.
    @IntegerProperty(label: "age")
    var age

    /// Path to data.
    let path = EmptyModifiable.path.attributes[0].attributes["person"].wrappedValue

    /// Initialise data with default values.
    init() {
        let personFields = [
            Field(name: "first_name", type: .line),
            Field(name: "last_name", type: .line),
            Field(name: "age", type: .integer)
        ]
        self.data = EmptyModifiable(
            attributes: [
                AttributeGroup(
                    name: "Details",
                    fields: [Field(name: "person", type: .complex(layout: personFields))],
                    attributes: [
                        "person": .complex(
                            [
                                "first_name": .line("John"),
                                "last_name": .line("Smith"),
                                "age": .integer(21)
                            ],
                            layout: personFields
                        )
                    ],
                    metaData: [:]
                )
            ],
            metaData: [],
            errorBag: ErrorBag()
        )
    }

    /// Initialise data from preconfigured modifiable.
    /// - Parameter data: The data.
    init(data: EmptyModifiable) {
        self.data = data
    }

}

/// Equality and Hashable Conformance.
extension ErrorBag: Equatable, Hashable where Root: Equatable, Root: Hashable {

    /// Hashable.
    public static func == (lhs: ErrorBag, rhs: ErrorBag) -> Bool {
        lhs.allErrors == rhs.allErrors
    }

    /// Equality
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.allErrors)
    }

}

/// Equality and Hashable Conformance.
extension EmptyModifiable: Equatable, Hashable {

    /// Equality
    public static func == (lhs: Attributes.EmptyModifiable, rhs: Attributes.EmptyModifiable) -> Bool {
        lhs.attributes == rhs.attributes && lhs.errorBag == rhs.errorBag && lhs.metaData == rhs.metaData
    }

    /// Hashable.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.attributes)
        hasher.combine(self.errorBag)
        hasher.combine(self.metaData)
    }

}

/// Equality and Hashable Conformance.
extension AttributablePerson: Equatable, Hashable {

    /// Equality
    static func == (lhs: AttributablePerson, rhs: AttributablePerson) -> Bool {
        lhs.properties == rhs.properties && lhs.data == rhs.data && lhs.available == rhs.available &&
            lhs.path == rhs.path && lhs.pathToAttributes == rhs.pathToAttributes &&
            lhs.pathToFields == rhs.pathToFields
    }

    /// Hashable.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.properties)
        hasher.combine(self.available)
        hasher.combine(self.data)
        hasher.combine(self.path)
        hasher.combine(self.pathToAttributes)
        hasher.combine(self.pathToFields)
    }

}
