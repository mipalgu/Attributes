/*
 * EnumerableCollectionProperty.swift
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

/// An EnumerableCollection Property.
@propertyWrapper
public struct EnumerableCollectionProperty {

    /// A self property.
    @inlinable public var projectedValue: EnumerableCollectionProperty {
        self
    }

    /// The underlying SchemaAttribute.
    public var wrappedValue: SchemaAttribute {
        get {
            let validationPath = ValidationPath(path: path)
            let enumeratedRule = AnyValidator(validationPath.each { _, elementPath in
                elementPath.in(self.validValues)
            })
            return SchemaAttribute(
                label: self.label,
                type: .enumerableCollection(validValues: self.validValues),
                validate: AnyValidator([enumeratedRule, self.validator])
            )
        }
        set {
            guard
                case AttributeType.block(let blockAttribute) = newValue.type,
                case BlockAttributeType.enumerableCollection(let values) = blockAttribute
            else {
                fatalError("Invalid type!")
            }
            self.label = newValue.label
            self.validValues = values
        }
    }

    /// The path to the enumerated collection value.
    private let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute
        .enumerableCollectionValue

    /// The label of this property.
    private var label: String

    /// The valid values in this enumeration collection.
    private var validValues: Set<String>

    /// The user-specified validation rules.
    private var validator: AnyValidator<Attribute>

    /// Create the Property from a SchemaAttribute.
    /// - Parameter wrappedValue: The attribute.
    public init(wrappedValue: SchemaAttribute) {
        guard
            case AttributeType.block(let blockAttribute) = wrappedValue.type,
            case BlockAttributeType.enumerableCollection(let values) = blockAttribute
        else {
            fatalError("Invalid type!")
        }
        self.label = wrappedValue.label
        self.validator = wrappedValue.validate
        self.validValues = values
    }

    /// Create the property from a label and builder function.
    /// - Parameters:
    ///   - label: The label of this property.
    ///   - validValues: The valid values for the enumerable collection.
    ///   - builder: A function that creates the validator.
    public init(
        label: String,
        validValues: Set<String>,
        @ValidatorBuilder<Attribute>
            validation builder: (ValidationPath<ReadOnlyPath<Attribute, Set<String>>>)
            -> AnyValidator<Attribute> = { _ in AnyValidator([]) }
    ) {
        self.label = label
        self.validValues = validValues
        self.validator = builder(ValidationPath(path: path))
    }

}
