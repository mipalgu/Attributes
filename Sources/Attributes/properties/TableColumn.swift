// TableColumn.swift 
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

/// A struct that represents a single column in a table. Each column is represented using a
/// ``LineAttribute``.
/// - SeeAlso: ``LineAttribute``.
public struct TableColumn {

    /// The name of the column.
    public var label: String

    /// The type of the attribute stored in the column.
    public var type: LineAttributeType

    /// A validator that verifies the contents of the values within this column.
    public var validator: AnyValidator<LineAttribute>

    /// Initialise with stored property values.
    /// - Parameters:
    ///   - label: The label.
    ///   - type: The type.
    ///   - validator: The validator.
    init(label: String, type: LineAttributeType, validator: AnyValidator<LineAttribute>) {
        self.label = label
        self.type = type
        self.validator = validator
    }

    /// Create a table column that stores boolean values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for a boolean value.
    public static func bool(
        label: String, validation validatorFactories: ValidatorFactory<Bool> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).boolValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .bool, validator: validator)
    }

    /// Create a table column that stores integer values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for an integer value.
    public static func integer(
        label: String, validation validatorFactories: ValidatorFactory<Int> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).integerValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .integer, validator: validator)
    }

    /// Create a table column that stores floating point values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for a floating point value.
    public static func float(
        label: String, validation validatorFactories: ValidatorFactory<Double> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).floatValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .float, validator: validator)
    }

    /// Create a table column that stores expression values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - language: The language the expression is written in.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for an expression value.
    public static func expression(
        label: String, language: Language, validation validatorFactories: ValidatorFactory<Expression> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).expressionValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .expression(language: language), validator: validator)
    }

    /// Create a table column that stores enumerated values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - validValues: The valid values that restrict the possible values that can be stored in this column.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for an enumerated value.
    public static func enumerated(
        label: String, validValues: Set<String>, validation validatorFactories: ValidatorFactory<String> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).enumeratedValue
        let enumeratedValidator = AnyValidator(ValidationPath(path: path).in(validValues))
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(
            label: label,
            type: .enumerated(validValues: validValues),
            validator: AnyValidator([enumeratedValidator, validator])
        )
    }

    /// Create a table column that stores line values.
    /// - Parameters:
    ///   - label: The name of the column.
    ///   - validatorFactories: The validation rules applied to the contents of this column.
    /// - Returns: A ``TableColumn`` for a line value.
    public static func line(
        label: String, validation validatorFactories: ValidatorFactory<String> ...
    ) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).lineValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .line, validator: validator)
    }

}
