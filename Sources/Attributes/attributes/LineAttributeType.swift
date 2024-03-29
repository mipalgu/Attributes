/*
 * LineAttributeType.swift
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
/// All the possible types of a LineAttribute.
public enum LineAttributeType: Hashable {

    /// A Boolean type.
    case bool

    /// An Integer type.
    case integer

    /// A Double-Precision Floating Point type.
    case float

    /// An Expression in some language.
    case expression(language: Language)

    /// An enumerated value drawn from a set of valid values.
    case enumerated(validValues: Set<String>)

    /// A small String of text.
    case line

    /// The default value of an attribute type.
    @inlinable public var defaultValue: LineAttribute {
        switch self {
        case .bool:
            return .bool(false)
        case .enumerated(let validValues):
            return .enumerated(validValues.min() ?? "", validValues: validValues)
        case .expression(let language):
            return .expression("", language: language)
        case .float:
            return .float(0.0)
        case .integer:
            return .integer(0)
        case .line:
            return .line("")
        }
    }

}

/// Codable conformance.
extension LineAttributeType: Codable {

    // swiftlint:disable missing_docs

    private struct BoolAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "BoolAttributeType" }

    }

    private struct IntegerAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "IntegerAttributeType" }

    }

    private struct FloatAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "FloatAttributeType" }

    }

    private struct ExpressionAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "ExpressionAttributeType" }

        var language: Language

    }

    private struct EnumAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "EnumAttributeType" }

        var validValues: Set<String>

    }

    private struct LineAttributeType: Hashable, Codable, XMIConvertible {

        var xmiName: String? { "LineAttributeType" }

    }

    // swiftlint:enable missing_docs

    /// Decoder initialiser.
    /// - Parameter decoder: The decoder. 
    public init(from decoder: Decoder) throws {
        if let expression = try? ExpressionAttributeType(from: decoder) {
            self = .expression(language: expression.language)
            return
        }
        if let enumerated = try? EnumAttributeType(from: decoder) {
            self = .enumerated(validValues: enumerated.validValues)
            return
        }
        guard let name = try? String(from: decoder) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
        switch name {
        case BoolAttributeType().xmiName:
            self = .bool
        case IntegerAttributeType().xmiName:
            self = .integer
        case FloatAttributeType().xmiName:
            self = .float
        case LineAttributeType().xmiName:
            self = .line
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }

    /// Encode self into data using an encoder.
    /// - Parameter encoder: The encoder.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .bool:
            try BoolAttributeType().xmiName.encode(to: encoder)
        case .integer:
            try IntegerAttributeType().xmiName.encode(to: encoder)
        case .float:
            try FloatAttributeType().xmiName.encode(to: encoder)
        case .expression(let language):
            try ExpressionAttributeType(language: language).encode(to: encoder)
        case .enumerated(let value):
            try EnumAttributeType(validValues: value).encode(to: encoder)
        case .line:
            try LineAttributeType().xmiName.encode(to: encoder)
        }
    }

}

/// XMIConvertible conformance.
extension LineAttributeType: XMIConvertible {

    /// The XMI name of this attribute type.
    public var xmiName: String? {
        switch self {
        case .bool:
            return BoolAttributeType().xmiName
        case .integer:
            return IntegerAttributeType().xmiName
        case .float:
            return FloatAttributeType().xmiName
        case .expression(let language):
            return ExpressionAttributeType(language: language).xmiName
        case .enumerated(let value):
            return EnumAttributeType(validValues: value).xmiName
        case .line:
            return LineAttributeType().xmiName
        }
    }

}
