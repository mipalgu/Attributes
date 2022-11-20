/*
 * Attribute.swift
 * Machines
 *
 * Created by Callum McColl on 29/10/20.
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// All types of Attributes. An attribute is a way of grouping common data
/// types.
public enum Attribute: Hashable, Identifiable {

    /// A line attribute.
    case line(LineAttribute)

    /// A block attribute.
    case block(BlockAttribute)

    /// The id of the attribute.
    public var id: Int {
        AttributeIDCache.id(for: self)
    }

    /// The type of the attribute.
    public var type: AttributeType {
        switch self {
        case .line(let attribute):
            switch attribute {
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
        case .block(let attribute):
            switch attribute {
            case .code(_, let language):
                return .code(language: language)
            case .text:
                return .text
            case .collection(_, _, let type):
                return .collection(type: type)
            case .complex(_, let layout):
                return .complex(layout: layout)
            case .enumerableCollection(_, let validValues):
                return .enumerableCollection(validValues: validValues)
            case .table(_, columns: let columns):
                return .table(columns: columns.map { ($0.name, $0.type) })
            }
        }
    }

    /// Whether the attribute is a line attribute.
    public var isLine: Bool {
        switch self {
        case .line:
            return true
        default:
            return false
        }
    }

    /// Whether the attribute is a block attribute.
    public var isBlock: Bool {
        switch self {
        case .block:
            return true
        default:
            return false
        }
    }

    /// The LineAttribute version of this attribute.
    /// - Warning: This property will create runtime errors if the attribute
    ///            is a block attribute.
    public var lineAttribute: LineAttribute {
        get {
            switch self {
            case .line(let attribute):
                return attribute
            default:
                fatalError("Attempting to access line attribute of block attribute")
            }
        } set {
            self = .line(newValue)
        }
    }

    /// The BlockAttribute version of this attribute.
    /// - Warning: This property will create runtime errors if the attribute
    ///            is a line attribute.
    public var blockAttribute: BlockAttribute {
        get {
            switch self {
            case .block(let attribute):
                return attribute
            default:
                fatalError("Attempting to access block attribute of line attribute")
            }
        } set {
            self = .block(newValue)
        }
    }

    /// A string version of this attribute.
    public var strValue: String? {
        switch self {
        case .line(let lineAttribute):
            return lineAttribute.strValue
        case .block(let blockAttribute):
            return blockAttribute.strValue
        }
    }

    /// A Bool value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Bool value.
    public var boolValue: Bool {
        get {
            switch self {
            case .line(let attribute):
                return attribute.boolValue
            default:
                fatalError("Attempting to fetch a bool value on an attribute which is not a line attribute")
            }
        }
        set {
            switch self {
            case .line(.bool):
                self = .line(.bool(newValue))
            default:
                fatalError("Attempting to set a bool value on an attribute which is not a line attribute")
            }
        }
    }

    /// An Integer value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Integer value.
    public var integerValue: Int {
        get {
            switch self {
            case .line(let attribute):
                return attribute.integerValue
            default:
                fatalError(
                    "Attempting to fetch an integer value on an attribute which is not a line attribute"
                )
            }
        }
        set {
            switch self {
            case .line(.integer):
                self = .line(.integer(newValue))
            default:
                fatalError("Attempting to set an integer value on an attribute which is not a line attribute")
            }
        }
    }

    /// A Float value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Float value.
    public var floatValue: Double {
        get {
            switch self {
            case .line(let value):
                return value.floatValue
            default:
                fatalError("Attempting to fetch a float value on an attribute which is not a line attribute")
            }
        }
        set {
            switch self {
            case .line(.float):
                self = .line(.float(newValue))
            default:
                fatalError("Attempting to set a float value on an attribute which is not a line attribute")
            }
        }
    }

    /// An Expression value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Expression value.
    public var expressionValue: Expression {
        get {
            switch self {
            case .line(let value):
                return value.expressionValue
            default:
                fatalError(
                    "Attempting to fetch an expression value on an attribute which is not a line attribute"
                )
            }
        }
        set {
            switch self {
            case .line(.expression(_, let language)):
                self = .line(.expression(newValue, language: language))
            default:
                fatalError(
                    "Attempting to set an expression value on an attribute which is not a line attribute"
                )
            }
        }
    }

    /// An Enumerated value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Enumerated value.
    public var enumeratedValue: String {
        get {
            switch self {
            case .line(let value):
                return value.enumeratedValue
            default:
                fatalError(
                    "Attempting to fetch an enumerated value on an attribute which is not a line attribute"
                )
            }
        }
        set {
            switch self {
            case .line(.enumerated(_, let validValues)):
                self = .line(.enumerated(newValue, validValues: validValues))
            default:
                fatalError(
                    "Attempting to set an enumerated value on a line attribute which is not a line attribute"
                )
            }
        }
    }

    /// The valid values from an Enumerated attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Enumerated value.
    public var enumeratedValidValues: Set<String> {
        get {
            switch self {
            case .line(let value):
                return value.enumeratedValidValues
            default:
                fatalError(
                    """
                    Attempting to fetch an enumerated valid value on a line attribute which
                    is not an enumerated attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .line(.enumerated(let value, _)):
                self = .line(.enumerated(value, validValues: newValue))
            default:
                fatalError(
                    """
                    Attempting to set an enumerated valid value on a line attribute which
                    is not an enumerated attribute
                    """
                )
            }
        }
    }

    /// A Line value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Line value.
    public var lineValue: String {
        get {
            switch self {
            case .line(let value):
                return value.lineValue
            default:
                fatalError("Attempting to fetch a line value on an attribute which is not a line attribute")
            }
        }
        set {
            switch self {
            case .line(.line):
                self = .line(.line(newValue))
            default:
                fatalError("Attempting to set a line value on an attribute which is not a line attribute")
            }
        }
    }

    /// A Code value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Code value.
    public var codeValue: String {
        get {
            switch self {
            case .block(let value):
                return value.codeValue
            default:
                fatalError("Attempting to fetch a code value on an attribute which is not a block attribute")
            }
        }
        set {
            switch self {
            case .block(.code(_, let language)):
                self = .block(.code(newValue, language: language))
            default:
                fatalError("Attempting to set a code value on an attribute which is not a block attribute")
            }
        }
    }

    /// A Text value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Text value.
    public var textValue: String {
        get {
            switch self {
            case .block(let value):
                return value.textValue
            default:
                fatalError("Attempting to fetch a text value on an attribute which is not a block attribute")
            }
        }
        set {
            switch self {
            case .block(.text):
                self = .block(.text(newValue))
            default:
                fatalError("Attempting to set a text value on an attribute which is not a block attribute")
            }
        }
    }

    /// A Collection value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Collection value.
    public var collectionValue: [Attribute] {
        get {
            switch self {
            case .block(let value):
                return value.collectionValue
            default:
                fatalError(
                    """
                    Attempting to fetch a collection value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                self = .block(.collection(newValue, display: display, type: type))
            default:
                fatalError(
                    "Attempting to set a collection value on an attribute which is not a block attribute"
                )
            }
        }
    }

    /// Access the Fields of a complex attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Complex value.
    public var complexFields: [Field] {
        get {
            switch self {
            case .block(let value):
                return value.complexFields
            default:
                fatalError(
                    "Attempting to fetch complex fields on an attribute which is not a block attribute"
                )
            }
        }
        set {
            switch self {
            case .block(.complex(let value, _)):
                self = .block(.complex(value, layout: newValue))
            default:
                fatalError("Attempting to set complex fields on an attribute which is not a block attribute")
            }
        }
    }

    /// A Complex value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Complex value.
    public var complexValue: [Label: Attribute] {
        get {
            switch self {
            case .block(let value):
                return value.complexValue
            default:
                fatalError(
                    "Attempting to fetch a complex value on an attribute which is not a block attribute"
                )
            }
        }
        set {
            switch self {
            case .block(.complex(_, let layout)):
                self = .block(.complex(newValue, layout: layout))
            default:
                fatalError("Attempting to set a complex value on an attribute which is not a block attribute")
            }
        }
    }

    /// An Enumerable Collection value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Enumerable Collection.
    public var enumerableCollectionValue: Set<String> {
        get {
            switch self {
            case .block(let value):
                return value.enumerableCollectionValue
            default:
                fatalError(
                    """
                    Attempting to fetch an enumerable collection value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.enumerableCollection(_, let validValues)):
                self = .block(.enumerableCollection(newValue, validValues: validValues))
            default:
                fatalError(
                    """
                    Attempting to set an enumerable collection value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
    }

    /// The valid values of an enumerable collection attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Enumerable Collection.
    public var enumerableCollectionValidValues: Set<String> {
        get {
            switch self {
            case .block(let value):
                return value.enumerableCollectionValidValues
            default:
                fatalError(
                    """
                    Attempting to fetch enumerable collection valid values on an
                    attribute which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.enumerableCollection(let values, _)):
                self = .block(.enumerableCollection(values, validValues: newValue))
            default:
                fatalError(
                    """
                    Attempting to set enumerable collection valid values
                    on an attribute which is not a block attribute
                    """
                )
            }
        }
    }

    /// A Table value of this attribute.
    /// - Warning: This property will create runtime errors if the attribute is not
    ///            a valid Table value.
    public var tableValue: [[LineAttribute]] {
        get {
            switch self {
            case .block(.table(let rows, _)):
                return rows
            default:
                fatalError("Attempting to access table value of non table value attribute")
            }
        } set {
            switch self.type {
            case .block(.table(let cols)):
                self = .block(.table(newValue, columns: cols))
            default:
                fatalError("Attempting to set a table value on an attribute which is not a block attribute")
            }
        }
    }

    /// Access the collection values as Bool types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Bool types.
    public var collectionBools: [Bool] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .bool:
                    return values.map { $0.boolValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection bool value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection bool value on an
                    attribute which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .bool:
                    self = .block(
                        .collection(newValue.map { Attribute.bool($0) }, display: display, type: type)
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection bool value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    "Attempting to set a collection bool value on an attribute which is not a block attribute"
                )
            }
        }
    }

    /// Access the collection values as Integer types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Integer types.
    public var collectionIntegers: [Int] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .integer:
                    return values.map { $0.integerValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection integer value on an attribute which
                        is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection integer value on an attribute which
                    is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .integer:
                    self = .block(
                        .collection(newValue.map { Attribute.integer($0) }, display: display, type: type)
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection integer value on an attribute which is not
                        a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection integer value on an attribute which is not a
                    block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Float types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Float types.
    public var collectionFloats: [Double] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .float:
                    return values.map { $0.floatValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection float value on an attribute which
                        is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection float value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .float:
                    self = .block(
                        .collection(newValue.map { Attribute.float($0) }, display: display, type: type)
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection float value on an attribute which is
                        not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection float value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Expression types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Expression types.
    public var collectionExpressions: [Expression] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .line(.expression):
                    return values.map { $0.expressionValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection expression value on an
                        attribute which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection expression value on an
                    attribute which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .line(.expression(let language)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.expression($0, language: language) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection expression value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection expression value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Enumerated types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Enumerated types.
    public var collectionEnumerated: [String] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .line(.enumerated):
                    return values.map { $0.enumeratedValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection enumerated value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection enumerated value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .line(.enumerated(let validValues)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.enumerated($0, validValues: validValues) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection enumerated value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection enumerated value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Line types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Line types.
    public var collectionLines: [String] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .line:
                    return values.map { $0.lineValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection lines value on an
                        attribute which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection lines value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .line(.line):
                    self = .block(
                        .collection(newValue.map { Attribute.line($0) }, display: display, type: type)
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection lines value on an attribute which is
                        not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection lines value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Code types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Code types.
    public var collectionCode: [String] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .block(.code):
                    return values.map { $0.codeValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection code value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection code value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .block(.code(let language)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.code($0, language: language) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection code value on an attribute which
                        is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection code value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Text types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Text types.
    public var collectionText: [String] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .text:
                    return values.map { $0.textValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection text value on an attribute which
                        is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection text value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .block(.text):
                    self = .block(
                        .collection(newValue.map { Attribute.text($0) }, display: display, type: type)
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection text value on an attribute which is
                        not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection text value on an attribute which is not
                    a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Complex types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Complex types.
    public var collectionComplex: [[Label: Attribute]] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .block(.complex):
                    return values.map { $0.complexValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection complex value on an attribute which is
                        not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection complex value on an attribute which is not
                    a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .block(.complex(let layout)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.complex($0, layout: layout) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection complex value on an attribute which is not
                        a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection complex value on an attribute which is not a
                    block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Enumerable Collection types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Enumerable Collection types.
    public var collectionEnumerableCollection: [Set<String>] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .block(.enumerableCollection):
                    return values.map({ $0.enumerableCollectionValue })
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection enumerable collection value on an
                        attribute which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection enumerable collection value on an
                    attribute which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .block(.enumerableCollection(let validValues)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.enumerableCollection($0, validValues: validValues) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection enumerable collection value on an
                        attribute which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection enumerable collection value on an
                    attribute which is not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Table types.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection value of Table types.
    public var collectionTable: [[[LineAttribute]]] {
        get {
            switch self {
            case .block(.collection(let values, _, type: let type)):
                switch type {
                case .block(.table):
                    return values.map({ $0.tableValue })
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection table value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection table value on an attribute
                    which is not a block attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(_, let display, let type)):
                switch type {
                case .block(.table(let columns)):
                    self = .block(
                        .collection(
                            newValue.map { Attribute.table($0, columns: columns.map { ($0.name, $0.type) }) },
                            display: display,
                            type: type
                        )
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection table value on an attribute
                        which is not a block attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection table value on an attribute which is
                    not a block attribute
                    """
                )
            }
        }
    }

    /// Access the collection display.
    /// - Warning: This property will cause runtime errors if the attribute is not
    ///            a collection type.
    public var collectionDisplay: ReadOnlyPath<Attribute, LineAttribute>? {
        get {
            switch self {
            case .block(.collection(_, let display, _)):
                return display
            default:
                fatalError(
                    """
                    Attempting to fetch a collection display value on an attribute which is
                    not a collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .block(.collection(let values, _, let type)):
                self = .block(.collection(values, display: newValue, type: type))
            default:
                fatalError(
                    """
                    Attempting to set a collection display value on an attribute which is not
                    a collection attribute
                    """
                )
            }
        }
    }

    /// Initialise this attribute from a LineAttribute.
    /// - Parameter lineAttribute: The equivalent line attribute.
    public init(lineAttribute: LineAttribute) {
        self = .line(lineAttribute)
    }

    /// Initialise this attribute from a BlockAttribute.
    /// - Parameter blockAttribute: The equivalent block attribute.
    public init(blockAttribute: BlockAttribute) {
        self = .block(blockAttribute)
    }

    /// Create a bool attribute.
    /// - Parameter value: The value of the attribute.
    /// - Returns: The bool attribute.
    public static func bool(_ value: Bool) -> Attribute {
        .line(.bool(value))
    }

    // Create an integer attribute.
    /// - Parameter value: The value of the attribute.
    /// - Returns: The integer attribute.
    public static func integer(_ value: Int) -> Attribute {
        .line(.integer(value))
    }

    // Create a float attribute.
    /// - Parameter value: The value of the attribute.
    /// - Returns: The float attribute.
    public static func float(_ value: Double) -> Attribute {
        .line(.float(value))
    }

    /// Create an expression attribute.
    /// - Parameters:
    ///   - value: The value of the expression.
    ///   - language: The language of the expression.
    /// - Returns: The expression attribute.
    public static func expression(_ value: Expression, language: Language) -> Attribute {
        .line(.expression(value, language: language))
    }

    // Create a line attribute.
    /// - Parameter value: The value of the attribute.
    /// - Returns: The line attribute.
    public static func line(_ value: String) -> Attribute {
        .line(.line(value))
    }

    /// Create a code attribute.
    /// - Parameters:
    ///   - value: The code.
    ///   - language: The language of the code.
    /// - Returns: The code attribute.
    public static func code(_ value: String, language: Language) -> Attribute {
        .block(.code(value, language: language))
    }

    // Create a text attribute.
    /// - Parameter value: The value of the attribute.
    /// - Returns: The text attribute.
    public static func text(_ value: String) -> Attribute {
        .block(.text(value))
    }

    /// Create a collection of bools.
    /// - Parameter bools: The bools in the collection.
    /// - Returns: A collection of bools.
    public static func collection(bools: [Bool]) -> Attribute {
        .block(.collection(bools.map { Attribute.bool($0) }, display: nil, type: .bool))
    }

    /// Create a collection of integers.
    /// - Parameter integers: The integers in the collection.
    /// - Returns: A collection of integers.
    public static func collection(integers: [Int]) -> Attribute {
        .block(.collection(integers.map { Attribute.integer($0) }, display: nil, type: .integer))
    }

    /// Create a collection of floats.
    /// - Parameter floats: The floats in the collection.
    /// - Returns: A collection of floats.
    public static func collection(floats: [Double]) -> Attribute {
        .block(.collection(floats.map { Attribute.float($0) }, display: nil, type: .float))
    }

    /// Create a collection of expressions.
    /// - Parameter expressions: The expressions in the collection.
    /// - Parameter language: The language of the expressions.
    /// - Returns: A collection of expressions.
    public static func collection(expressions: [Expression], language: Language) -> Attribute {
        .block(
            .collection(
                expressions.map { Attribute.expression($0, language: language) },
                display: nil,
                type: .expression(language: language)
            )
        )
    }

    /// Create a collection of lines.
    /// - Parameter lines: The lines in the collection.
    /// - Returns: A collection of lines.
    public static func collection(lines: [String]) -> Attribute {
        .block(.collection(lines.map { Attribute.line($0) }, display: nil, type: .line))
    }

    /// Create a collection of code.
    /// - Parameter code: The expressions in the collection.
    /// - Parameter language: The language of the code.
    /// - Returns: A collection of code.
    public static func collection(code: [String], language: Language) -> Attribute {
        .block(
            .collection(
                code.map { Attribute.code($0, language: language) },
                display: nil,
                type: .code(language: language)
            )
        )
    }

    /// Create a collection of text.
    /// - Parameter text: The text in the collection.
    /// - Returns: A collection of text.
    public static func collection(text: [String]) -> Attribute {
        .block(.collection(text.map { Attribute.text($0) }, display: nil, type: .text))
    }

    /// Create a collection of complex attributes.
    /// - Parameters:
    ///   - complex: The complex values in the collection.
    ///   - layout: The layout of the complex attributes.
    ///   - display: The display path of the collection.
    /// - Returns: A collection of complex attributes.
    public static func collection(
        complex: [[Label: Attribute]],
        layout: [Field],
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(
            .collection(
                complex.map { Attribute.complex($0, layout: layout) },
                display: display,
                type: .complex(layout: layout)
            )
        )
    }

    /// Create a collection of enumerated attributes.
    /// - Parameters:
    ///   - enumerated: The enumerated values in the collection.
    ///   - validValues: The valid values of the enumerations.
    ///   - display: The display path of the collection.
    /// - Returns: A collection of enumerated attributes.
    public static func collection(
        enumerated: [String],
        validValues: Set<String>,
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(
            .collection(
                enumerated.map { Attribute.enumerated($0, validValues: validValues) },
                display: display,
                type: .enumerated(validValues: validValues)
            )
        )
    }

    /// Create a collection of enumerated collections.
    /// - Parameters:
    ///   - enumerables: The enumerated collections in the new collection.
    ///   - validValues: The valid values of the enumerated collections.
    ///   - display: The display path of the new collection.
    /// - Returns: A new collection of enumerated collections.
    public static func collection(
        enumerables: [Set<String>],
        validValues: Set<String>,
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(
            .collection(
                enumerables.map { Attribute.enumerableCollection($0, validValues: validValues) },
                display: display,
                type: .enumerableCollection(validValues: validValues)
            )
        )
    }

    /// Create a collection of tables.
    /// - Parameters:
    ///   - tables: The tables to store in the collection.
    ///   - columns: The columns in these tables.
    ///   - display: The display path to the new collection.
    /// - Returns: A collection of tables.
    public static func collection(
        tables: [[[LineAttribute]]],
        columns: [(name: Label, type: LineAttributeType)],
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(
            .collection(
                tables.map { Attribute.table($0, columns: columns) },
                display: display,
                type: .table(columns: columns)
            )
        )
    }

    /// Create a collection of collections.
    /// - Parameters:
    ///   - collection: The collections in the new collection.
    ///   - type: The type of the elements in the collections.
    ///   - display: The display path of the new collection.
    /// - Returns: A collection of collections.
    public static func collection(
        collection: [[Attribute]],
        type: AttributeType,
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(
            .collection(
                collection.map { Attribute.collection($0, type: type) },
                display: display,
                type: .collection(type: type)
            )
        )
    }

    /// Create a collection of Attributes.
    /// - Parameters:
    ///   - values: The Attributes in the collection.
    ///   - type: The type of the Attributes. Each Attribute must be the same type.
    ///   - display: The display path of the new collection.
    /// - Returns: A collection of Attributes.
    public static func collection(
        _ values: [Attribute],
        type: AttributeType,
        display: ReadOnlyPath<Attribute, LineAttribute>? = nil
    ) -> Attribute {
        .block(.collection(values, display: display, type: type))
    }

    /// Create a complex attribute.
    /// - Parameters:
    ///   - values: The values of the complex attribute.
    ///   - layout: The layout of the complex attribute.
    /// - Returns: A new complex attribute.
    public static func complex(_ values: [Label: Attribute], layout: [Field]) -> Attribute {
        .block(.complex(values, layout: layout))
    }

    /// Create an enumerated attribute.
    /// - Parameters:
    ///   - value: The value of the enumerated attribute.
    ///   - validValues: The valid values in the enumerated attribute.
    /// - Returns: A new enumerated attribute.
    public static func enumerated(_ value: String, validValues: Set<String>) -> Attribute {
        .line(.enumerated(value, validValues: validValues))
    }

    /// Create an enumerable collection.
    /// - Parameters:
    ///   - value: The values in the enumerable collection.
    ///   - validValues: The valid values in the enumerable collection.
    /// - Returns: A new enumerable collection.
    public static func enumerableCollection(_ value: Set<String>, validValues: Set<String>) -> Attribute {
        .block(.enumerableCollection(value, validValues: validValues))
    }

    /// Create a table attribute.
    /// - Parameters:
    ///   - rows: The row in the table.
    ///   - columns: The columns in the table.
    /// - Returns: A new table attribute.
    public static func table(
        _ rows: [[LineAttribute]],
        columns: [(name: Label, type: LineAttributeType)]
    ) -> Attribute {
        .block(
            .table(
                rows,
                columns: columns.map { BlockAttributeType.TableColumn(name: $0.name, type: $0.type) }
            )
        )
    }

}

// swiftlint:enable type_body_length

/// Codable conformance.
extension Attribute: Codable {

    /// Decoder init.
    public init(from decoder: Decoder) throws {
        if let lineAttribute = try? LineAttribute(from: decoder) {
            self = .line(lineAttribute)
            return
        }
        if let blockAttribute = try? BlockAttribute(from: decoder) {
            self = .block(blockAttribute)
            return
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported value"
            )
        )
    }

    /// Encode function.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .line(let attribute):
            try attribute.encode(to: encoder)
        case .block(let attribute):
            try attribute.encode(to: encoder)
        }
    }

}

/// XMIConvertible conformance.
extension Attribute: XMIConvertible {

    /// The XMI name of this attribute.
    public var xmiName: String? {
        switch self {
        case .line(let attribute):
            return attribute.xmiName
        case .block(let attribute):
            return attribute.xmiName
        }
    }

}

// swiftlint:enable file_length
