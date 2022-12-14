/*
 * AttributeType.swift
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

/// The type of any Attribute.
public enum AttributeType: Hashable {

    /// A line attribute type.
    case line(LineAttributeType)

    /// A block attribute type.
    case block(BlockAttributeType)

    /// A bool type.
    @inlinable public static var bool: AttributeType {
        .line(.bool)
    }

    /// An integer type.
    @inlinable public static var integer: AttributeType {
        .line(.integer)
    }

    /// A float type.
    @inlinable public static var float: AttributeType {
        .line(.float)
    }

    /// A text type.
    @inlinable public static var text: AttributeType {
        .block(.text)
    }

    /// A line type.
    @inlinable public static var line: AttributeType {
        .line(.line)
    }

    /// Whether the AttributeType is a line attribute.
    @inlinable public var isLine: Bool {
        switch self {
        case .line:
            return true
        default:
            return false
        }
    }

    /// Whether the AttributeType is a block attribute.
    @inlinable public var isBlock: Bool {
        switch self {
        case .block:
            return true
        default:
            return false
        }
    }

    /// Whether the AttributeType is a recursive type. This infers that the
    /// type is also a block attribute type.
    @inlinable public var isRecursive: Bool {
        switch self {
        case .block(let blockType):
            return blockType.isRecursive
        default:
            return false
        }
    }

    /// Whether the AttributeType is a table.
    @inlinable public var isTable: Bool {
        switch self {
        case .block(let type):
            return type.isTable
        default:
            return false
        }
    }

    /// The default value of this AttributeType represented as an
    /// Attribute.
    @inlinable public var defaultValue: Attribute {
        switch self {
        case .line(let lineAttribute):
            return .line(lineAttribute.defaultValue)
        case .block(let blockAttribute):
            return .block(blockAttribute.defaultValue)
        }
    }

    /// An expression type with a language.
    /// - Parameter language: The language of the expression.
    /// - Returns: The expression type.
    @inlinable
    public static func expression(language: Language) -> AttributeType {
        .line(.expression(language: language))
    }

    /// An enumerated type with a set of valid values.
    /// - Parameter validValues: The valid values for the enumeration.
    /// - Returns: The enumerated type.
    @inlinable
    public static func enumerated(validValues: Set<String>) -> AttributeType {
        .line(.enumerated(validValues: validValues))
    }

    /// A code type in a language
    ///  - Parameter lagnuage: The language of the code type.
    ///  - Returns: The code type.
    @inlinable
    public static func code(language: Language) -> AttributeType {
        .block(.code(language: language))
    }

    /// A collection of Attributes sharing the same type.
    /// - Parameter type: The type of the elements in the collection.
    /// - Returns: The type of the collection.
    @inlinable
    public static func collection(type: AttributeType) -> AttributeType {
        .block(.collection(type: type))
    }

    /// A complex with a specific layout.
    /// - Parameter layout: The layout of this complex type.
    /// - Returns: The complex type with the layout specified.
    @inlinable
    public static func complex(layout: [Field]) -> AttributeType {
        .block(.complex(layout: layout))
    }

    /// An enumerated collection drawn from a set of valid values.
    /// - Parameter validValues: The valid values of this collection.
    /// - Returns: The type of the enumerated collection.
    @inlinable
    public static func enumerableCollection(validValues: Set<String>) -> AttributeType {
        .block(.enumerableCollection(validValues: validValues))
    }

    /// A table type with a set of columns.
    /// - Parameter columns: The columns in this table type.
    /// - Returns: The table type.
    @inlinable
    public static func table(columns: [(name: String, type: LineAttributeType)]) -> AttributeType {
        .block(
            .table(columns: columns.map { BlockAttributeType.TableColumn(name: $0.name, type: $0.type) })
        )
    }

}

/// Codable conformance.
extension AttributeType: Codable {

    /// The Coding Keys for this Attribute Type.
    @usableFromInline
    enum CodingKeys: CodingKey {

        /// The type of the attribute (line or block).
        case type

        /// The value of the attribute.
        case value

    }

    /// Decoder init.
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Bool.self, forKey: .type)
        switch type {
        case true:
            let lineAttributeType = try container.decode(LineAttributeType.self, forKey: .value)
            self = .line(lineAttributeType)
        case false:
            let blockAttributeType = try container.decode(BlockAttributeType.self, forKey: .value)
            self = .block(blockAttributeType)
        }
    }

    /// Encode function.
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .line(let attributeType):
            try container.encode(true, forKey: .type)
            try container.encode(attributeType, forKey: .value)
        case .block(let attributeType):
            try container.encode(false, forKey: .type)
            try container.encode(attributeType, forKey: .value)
        }
    }

}

/// XMIConvertible conformance.
extension AttributeType: XMIConvertible {

    /// The XMI name of this type.
    @inlinable public var xmiName: String? {
        switch self {
        case .line(let type):
            return type.xmiName
        case .block(let type):
            return type.xmiName
        }
    }

}
