/*
 * LineAttribute.swift
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

/// A LineAttribute is an Attribute that is represented without any relation
/// to other Attributes.
public enum LineAttribute: Hashable, Identifiable {

    /// A boolean attribute.
    case bool(Bool)

    /// An integer attribute.
    case integer(Int)

    /// A double-precision floating point attribute.
    case float(Double)

    /// An expression in some language.
    case expression(Expression, language: Language)

    /// An enumerated value drawn from a set of valid values.
    case enumerated(String, validValues: Set<String>)

    /// A single-lined text value.
    case line(String)

    /// The id of the attribute.
    public var id: Int {
        LineAttributeIDCache.id(for: self)
    }

    /// The equivalent LineAttributeType for self.
    public var type: LineAttributeType {
        switch self {
        case .bool:
            return .bool
        case .integer:
            return .integer
        case .float:
            return .float
        case .expression(_, let language):
            return .expression(language: language)
        case .enumerated(_, let validValues):
            return .enumerated(validValues: validValues)
        case .line:
            return .line
        }
    }

    /// The Bool value of self.
    /// - Warning: This creates a runtime error when self != .bool.
    public var boolValue: Bool {
        get {
            switch self {
            case .bool(let value):
                return value
            default:
                fatalError(
                    "Attempting to fetch a bool value on a line attribute which is not a bool attribute"
                )
            }
        }
        set {
            switch self {
            case .bool:
                self = .bool(newValue)
            default:
                fatalError("Attempting to set a bool value on a line attribute which is not a bool attribute")
            }
        }
    }

    /// The integer value of self.
    /// - Warning: This creates a runtime error when self != .integer.
    public var integerValue: Int {
        get {
            switch self {
            case .integer(let value):
                return value
            default:
                fatalError(
                    """
                    Attempting to fetch an integer value on a line attribute which is
                    not an integer attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .integer:
                self = .integer(newValue)
            default:
                fatalError(
                    "Attempting to set an integer value on a line attribute which is not an integer attribute"
                )
            }
        }
    }

    /// The Double value of self.
    /// - Warning: This creates a runtime error when self != .float.
    public var floatValue: Double {
        get {
            switch self {
            case .float(let value):
                return value
            default:
                fatalError(
                    "Attempting to fetch a float value on a line attribute which is not a float attribute"
                )
            }
        }
        set {
            switch self {
            case .float:
                self = .float(newValue)
            default:
                fatalError(
                    "Attempting to set a float value on a line attribute which is not a float attribute"
                )
            }
        }
    }

    /// The Expression value of self.
    /// - Warning: This creates a runtime error when self != .expression.
    public var expressionValue: Expression {
        get {
            switch self {
            case .expression(let value, _):
                return value
            default:
                fatalError(
                    """
                    Attempting to fetch an expression value on a line attribute which is
                    not an expression attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .expression(_, let language):
                self = .expression(newValue, language: language)
            default:
                fatalError(
                    """
                    Attempting to set an expression value on a line attribute which is
                    not an expression attribute
                    """
                )
            }
        }
    }

    /// The Enumerated String value of self.
    /// - Warning: This creates a runtime error when self != .enumerated.
    public var enumeratedValue: String {
        get {
            switch self {
            case .enumerated(let value, _):
                return value
            default:
                fatalError(
                    """
                    Attempting to fetch an enumerated value on a line attribute which
                    is not an enumerated attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .enumerated(_, let validValues):
                self = .enumerated(newValue, validValues: validValues)
            default:
                fatalError(
                    """
                    Attempting to set an enumerated value on a line attribute which is
                    not an enumerated attribute
                    """
                )
            }
        }
    }

    /// The Enumerated valid values Set<String> value of self.
    /// - Warning: This creates a runtime error when self != .enumerated.
    public var enumeratedValidValues: Set<String> {
        get {
            switch self {
            case .enumerated(_, let validValues):
                return validValues
            default:
                fatalError(
                    """
                    Attempting to fetch an enumerated valid value on a line attribute which is
                    not an enumerated attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .enumerated(let value, _):
                self = .enumerated(value, validValues: newValue)
            default:
                fatalError(
                    """
                    Attempting to set an enumerated valid value on a line attribute which is
                    not an enumerated attribute
                    """
                )
            }
        }
    }

    /// The String value of self.
    /// - Warning: This creates a runtime error when self != .line.
    public var lineValue: String {
        get {
            switch self {
            case .line(let value):
                return value
            default:
                fatalError(
                    "Attempting to fetch a line value on a line attribute which is not a line attribute"
                )
            }
        }
        set {
            switch self {
            case .line:
                self = .line(newValue)
            default:
                fatalError(
                    "Attempting to set a line value on a line attribute which is not a line attribute"
                )
            }
        }
    }

    /// A string representation of self.
    public var strValue: String {
        switch self {
        case .bool(let value):
            return String(describing: value)
        case .enumerated(let value, _):
            return value
        case .expression(let value, _):
            return value
        case .float(let value):
            return String(describing: value)
        case .integer(let value):
            return String(describing: value)
        case .line(let value):
            return value
        }
    }

    /// Initialise a LineAttribute from a LineAttributeType and a string representation of
    /// the value
    /// - Parameters:
    ///   - type: The type of the attribute.
    ///   - value: The value of the attribute.
    public init?(type: LineAttributeType, value: String) {
        switch type {
        case .bool:
            guard let value = Bool(value) else {
                return nil
            }
            self = .bool(value)
        case .integer:
            guard let value = Int(value) else {
                return nil
            }
            self = .integer(value)
        case .float:
            guard let value = Double(value) else {
                return nil
            }
            self = .float(value)
        case .expression(let language):
            self = .expression(Expression(value), language: language)
        case .enumerated(let validValues):
            if !validValues.contains(value) {
                return nil
            }
            self = .enumerated(value, validValues: validValues)
        case .line:
            self = .line(value)
        }
    }

}

/// XMIConvertible conformance.
extension LineAttribute: XMIConvertible {

    /// The XMI name of this attribute.
    public var xmiName: String? {
        switch self {
        case .bool:
            return "BoolAttribute"
        case .integer:
            return "IntegerAttribute"
        case .float:
            return "FloatAttribute"
        case .enumerated:
            return "EnumeratedAttribute"
        case .expression:
            return "ExpressionAttribute"
        case .line:
            return "LineAttribute"
        }
    }

}
