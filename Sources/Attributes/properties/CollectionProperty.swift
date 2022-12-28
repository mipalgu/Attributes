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
    public var wrappedValue: SchemaAttribute {
        get {
            self.createSchemaAttribute(self.label, self.type, self.validator)
        }
        set {
            self.label = newValue.label
            self.type = newValue.type
        }
    }

    /// The label of the property.
    private var label: String

    /// The attribute type of the property.
    private var type: AttributeType

    /// The user-specified validation rules.
    private var validator: AnyValidator<Attribute>

    /// A function to create a ``SchemaAttribute`` from the label, type and validator.
    private var createSchemaAttribute: (String, AttributeType, AnyValidator<Attribute>) -> SchemaAttribute = {
        SchemaAttribute(label: $0, type: $1, validate: $2)
    }

    /// Initialise this property from it's wrapped value.
    /// - Parameter wrappedValue: The wrapped value.
    public init(wrappedValue: SchemaAttribute) {
        self.label = wrappedValue.label
        self.type = wrappedValue.type
        self.validator = wrappedValue.validate
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
        self.label = label
        self.type = .collection(type: .bool)
        self.validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.boolValue)
                })
            }
        }
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
        self.label = label
        self.type = .collection(type: .integer)
        self.validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.integerValue)
                })
            }
        }
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
        self.label = label
        self.type = .collection(type: .float)
        self.validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.floatValue)
                })
            }
        }
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
        self.label = label
        self.type = .collection(type: .expression(language: language))
        self.validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.expressionValue)
                })
            }
        }
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
        self.label = label
        self.type = .collection(type: .enumerated(validValues: validValues))
        let validationPath = ValidationPath(path: path)
        self.validator = validationPath.validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.enumeratedValue)
                })
            }
        }
        self.createSchemaAttribute = { label, type, validator in
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
        }
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
        self.label = label
        self.type = .collection(type: .line)
        self.validator = ValidationPath(path: path).validate {
            $0.each { _, elementPath in
                AnyValidator(validatorFactories.map {
                    $0.make(path: elementPath.path.lineAttribute.lineValue)
                })
            }
        }
    }

}
