/*
 * BlockAttributeType.swift
 * Machines
 *
 * Created by Callum McColl on 31/10/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import XMI

/// The supported types for a BlockAttribute.
public enum BlockAttributeType: Hashable {

    /// A code type with a language.
    case code(language: Language)

    /// A block of text.
    case text

    /// A collection of other Attributes.
    indirect case collection(type: AttributeType)

    /// An array of other Attributes.
    indirect case complex(layout: [Field])

    /// A collection of Attributes drawn from a set of valid values.
    case enumerableCollection(validValues: Set<String>)

    /// A table with columns and rows.
    case table(columns: [TableColumn])

    /// Helper struct used to define tables. This struct represents a
    /// single column of a table.
    public struct TableColumn: Hashable, Codable {

        /// The name of the column.
        public var name: Label

        /// The data type stored in the column.
        public var type: LineAttributeType

        /// Initialise the column with a name and a type.
        /// - Parameters:
        ///   - name: The name of the column.
        ///   - type: The type of the data in the column.
        public init(name: String, type: LineAttributeType) {
            self.name = name
            self.type = type
        }

    }

    /// Checks whether the type can contain other types.
    public var isRecursive: Bool {
        switch self {
        case .collection, .complex, .table:
            return true
        default:
            return false
        }
    }

    /// True if the type is a table.
    public var isTable: Bool {
        switch self {
        case .table:
            return true
        default:
            return false
        }
    }

    /// The default value of the type.
    public var defaultValue: BlockAttribute {
        switch self {
        case .code(let language):
            return .code("", language: language)
        case .collection(let type):
            return .collection([], display: nil, type: type)
        case .complex(let fields):
            let values = Dictionary(uniqueKeysWithValues: fields.map { field -> (Label, Attribute) in
                (field.name, field.type.defaultValue)
            })
            return .complex(values, layout: fields)
        case .enumerableCollection(let validValues):
            return .enumerableCollection(Set(), validValues: validValues)
        case .table(let columns):
            return .table([], columns: columns)
        case .text:
            return .text("")
        }
    }

}

/// Codable conformance.
extension BlockAttributeType: Codable {

    // swiftlint:disable missing_docs

    private struct CodeAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String?

        var language: Language

    }

    private struct CollectionAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String?

        var type: AttributeType

    }

    private struct ComplexAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String?

        var layout: [Field]

    }

    private struct EnumCollectionAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String?

        var validValues: Set<String>

    }

    private struct TableAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String?

        var columns: [BlockAttributeType.TableColumn]

    }

    // swiftlint:enable missing_docs

    /// Decoder initialiser.
    /// - Parameter decoder: The decoder. 
    public init(from decoder: Decoder) throws {
        if let code = try? CodeAttributeType(from: decoder) {
            self = .code(language: code.language)
            return
        }
        if let complex = try? ComplexAttributeType(from: decoder) {
            self = .complex(layout: complex.layout)
        }
        if let enumCollection = try? EnumCollectionAttributeType(from: decoder) {
            self = .enumerableCollection(validValues: enumCollection.validValues)
        }
        if let table = try? TableAttributeType(from: decoder) {
            self = .table(columns: table.columns)
        }
        if let collection = try? CollectionAttributeType(from: decoder) {
            self = .collection(type: collection.type)
        }
        guard let name = try? String(from: decoder), name == BlockAttributeType.text.xmiName else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
        self = .text
    }

    /// Encode function.
    /// - Parameter encoder: The encoder.
    public func encode(to encoder: Encoder) throws {
        guard let name = self.xmiName else {
            throw EncodingError.invalidValue(
                "name",
                EncodingError.Context(
                    codingPath: encoder.codingPath, debugDescription: "Failed to get xmiName"
                )
            )
        }
        switch self {
        case .code(let language):
            try CodeAttributeType(xmiName: name, language: language).encode(to: encoder)
        case .text:
            try name.encode(to: encoder)
        case .collection(let type):
            try CollectionAttributeType(xmiName: name, type: type).encode(to: encoder)
        case .complex(let layout):
            try ComplexAttributeType(xmiName: name, layout: layout).encode(to: encoder)
        case .enumerableCollection(let validValues):
            try EnumCollectionAttributeType(xmiName: name, validValues: validValues).encode(to: encoder)
        case .table(columns: let columns):
            try TableAttributeType(xmiName: name, columns: columns).encode(to: encoder)
        }
    }

}

/// XMIConvertible conformance.
extension BlockAttributeType: XMIConvertible {

    /// The XMI name of this type.
    public var xmiName: String? {
        switch self {
        case .code:
            return "CodeAttributeType"
        case .text:
            return "TextAttributeType"
        case .collection:
            return "CollectionAttributeType"
        case .complex:
            return "ComplexAttributeType"
        case .enumerableCollection:
            return "EnumCollectionAttributeType"
        case .table:
            return "TableAttributeType"
        }
    }

}
