/*
 * ValidatorFactory.swift
 * Attributes
 *
 * Created by Callum McColl on 11/6/21.
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

/// A simple interface for chaining together different validators. This factory can be reused to create a
/// validator that may perform the task of several validators chained together. This factory will
/// store a function to generate a complex validation rule that can be modified/altered to work with
/// other validators. When the user is satisfied with the validation rule, this factory may be used
/// to generate the validator as many times as required by using the `make` function.
public struct ValidatorFactory<Value> {

    /// The function to create the validator.
    private let _make: () -> AnyValidator<Value>

    /// Whether the validator rule created by `make` is required to succeed.
    private let required: Bool

    /// Initialise this struct from a make function and `required` bool.
    /// - Parameters:
    ///   - required: Whether this validator is required to succeed.
    ///   - make: The function to create the validator.
    private init(required: Bool, make: @escaping () -> AnyValidator<Value>) {
        self._make = make
        self.required = required
    }

    /// Create a factory that produces a validation rule that is required to succeed.
    /// - Returns: The new factory.
    public static func required() -> ValidatorFactory<Value> {
        .init(required: true) { AnyValidator() }
    }

    /// Create a factory that produces a validator that is **not** required to succeed.
    /// - Returns: The new factory.
    public static func optional() -> ValidatorFactory<Value> {
        .init(required: false) { AnyValidator() }
    }

    /// Creates a validator that performs a custom validation function.
    /// - Parameter builder: The custom validation function.
    /// - Returns: The new validator.
    public static func validate(
        @ValidatorBuilder<Value> builder: (ValidatorFactory<Value>) -> AnyValidator<Value>
    ) -> AnyValidator<Value> {
        builder(.init(required: true) { AnyValidator() })
    }

    /// Create a validator that is preconfigured to verify some validation rule. This rule may be created by
    /// chaining together different validators.
    /// - Parameter path: The path to the object to validate..
    /// - Returns: A new validator.
    public func make<Path: ReadOnlyPathProtocol>(
        path: Path
    ) -> AnyValidator<Path.Root> where Path.Value == Value {
        AnyValidator { root in
            if required && path.isNil(root) {
                throw AttributeError(message: "Does not exist", path: AnyPath(path))
            }
            if !required && path.isNil(root) {
                return
            }
            try _make().performValidation(root[keyPath: path.keyPath])
        }
    }

    /// Push a new validator onto the current stack of validation rules.
    /// - Parameter make: A function to generate the new validator.
    /// - Returns: A new factory that incorporates the new validator into the current
    /// stack of validators.
    /// - SeeAlso: ``ValidationPath``.
    internal func push<Validator: ValidatorProtocol>(
        _ make: @escaping (ValidationPath<ReadOnlyPath<Value, Value>>) -> Validator
    ) -> ValidatorFactory<Value> where Validator.Root == Value {
        ValidatorFactory(required: required) {
            let newValidator = make(ValidationPath(path: ReadOnlyPath(keyPath: \Value.self, ancestors: [])))
            return AnyValidator([_make(), AnyValidator(newValidator)])
        }
    }

}

/// Add conditional rules.
extension ValidatorFactory {

    /// Creates a factory that will perform the `if` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Value> then builder: @escaping () -> AnyValidator<Value>
    ) -> ValidatorFactory<Value> {
        push { $0.if(condition, then: builder) }
    }

    /// Creates a factory that will perform the `if` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Value> then builder1: @escaping () -> AnyValidator<Value>,
        @ValidatorBuilder<Value> else builder2: @escaping () -> AnyValidator<Value>
    ) -> ValidatorFactory<Value> {
        push { $0.if(condition, then: builder1, else: builder2) }
    }

}

// extension ValidatorFactory where Value: Equatable {

//     public func `in`<P: ReadOnlyPathProtocol, S: Sequence, S2: Sequence>(_ p: P, transform: @escaping (S) -> S2) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S2.Element == Value {
//         push { $0.in(p, transform: transform) }
//     }

//     public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S.Element == Value {
//         push { $0.in(p) }
//     }

// }

// extension ValidatorFactory where Value: Hashable {

//     public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P, transform: @escaping (S) -> Set<Value>) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S {
//         push { $0.in(p, transform: transform) }
//     }

//     public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S.Element == Value {
//         push { $0.in(p) }
//     }

//     public func `in`<P: ReadOnlyPathProtocol>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == Set<Value> {
//         push { $0.in(p) }
//     }

//     public func `in`(_ set: Set<Value>) -> ValidatorFactory<Value> {
//         push { $0.in(set) }
//     }

// }

/// Adds equal methods.
extension ValidatorFactory where Value: Equatable {

    /// Creates a factory that will perform the `equals` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func equals(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.equals(value) }
    }

    /// Creates a factory that will perform the `notEquals` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func notEquals(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.notEquals(value) }
    }

}

/// Adds equal methods for boolean values.
extension ValidatorFactory where Value == Bool {

    /// Creates a factory that will perform the `equalsFalse` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func equalsFalse() -> ValidatorFactory<Value> {
        push { $0.equalsFalse() }
    }

    /// Creates a factory that will perform the `equalsTrue` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func equalsTrue() -> ValidatorFactory<Value> {
        push { $0.equalsTrue() }
    }

}

/// Add comparable methods.
extension ValidatorFactory where Value: Comparable {

    /// Creates a factory that will perform the `between` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func between(min: Value, max: Value) -> ValidatorFactory<Value> {
        push { $0.between(min: min, max: max) }
    }

    /// Creates a factory that will perform the `lessThan` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func lessThan(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.lessThan(value) }
    }

    /// Creates a factory that will perform the `lessThanEqual` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func lessThanEqual(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.lessThanEqual(value) }
    }

    /// Creates a factory that will perform the `greaterThan` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func greaterThan(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.greaterThan(value) }
    }

    /// Creates a factory that will perform the `greaterThanEqual` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func greaterThanEqual(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.greaterThanEqual(value) }
    }

}

/// Add collection methods.
extension ValidatorFactory where Value: Collection {

    /// Creates a factory that will perform the `empty` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func empty() -> ValidatorFactory<Value> {
        push { $0.empty() }
    }

    /// Creates a factory that will perform the `notEmpty` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func notEmpty() -> ValidatorFactory<Value> {
        push { $0.notEmpty() }
    }

    /// Creates a factory that will perform the `length` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func length(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.length(length) }
    }

    /// Creates a factory that will perform the `minLength` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func minLength(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.minLength(length) }
    }

    /// Creates a factory that will perform the `maxLength` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func maxLength(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.maxLength(length) }
    }

}

/// Add unique method.
extension ValidatorFactory where Value: Sequence {

    /// Creates a factory that will perform the `unique` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func unique<S: Sequence>(
        _ transform: @escaping (Value) -> S
    ) -> ValidatorFactory<Value> where S.Element: Hashable {
        push { $0.unique(transform) }
    }

}

/// Add unique method.
extension ValidatorFactory where Value: Sequence, Value.Element: Hashable {

    /// Creates a factory that will perform the `unique` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func unique() -> ValidatorFactory<Value> {
        push { $0.unique() }
    }

}

/// Add string methods.
extension ValidatorFactory where Value: StringProtocol {

    /// Creates a factory that will perform the `alpha` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alpha() -> ValidatorFactory<Value> {
        push { $0.alpha() }
    }

    /// Creates a factory that will perform the `alphadash` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alphadash() -> ValidatorFactory<Value> {
        push { $0.alphadash() }
    }

    /// Creates a factory that will perform the `alphafirst` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alphafirst() -> ValidatorFactory<Value> {
        push { $0.alphafirst() }
    }

    /// Creates a factory that will perform the `alphanumeric` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alphanumeric() -> ValidatorFactory<Value> {
        push { $0.alphanumeric() }
    }

    /// Creates a factory that will perform the `alphaunderscore` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alphaunderscore() -> ValidatorFactory<Value> {
        push { $0.alphaunderscore() }
    }

    /// Creates a factory that will perform the `alphaunderscorefirst` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func alphaunderscorefirst() -> ValidatorFactory<Value> {
        push { $0.alphaunderscorefirst() }
    }

    /// Creates a factory that will perform the `blacklist` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func blacklist(_ list: Set<String>) -> ValidatorFactory<Value> {
        push { $0.blacklist(list) }
    }

    /// Creates a factory that will perform the `numeric` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func numeric() -> ValidatorFactory<Value> {
        push { $0.numeric() }
    }

    /// Creates a factory that will perform the `whitelist` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func whitelist(_ list: Set<String>) -> ValidatorFactory<Value> {
        push { $0.whitelist(list) }
    }

    /// Creates a factory that will perform the `greyList` rule. For a full list of rules,
    /// see ``ValidationPushProtocol``.
    /// - SeeAlso: ``ValidationPushProtocol``.
    public func greyList(_ list: Set<String>) -> ValidatorFactory<Value> {
        push { $0.greyList(list) }
    }

}
