/*
 * BlockAttribute.swift
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

import swift_helpers
import XMI

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Attributes that contain other attribute types or fill a block pattern.
public enum BlockAttribute: Hashable, Identifiable {

    /// A code value represents a block of text but has syntax highlighting for a
    /// language.
    case code(_ value: String, language: Language)

    /// A block of text.
    case text(_ value: String)

    /// A collection is an array of values that share the same type.
    indirect case collection(
        _ values: [Attribute], display: ReadOnlyPath<Attribute, LineAttribute>?, type: AttributeType
    )

    /// A complex is a collection of data that has a specific layout.
    indirect case complex(_ data: [Label: Attribute], layout: [Field])

    /// An enumerable collection is a set of values drawn from a set of valid values.
    case enumerableCollection(_ values: Set<String>, validValues: Set<String>)

    /// A table is a collection of rows and columns with different types and headings.
    case table([[LineAttribute]], columns: [BlockAttributeType.TableColumn])

    /// The id of the attribute.
    public var id: Int {
        BlockAttributeIDCache.id(for: self)
    }

    /// The type of the attribute.
    @inlinable public var type: BlockAttributeType {
        switch self {
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
            return .table(columns: columns)
        }
    }

    /// The string equivalent of the attribute.
    @inlinable public var strValue: String? {
        switch self {
        case .code(let value, _):
            return value
        case .collection(let values, _, _):
            return values.lazy.compactMap { $0.strValue }.first
        case .complex(let data, _):
            return data.sorted { $0.key < $1.key }.lazy.compactMap { $1.strValue }.first
        case .enumerableCollection(let values, _):
            return values.min()
        case .table(let rows, _):
            return rows.first?.first?.strValue
        case .text(let value):
            return value
        }
    }

    /// Represent self as a code value.
    /// - Warning: Using this property when self is not a code value will cause a
    ///            runtime error.
    @inlinable public var codeValue: String {
        get {
            switch self {
            case .code(let value, _):
                return value
            default:
                fatalError(
                    "Attempting to fetch a code value on a block attribute which is not a code attribute"
                )
            }
        }
        set {
            switch self {
            case .code(_, let language):
                self = .code(newValue, language: language)
            default:
                fatalError(
                    "Attempting to set a code value on a block attribute which is not a code attribute"
                )
            }
        }
    }

    /// Represent self as a text value.
    /// - Warning: Using this property when self is not a text value will cause a
    ///            runtime error.
    @inlinable public var textValue: String {
        get {
            switch self {
            case .text(let value):
                return value
            default:
                fatalError(
                    "Attempting to fetch a text value on a block attribute which is not a text attribute"
                )
            }
        }
        set {
            switch self {
            case .text:
                self = .text(newValue)
            default:
                fatalError(
                    "Attempting to set a text value on a block attribute which is not a text attribute"
                )
            }
        }
    }

    /// Represent self as a collection value.
    /// - Warning: Using this property when self is not a collection value will cause a
    ///            runtime error.
    @inlinable public var collectionValue: [Attribute] {
        get {
            switch self {
            case .collection(let value, _, _):
                return value
            default:
                fatalError(
                    """
                    Attempting to fetch a collection value on a block attribute which is not a
                    collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                self = .collection(newValue, display: display, type: type)
            default:
                fatalError(
                    """
                    Attempting to set a collection value on a block attribute which is not
                    a collection attribute
                    """
                )
            }
        }
    }

    /// Access the fields in a complex value.
    /// - Warning: Using this property when self is not a complex value will cause a
    ///            runtime error.
    @inlinable public var complexFields: [Field] {
        get {
            switch self {
            case .complex(_, let fields):
                return fields
            default:
                fatalError(
                    """
                    Attempting to fetch a complex value on a block attribute which is
                    not a complex attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .complex(let values, _):
                self = .complex(values, layout: newValue)
            default:
                fatalError(
                    "Attempting to set a complex value on a block attribute which is not a complex attribute"
                )
            }
        }
    }

    /// Represent self as a complex value.
    /// - Warning: Using this property when self is not a complex value will cause a
    ///            runtime error.
    @inlinable public var complexValue: [Label: Attribute] {
        get {
            switch self {
            case .complex(let values, _):
                return values
            default:
                fatalError(
                    """
                    Attempting to fetch a complex value on a block attribute which is
                    not a complex attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .complex(_, let layout):
                self = .complex(newValue, layout: layout)
            default:
                fatalError(
                    "Attempting to set a complex value on a block attribute which is not a complex attribute"
                )
            }
        }
    }

    /// Represent self as an enumerable collection value.
    /// - Warning: Using this property when self is not an enumerable collection value will cause a
    ///            runtime error.
    @inlinable public var enumerableCollectionValue: Set<String> {
        get {
            switch self {
            case .enumerableCollection(let values, _):
                return values
            default:
                fatalError(
                    """
                    Attempting to fetch an enumerable collection value on a block attribute which is
                    not an enumerable collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .enumerableCollection(_, let validValues):
                self = .enumerableCollection(newValue, validValues: validValues)
            default:
                fatalError(
                    """
                    Attempting to set an enumerable collection value on a block attribute which is not an
                    enumerable collection attribute
                    """
                )
            }
        }
    }

    /// Access the valid values in self assuming self is an enumerated collection.
    /// - Warning: Using this property when self is not an enumerated collection will cause a
    ///            runtime error.
    @inlinable public var enumerableCollectionValidValues: Set<String> {
        get {
            switch self {
            case .enumerableCollection(_, let validValues):
                return validValues
            default:
                fatalError(
                    """
                    Attempting to fetch enumerable collection valid values on a block attribute
                    which is not an enumerable collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .enumerableCollection(let values, _):
                self = .enumerableCollection(values, validValues: newValue)
            default:
                fatalError(
                    """
                    Attempting to set enumerable collection valid values on a block attribute
                    which is not an enumerable collection attribute
                    """
                )
            }
        }
    }

    /// Represent self as a table value.
    /// - Warning: Using this property when self is not a table value will cause a
    ///            runtime error.
    @inlinable public var tableValue: [[LineAttribute]] {
        get {
            switch self {
            case .table(let values, _):
                return values
            default:
                fatalError(
                    "Attempting to fetch table value on a block attribute which is not a table attribute"
                )
            }
        } set {
            switch self {
            case .table(_, let columns):
                self = .table(newValue, columns: columns)
            default:
                fatalError(
                    "Attempting to set table value on a block attribute which is not a table attribute"
                )
            }
        }
    }

    /// Access the collection values as Bools.
    /// - Warning: Using this property when self is not a collection containing Bools will cause a
    ///            runtime error.
    @inlinable public var collectionBools: [Bool] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .bool:
                    return values.map { $0.boolValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection bool value on a block attribute which
                        is not a collection bool attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection bool value on a block attribute which is
                    not a collection bool attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .bool:
                    self = .collection(newValue.map { Attribute.bool($0) }, display: display, type: type)
                default:
                    fatalError(
                        """
                        Attempting to set a collection bool value on a block attribute which is
                        not a collection bool attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection bool value on a block attribute which is
                    not a collection bool attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Integers.
    /// - Warning: Using this property when self is not a collection containing integers will cause a
    ///            runtime error.
    @inlinable public var collectionIntegers: [Int] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .integer:
                    return values.map { $0.integerValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection integer value on a block attribute which
                        is not a collection integer attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection integer value on a block attribute which
                    is not a collection integer attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .integer:
                    self = .collection(newValue.map { Attribute.integer($0) }, display: display, type: type)
                default:
                    fatalError(
                        """
                        Attempting to set a collection integer value on a block attribute which
                        is not a collection integer attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection integer value on a block attribute which
                    is not a collection integer attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Floats.
    /// - Warning: Using this property when self is not a collection containing Floats will cause a
    ///            runtime error.
    @inlinable public var collectionFloats: [Double] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .float:
                    return values.map { $0.floatValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection float value on a block attribute which
                        is not a collection float attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection float value on a block attribute
                    which is not a collection float attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .float:
                    self = .collection(newValue.map { Attribute.float($0) }, display: display, type: type)
                default:
                    fatalError(
                        """
                        Attempting to set a collection float value on a block attribute which
                        is not a collection float attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection float value on a block attribute which
                    is not a collection float attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Expressions.
    /// - Warning: Using this property when self is not a collection containing Expressions will cause a
    ///            runtime error.
    @inlinable public var collectionExpressions: [Expression] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .line(.expression):
                    return values.map { $0.expressionValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection expression value on a block attribute
                        which is not a collection expression attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection expression value on a
                    block attribute which is not a collection expression attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .line(.expression(let language)):
                    self = .collection(
                        newValue.map { Attribute.expression($0, language: language) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection expression value on a block attribute which
                        is not a collection expression attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection expression value on a block attribute
                    which is not a collection expression attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Enumerations.
    /// - Warning: Using this property when self is not a collection containing Enumerations will cause a
    ///            runtime error.
    @inlinable public var collectionEnumerated: [String] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .line(.enumerated):
                    return values.map { $0.enumeratedValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection enumerated value on a block attribute
                        which is not a collection enumerated attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection enumerated value on a block
                    attribute which is not a collection enumerated attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .line(.enumerated(let validValues)):
                    self = .collection(
                        newValue.map { Attribute.enumerated($0, validValues: validValues) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection enumerated value on a block attribute
                        which is not a collection enumerated attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection enumerated value on a block attribute
                    which is not a collection enumerated attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Lines.
    /// - Warning: Using this property when self is not a collection containing Lines will cause a
    ///            runtime error.
    @inlinable public var collectionLines: [String] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .line:
                    return values.map { $0.lineValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection lines value on a block attribute
                        which is not a collection lines attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection lines value on a block attribute
                    which is not a collection lines attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .line(.line):
                    self = .collection(newValue.map { Attribute.line($0) }, display: display, type: type)
                default:
                    fatalError(
                        """
                        Attempting to set a collection lines value on a block attribute
                        which is not a collection lines attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection lines value on a block attribute
                    which is not a collection lines attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Codes.
    /// - Warning: Using this property when self is not a collection containing Codes will cause a
    ///            runtime error.
    @inlinable public var collectionCode: [String] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .block(.code):
                    return values.map { $0.codeValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection code value on a block attribute
                        which is not a collection code attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection code value on a block attribute
                    which is not a collection code attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .block(.code(let language)):
                    self = .collection(
                        newValue.map { Attribute.code($0, language: language) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection code value on a block attribute
                        which is not a collection code attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection code value on a block attribute
                    which is not a collection code attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Texts.
    /// - Warning: Using this property when self is not a collection containing Texts will cause a
    ///            runtime error.
    @inlinable public var collectionText: [String] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .text:
                    return values.map { $0.textValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection text value on a block attribute
                        which is not a collection text attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection text value on a block attribute
                    which is not a collection text attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .block(.text):
                    self = .collection(newValue.map { Attribute.text($0) }, display: display, type: type)
                default:
                    fatalError(
                        """
                        Attempting to set a collection text value on a block attribute
                        which is not a collection text attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection text value on a block attribute which
                    is not a collection text attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Complexes.
    /// - Warning: Using this property when self is not a collection containing Complexes will cause a
    ///            runtime error.
    @inlinable public var collectionComplex: [[Label: Attribute]] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .block(.complex):
                    return values.map { $0.complexValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection complex value on a block attribute
                        which is not a collection complex attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection complex value on a block attribute
                    which is not a collection complex attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .block(.complex(let layout)):
                    self = .collection(
                        newValue.map { Attribute.complex($0, layout: layout) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection complex value on a block attribute which
                        is not a collection complex attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection complex value on a block attribute
                    which is not a collection complex attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Enumerable Collections.
    /// - Warning: Using this property when self is not a collection containing Enumerable Collections
    ///            will cuase a runtime error.
    @inlinable public var collectionEnumerableCollection: [Set<String>] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .block(.enumerableCollection):
                    return values.map { $0.enumerableCollectionValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection enumerable collection value on a block attribute
                        which is not a collection enumerable collection attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection enumerable collection value on a block attribute which
                    is not a collection enumerable collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .block(.enumerableCollection(let validValues)):
                    self = .collection(
                        newValue.map { Attribute.enumerableCollection($0, validValues: validValues) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection enumerable collection value on a block
                        attribute which is not a collection enumerable collection attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection enumerable collection value on a block
                    attribute which is not a collection enumerable collection attribute
                    """
                )
            }
        }
    }

    /// Access the collection values as Tables.
    /// - Warning: Using this property when self is not a collection containing Tables will cause a
    ///            runtime error.
    @inlinable public var collectionTable: [[[LineAttribute]]] {
        get {
            switch self {
            case .collection(let values, _, type: let type):
                switch type {
                case .block(.table):
                    return values.map { $0.tableValue }
                default:
                    fatalError(
                        """
                        Attempting to fetch a collection table value on a block
                        attribute which is not a collection table attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to fetch a collection table value on a block
                    attribute which is not a collection table attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(_, let display, let type):
                switch type {
                case .block(.table(let columns)):
                    self = .collection(
                        newValue.map { Attribute.table($0, columns: columns.map { ($0.name, $0.type) }) },
                        display: display,
                        type: type
                    )
                default:
                    fatalError(
                        """
                        Attempting to set a collection table value on a block
                        attribute which is not a collection table attribute
                        """
                    )
                }
            default:
                fatalError(
                    """
                    Attempting to set a collection table value on a block attribute
                    which is not a collection table attribute
                    """
                )
            }
        }
    }

    /// Access the collection display.
    /// - Warning: Using this property when self is not a collection will cause a
    ///            runtime error.
    @inlinable public var collectionDisplay: ReadOnlyPath<Attribute, LineAttribute>? {
        get {
            switch self {
            case .collection(_, let display, _):
                return display
            default:
                fatalError(
                    """
                    Attempting to fetch a collection display value on a
                    block attribute which is not a collection attribute
                    """
                )
            }
        }
        set {
            switch self {
            case .collection(let values, _, let type):
                self = .collection(values, display: newValue, type: type)
            default:
                fatalError(
                    """
                    Attempting to set a collection display value on a block
                    attribute which is not a collection attribute
                    """
                )
            }
        }
    }

}

/// XMIConvertible conformance.
extension BlockAttribute: XMIConvertible {

    /// The XMI name of this attribute.
    @inlinable public var xmiName: String? {
        switch self {
        case .code:
            return "CodeAttribute"
        case .text:
            return "TextAttribute"
        case .collection:
            return "CollectionAttribute"
        case .complex:
            return "ComplexAttribute"
        case .enumerableCollection:
            return "EnumerableCollectionAttribute"
        case .table:
            return "TableAttribute"
        }
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
