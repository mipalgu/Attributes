// BlockAttribute+Codable.swift 
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

/// Codable conformance.
extension BlockAttribute: Codable {

    /// The coding keys of this type.
    public enum CodingKeys: CodingKey {

        /// The type of the attribute.
        case type

        /// The value of the attribute.
        case value
    }

    // swiftlint:disable missing_docs

    private struct CodeAttribute: Hashable, Codable {

        var value: String

        var language: Language

    }

    private struct TextAttribute: Hashable, Codable {

        var value: String

        init(_ value: String) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(String.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }

    }

    private struct CollectionAttribute: Hashable, Codable {

        var type: AttributeType

        var values: [Attribute]

    }

    private struct ComplexAttribute: Hashable, Codable {

        var values: [String: Attribute]

        var layout: [Field]

    }

    private struct EnumCollectionAttribute: Hashable, Codable {

        var cases: Set<String>

        var values: Set<String>

    }

    private struct TableAttribute: Hashable, Codable {

        var rows: [[LineAttribute]]

        var columns: [BlockAttributeType.TableColumn]

    }

    // swiftlint:enable missing_docs

    /// Decoder init.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "code":
            let code = try container.decode(CodeAttribute.self, forKey: .value)
            self = .code(code.value, language: code.language)
        case "text":
            let text = try container.decode(TextAttribute.self, forKey: .value)
            self = .text(text.value)
        case "collection":
            let collection = try container.decode(CollectionAttribute.self, forKey: .value)
            self = .collection(collection.values, display: nil, type: collection.type)
        case "complex":
            let complex = try container.decode(ComplexAttribute.self, forKey: .value)
            self = .complex(complex.values, layout: complex.layout)
        case "enumerableCollection":
            let enumCollection = try container.decode(EnumCollectionAttribute.self, forKey: .value)
            self = .enumerableCollection(enumCollection.values, validValues: enumCollection.cases)
        case "table":
            let table = try container.decode(TableAttribute.self, forKey: .value)
            self = .table(table.rows, columns: table.columns)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type \(type)"
                )
            )
        }
    }

    /// Encode function.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .code(let value, let language):
            try container.encode("code", forKey: .type)
            try container.encode(CodeAttribute(value: value, language: language), forKey: .value)
        case .text(let value):
            try container.encode("text", forKey: .type)
            try container.encode(TextAttribute(value), forKey: .value)
        case .collection(let values, _, let type):
            try container.encode("collection", forKey: .type)
            try container.encode(CollectionAttribute(type: type, values: values), forKey: .value)
        case .complex(let values, let layout):
            try container.encode("complex", forKey: .type)
            try container.encode(ComplexAttribute(values: values, layout: layout), forKey: .value)
        case .enumerableCollection(let values, let cases):
            try container.encode("enumerableCollection", forKey: .type)
            try container.encode(EnumCollectionAttribute(cases: cases, values: values), forKey: .value)
        case .table(let rows, columns: let columns):
            try container.encode("table", forKey: .type)
            try container.encode(TableAttribute(rows: rows, columns: columns), forKey: .value)
        }
    }

}
