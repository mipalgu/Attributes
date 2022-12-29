/*
 * TableProperty.swift
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

import Foundation

/// A property that represents data in a table.
@propertyWrapper
public struct TableProperty {

    /// The project value.
    @inlinable public var projectedValue: TableProperty {
        get {
            self
        }
        set {
            self = newValue
        }
    }

    /// The equivalent attribute.
    public private(set) var wrappedValue: SchemaAttribute

    /// Initialise this property from the wrapped value.
    /// - Parameter wrappedValue: The wrapped value.
    public init(wrappedValue: SchemaAttribute) {
        guard
            case AttributeType.block(let blockAttribute) = wrappedValue.type,
            case BlockAttributeType.table(let columns) = blockAttribute
        else {
            fatalError("Invalid type!")
        }
        let row: (Attribute) -> AnyValidator<Attribute> = { attribute in
            let path = CollectionSearchPath(
                collectionPath: Path(Attribute.self).blockAttribute.tableValue,
                elementPath: Path([LineAttribute].self)
            )
            let paths = path.paths(in: attribute)
            return AnyValidator(paths.map { path in
                AnyValidator(ValidationPath(path: path).length(columns.count))
            })
        }
        let tableValidator = AnyValidator(
            Validator(Path(Attribute.self)) { root, _ in
                try row(root).performValidation(root)
            }
        )
        self.wrappedValue = SchemaAttribute(
            label: wrappedValue.label,
            type: wrappedValue.type,
            validate: AnyValidator([tableValidator, wrappedValue.validate])
        )
    }

    /// Intialise this property from table data.
    /// - Parameters:
    ///   - label: The name of the table.
    ///   - columns: The columns in the table.
    ///   - builder: The validator for the table.
    public init(
        label: String,
        columns: [TableColumn],
        @ValidatorBuilder<Attribute> validation builder: (
            ValidationPath<ReadOnlyPath<Attribute, [[LineAttribute]]>>
        ) -> AnyValidator<Attribute> = { _ in AnyValidator([]) }
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.tableValue
        let validationPath = ValidationPath(path: path)
        let validator = builder(validationPath)
        let type: AttributeType = .table(columns: columns.map { ($0.label, $0.type) })
        let row: (Attribute, [TableColumn]) -> AnyValidator<Attribute> = { attribute, columns in
            let path = CollectionSearchPath(
                collectionPath: Path(Attribute.self).blockAttribute.tableValue,
                elementPath: Path([LineAttribute].self)
            )
            let paths = path.paths(in: attribute)
            return AnyValidator(paths.map { path in
                let validationPath = ValidationPath(path: path)
                let lengthRule = AnyValidator(validationPath.length(columns.count))
                let columnRules = AnyValidator(columns.enumerated().map {
                    ChainValidator(path: path[$0], validator: $1.validator)
                })
                return AnyValidator([lengthRule, columnRules])
            })
        }
        let tableValidator = AnyValidator(
            Validator(Path(Attribute.self)) { root, _ in
                try row(root, columns).performValidation(root)
            }
        )
        self.wrappedValue = SchemaAttribute(
            label: label,
            type: type,
            validate: AnyValidator([tableValidator, validator])
        )
    }

    /// Update the table with new columns and validation rules.
    /// - Parameters:
    ///   - columns: The new columns for this table.
    ///   - builder: The validator that validates the table rows.
    public mutating func update(
        columns: [TableColumn],
        @ValidatorBuilder<Attribute> validation builder: (
            ValidationPath<ReadOnlyPath<Attribute, [[LineAttribute]]>>
        ) -> AnyValidator<Attribute> = { _ in AnyValidator([]) }
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.tableValue
        let validationPath = ValidationPath(path: path)
        let validator = builder(validationPath)
        let type: AttributeType = .table(columns: columns.map { ($0.label, $0.type) })
        let row: (Attribute, [TableColumn]) -> AnyValidator<Attribute> = { attribute, columns in
            let path = CollectionSearchPath(
                collectionPath: Path(Attribute.self).blockAttribute.tableValue,
                elementPath: Path([LineAttribute].self)
            )
            let paths = path.paths(in: attribute)
            return AnyValidator(paths.map { path in
                let validationPath = ValidationPath(path: path)
                let lengthRule = AnyValidator(validationPath.length(columns.count))
                let columnRules = AnyValidator(columns.enumerated().map {
                    ChainValidator(path: path[$0], validator: $1.validator)
                })
                return AnyValidator([lengthRule, columnRules])
            })
        }
        let tableValidator = AnyValidator(
            Validator(Path(Attribute.self)) { root, _ in
                try row(root, columns).performValidation(root)
            }
        )
        self.wrappedValue = SchemaAttribute(
            label: self.wrappedValue.label,
            type: type,
            validate: AnyValidator([tableValidator, validator])
        )
    }

}
