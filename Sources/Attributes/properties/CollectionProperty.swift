/*
 * CollectionProperty.swift
 * Attributes
 *
 * Created by Callum McColl on 21/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

/// A property that represents a collection. A collection is used to define an array of one specific
/// attribute.
@propertyWrapper
public struct CollectionProperty {

    /// The project value.
    @inlinable public var projectedValue: CollectionProperty {
        self
    }

    /// The equivalent ``SchemaAttribute``.
    /// - Warning: The validate property within the wrapped value does not update this attribute property
    /// when using the setter. Once this property is created, it assumes the layout of the elements and
    /// usees the default rules for the attribute types. If you intend on making changes that break the
    /// validation rules, or inserting your own rules, the you need to create this `CollectionProperty` using
    /// the initialiser.
    public let wrappedValue: SchemaAttribute

    /// Initialise this property from it's wrapped value.
    /// - Parameter wrappedValue: The wrapped value.
    public init(wrappedValue: SchemaAttribute) {
        self.wrappedValue = wrappedValue
    }

    /// Create a collection of boolean values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    public init(
        label: String,
        bools validatorFactories: ValidatorFactory<Bool> ...
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: .collection(type: .bool),
            validate: ValidationPath(path: path).validate {
                $0.each { _, elementPath in
                    AnyValidator(validatorFactories.map {
                        $0.make(path: elementPath.path.lineAttribute.boolValue)
                    })
                }
            }
        )
    }

    /// Create a collection of integer values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    public init(
        label: String,
        integers validatorFactories: ValidatorFactory<Int> ...
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        let validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.integerValue)
                })
            }
        }
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: .collection(type: .integer),
            validate: validator
        )
    }

    /// Create a collection of floating point values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    public init(
        label: String,
        floats validatorFactories: ValidatorFactory<Double> ...
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        let validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.floatValue)
                })
            }
        }
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: .collection(type: .float),
            validate: validator
        )
    }

    /// Create a collection of expression values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    ///   - language: The language of the expressions.
    public init(
        label: String,
        expressions validatorFactories: ValidatorFactory<Expression> ...,
        language: Language
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        let validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.expressionValue)
                })
            }
        }
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: .collection(type: .expression(language: language)),
            validate: validator
        )
    }

    /// Create a collection of enumerated values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    ///   - validValues: The set of valid values for the enumeration.
    public init(
        label: String,
        enumerations validatorFactories: ValidatorFactory<String> ...,
        validValues: Set<String>
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        let validationPath = ValidationPath(path: path)
        let validator = validationPath.validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.enumeratedValue)
                })
            }
        }
        self.wrappedValue = { label, type, validator in
            guard
                case AttributeType.block(let blockType) = type,
                case BlockAttributeType.collection(let lineAttributeType) = blockType,
                case AttributeType.line(let lineType) = lineAttributeType,
                case LineAttributeType.enumerated(let values) = lineType
            else {
                fatalError("Invalid type")
            }
            let val = validationPath.validate {
                $0.each { _, elementPath in
                    AnyValidator(elementPath.lineAttribute.enumeratedValue.in(values))
                }
            }
            return SchemaAttribute(label: label, type: type, validate: AnyValidator([val, validator]))
        }(label, .collection(type: .enumerated(validValues: validValues)), validator)
    }

    /// Create a collection of line values.
    /// - Parameters:
    ///   - label: The name of the collection.
    ///   - validatorFactories: The validators verifying the values at each element.
    public init(
        label: String,
        lines validatorFactories: ValidatorFactory<String> ...
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.collectionValue
        let validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.lineValue)
                })
            }
        }
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: .collection(type: .line),
            validate: validator
        )
    }

}
