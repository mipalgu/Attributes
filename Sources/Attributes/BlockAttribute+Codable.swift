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

extension BlockAttribute: Codable {

    public enum CodingKeys: CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        if let code = try? CodeAttribute(from: decoder) {
            self = .code(code.value, language: code.language)
            return
        }
        if let text = try? TextAttribute(from: decoder) {
            self = .text(text.value)
            return
        }
        if let collection = try? CollectionAttribute(from: decoder) {
            self = .collection(collection.values, display: nil, type: collection.type)
        }
        if let complex = try? ComplexAttribute(from: decoder) {
            self = .complex(complex.values, layout: complex.layout)
        }
        if let enumCollection = try? EnumCollectionAttribute(from: decoder) {
            self = .enumerableCollection(enumCollection.values, validValues: enumCollection.cases)
        }
        if let table = try? TableAttribute(from: decoder) {
            self = .table(table.rows, columns: table.columns)
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported Value"
            )
        )
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .code(let value, let language):
            try CodeAttribute(value: value, language: language).encode(to: encoder)
        case .text(let value):
            try TextAttribute(value).encode(to: encoder)
        case .collection(let values, _, let type):
            try CollectionAttribute(type: type, values: values).encode(to: encoder)
        case .complex(let values, let layout):
            try ComplexAttribute(values: values, layout: layout).encode(to: encoder)
        case .enumerableCollection(let values, let cases):
            try EnumCollectionAttribute(cases: cases, values: values).encode(to: encoder)
        case .table(let rows, columns: let columns):
            try TableAttribute(rows: rows, columns: columns).encode(to: encoder)
        }
    }

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

}
