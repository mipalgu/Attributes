// LineAttribute+Codable.swift 
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
extension LineAttribute: Codable {

    // swiftlint:disable missing_docs

    private struct BoolAttribute: Hashable, Codable {

        var value: Bool

        init(_ value: Bool) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Bool.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }

    }

    private struct IntegerAttribute: Hashable, Codable {

        var value: Int

        init(_ value: Int) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Int.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }

    }

    private struct FloatAttribute: Hashable, Codable {

        var value: Double

        init(_ value: Double) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Double.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }

    }

    private struct ExpressionAttribute: Hashable, Codable {

        var value: Expression

        var language: Language

    }

    private struct EnumAttribute: Hashable, Codable {

        var cases: Set<String>

        var value: String

    }

    private struct LineAttribute: Hashable, Codable {

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

    // swiftlint:enable missing_docs

    /// Initialise the LineAttribute from a Decoder.
    /// - Parameter decoder: The decoder to use.
    public init(from decoder: Decoder) throws {
        if let bool = try? BoolAttribute(from: decoder) {
            self = .bool(bool.value)
            return
        }
        if let integer = try? IntegerAttribute(from: decoder) {
            self = .integer(integer.value)
            return
        }
        if let float = try? FloatAttribute(from: decoder) {
            self = .float(float.value)
            return
        }
        if let expression = try? ExpressionAttribute(from: decoder) {
            self = .expression(expression.value, language: expression.language)
            return
        }
        if let enumerated = try? EnumAttribute(from: decoder) {
            self = .enumerated(enumerated.value, validValues: enumerated.cases)
            return
        }
        if let line = try? LineAttribute(from: decoder) {
            self = .line(line.value)
            return
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported value"
            )
        )
    }

    /// Encode the LineAttribute.
    /// - Parameter encoder: The encoder to use.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .bool(let value):
            try BoolAttribute(value).encode(to: encoder)
        case .integer(let value):
            try IntegerAttribute(value).encode(to: encoder)
        case .float(let value):
            try FloatAttribute(value).encode(to: encoder)
        case .expression(let value, let language):
            try ExpressionAttribute(value: value, language: language).encode(to: encoder)
        case .enumerated(let value, let cases):
            try EnumAttribute(cases: cases, value: value).encode(to: encoder)
        case .line(let value):
            try LineAttribute(value).encode(to: encoder)
        }
    }

}
