/*
 * ValidationPushProtocol.swift
 * Attributes
 *
 * Created by Callum McColl on 8/11/20.
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

/// This protocol provides a mechanism for chaining different validators together into a
/// single validator that can perform a single validation function. This protocol also
/// forms a basis for defining common validation function such as validating that
/// collections aren't empty, or that collections have a specific amount of elements, etc.
/// 
/// The fundamental function of the type of operations described above is the `push` method
/// that acts as a pure function creating more instances of `PushValidator` by combining
/// validation functions sequentially together.
/// - SeeAlso: ``PathValidator``.
public protocol ValidationPushProtocol: ReadOnlyPathContainer {

    /// The type of the root object this protocol acts upon.
    associatedtype Root

    /// The type of the Value contained within `Root` that this protocol acts upon.
    associatedtype Value

    /// The validator type used by this protocol.
    associatedtype PushValidator: PathValidator

    /// Push a new validation function onto the stack of existing validators.
    /// - Parameter f: The new validation function.
    /// - Returns: A new validator that uses pre-existing validation functions and the
    /// new validation function `f` sequentially.
    func push(_ f: @escaping (Root, Value) throws -> Void) -> PushValidator

}

/// Add conditional validation rules.
extension ValidationPushProtocol {

    /// Perform some validation function given that a precondition is met.
    /// - Parameters:
    ///   - condition: The condition that triggers the validation function.
    ///   - builder: The validation function performed when `condition` is true.
    /// - Returns: A new validator that performs the validation functions contained
    /// within `builder` when `condition` is true.
    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Root> then builder: @escaping () -> AnyValidator<Root>
    ) -> PushValidator {
        push {
            if condition($1) {
                try builder().performValidation($0)
            }
        }
    }

    /// Perform some validation function `builder1` provided that a precondition is met, otherwise
    /// perform a different validation function `builder2`.
    /// - Parameters:
    ///   - condition: The condition that determins whether `builder1` or `builder2` is executed.
    ///   - builder1: The validation function that is executed when `condition` is true.
    ///   - builder2: The validation function that is executed when `condition` is false.
    /// - Returns: A new validator that performs the validation function `builder1` when `condition`
    /// is true, or `builder2` otherwise.
    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Root> then builder1: @escaping () -> AnyValidator<Root>,
        @ValidatorBuilder<Root> else builder2: @escaping () -> AnyValidator<Root>
    ) -> PushValidator {
        push {
            if condition($1) {
                try builder1().performValidation($0)
            } else {
                try builder2().performValidation($0)
            }
        }
    }

}

//extension ValidationPushProtocol where Value: Nilable {
//
//    public func ifNil(@ValidatorBuilder<Root> then builder: @escaping () -> [AnyValidator<Root>]) -> PushValidator {
//        return push {
//            if $1.isNil {
//                try AnyValidator(builder()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNil(
//        @ValidatorBuilder<Root> then builder1: @escaping () -> [AnyValidator<Root>],
//        @ValidatorBuilder<Root> else builder2: @escaping () -> [AnyValidator<Root>]
//    ) -> PushValidator {
//        return push {
//            if $1.isNil {
//                try AnyValidator(builder1()).performValidation($0)
//            } else {
//                try AnyValidator(builder2()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNotNil(@ValidatorBuilder<Root> then builder: @escaping () -> [AnyValidator<Root>]) -> PushValidator {
//        return push {
//            if !$1.isNil {
//                try AnyValidator(builder()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNotNil(
//        @ValidatorBuilder<Root> then builder1: @escaping () -> [AnyValidator<Root>],
//        @ValidatorBuilder<Root> else builder2: @escaping () -> [AnyValidator<Root>]
//    ) -> PushValidator {
//        return push {
//            if !$1.isNil {
//                try AnyValidator(builder1()).performValidation($0)
//            } else {
//                try AnyValidator(builder2()).performValidation($0)
//            }
//        }
//    }
//
//}

/// Provide *in* methods for collections of `Equatable` elements.
extension ValidationPushProtocol where Value: Equatable {

    /// Satisfies a validation if a sequence pointed to by a path `p` contains a given value when
    /// transformed by function `transform`. This method transforms a sequence pointed to by `p`
    /// and passes a validation if a value is within the new transformed sequence.
    /// - Parameters:
    ///   - p: A path to the sequence to transform.
    ///   - transform: The transformation function that transforms the sequence pointed to by `p`
    /// into a new sequence.
    /// - Returns: A new validator that performs a validation function validating that a specific value exists
    /// in the transformed sequence.
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence, S2: Sequence>(
        _ p: P, transform: @escaping (S) -> S2
    ) -> PushValidator where P.Root == Root, P.Value == S, S2.Element == Value {
        push { root, value in
            let collection = transform(root[keyPath: p.keyPath])
            if !collection.contains(value) {
                throw ValidationError(
                    message: "Must equal one of the following: '" +
                        "\(collection.map { "\($0)" }.joined(separator: ", "))'.",
                    path: AnyPath(path)
                )
            }
        }
    }

    /// Satisfies a validation if a value is within a sequence specified by a path.
    /// - Parameter p: The path pointing to the sequence that might contain a value.
    /// - Returns: A new validator that performs a validation function that ensures that values exist within
    /// a sequence specified by `p`.
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(
        _ p: P
    ) -> PushValidator where P.Root == Root, P.Value == S, S.Element == Value {
        push { root, value in
            let collection = root[keyPath: p.keyPath]
            if !collection.contains(value) {
                throw ValidationError(
                    message: "Must equal one of the following: '" +
                        "\(collection.map { "\($0)" }.joined(separator: ", "))'.",
                    path: path
                )
            }
        }
    }

}

/// Provide *in* methods for collections of `Hashable` elements.
extension ValidationPushProtocol where Value: Hashable {

    /// Satisfies a validation if a value is within a sequence specified by a path.
    /// - Parameter p: The path pointing to the sequence that might contain a value.
    /// - Returns: A new validator that performs a validation function that ensures values are within
    /// a sequence specified by `p`.
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(
        _ p: P
    ) -> PushValidator where P.Root == Root, P.Value == S, S.Element == Value {
        push {
            let set = Set($0[keyPath: p.keyPath])
            if !set.contains($1) {
                throw ValidationError(
                    message: "Must equal one of the following: '" +
                        "\(set.map { "\($0)" }.joined(separator: ", "))'.",
                    path: path
                )
            }
        }
    }

    /// Satisfies a validation function when a value exists within a given set.
    /// - Parameter set: The set of valid values.
    /// - Returns: A new validator that performs a validation function that ensures a given value exists
    /// within `set`.
    public func `in`(_ set: Set<Value>) -> PushValidator {
        push {
            if !set.contains($1) {
                throw ValidationError(message: "Must equal one of the following: '\(set)'.", path: path)
            }
        }
    }

}

/// Provides equality methods.
extension ValidationPushProtocol where Value: Equatable {

    /// Satisfies a validation function when a given value is equal to a specific value.
    /// - Parameter value: The value that causes the validation to pass.
    /// - Returns: A new validator that performs a validation that ensures a value is equal to
    /// `value`.
    public func equals(_ value: Value) -> PushValidator {
        push {
            if $1 != value {
                throw ValidationError(message: "Must equal \(value).", path: path)
            }
        }
    }

    /// Satisfies a validation function when a given value is not equal to a specific value.
    /// - Parameter value: The value the causes the validation not to pass. The validator
    /// will only pass when a given value is not equal to this `value`.
    /// - Returns: A new validator that passes when a given parameter is not equal
    /// to `value`.
    public func notEquals(_ value: Value) -> PushValidator {
        push {
            if $1 == value {
                throw ValidationError(message: "Must not equal \(value).", path: path)
            }
        }
    }

}

/// Extra methods when the value is a boolean.
extension ValidationPushProtocol where Value == Bool {

    /// Satisfies a validation when the given value is *false*.
    /// - Returns: A new validator that passes when a given boolean value is *false*.
    public func equalsFalse() -> PushValidator {
        self.equals(false)
    }

    /// Satisfies a validation when the given value is *true*.
    /// - Returns: A new validator that passes when a given boolean value is *true*.
    public func equalsTrue() -> PushValidator {
        self.equals(true)
    }

}

/// Provides `Comparable` methods.
extension ValidationPushProtocol where Value: Comparable {

    /// Satisfies a validation when a given value is between a minimum and maximum value
    /// inclusively.
    /// - Parameters:
    ///   - min: The minimum value that passes the validator.
    ///   - max: The maximum value that passes the validator.
    /// - Returns: A new validator that passes when a given value is between `min`
    /// and `max` inclusively.
    public func between(min: Value, max: Value) -> PushValidator {
        push {
            if $1 < min || $1 > max {
                throw ValidationError(message: "Must be between \(min) and \(max).", path: path)
            }
        }
    }

    /// Satisfies a validation when a given value is less than a specific value.
    /// - Parameter value: The value that a given value must be less then. The validator will
    /// only pass when a given value is less than this `value`.
    /// - Returns: A new validator that checks that a given parameter is less than `value`.
    public func lessThan(_ value: Value) -> PushValidator {
        push {
            if $1 >= value {
                throw ValidationError(message: "Must be less than \(value).", path: path)
            }
        }
    }

    /// Satisfies a validation when a given value is less than or equal to a specific value.
    /// - Parameter value: The value that a given value must be less then or equal to. The validator will
    /// only pass when a given value is less than or equal to this `value`.
    /// - Returns: A new validator that checks that a given parameter is less than or equal to `value`.
    public func lessThanEqual(_ value: Value) -> PushValidator {
        push {
            if $1 > value {
                throw ValidationError(message: "Must be less than or equal to \(value).", path: path)
            }
        }
    }

    /// Satisfies a validation when a given value is greater than a specific value.
    /// - Parameter value: The value that a given value must be greater then. The validator will
    /// only pass when a given value is greater than this `value`.
    /// - Returns: A new validator that is checks that a given parameter is greater than `value`.
    public func greaterThan(_ value: Value) -> PushValidator {
        push {
            if $1 <= value {
                throw ValidationError(message: "Must be greater than \(value).", path: path)
            }
        }
    }

    /// Satisfies a validation when a given value is greater than or equal to a specific value.
    /// - Parameter value: The value that a given value must be greater then or equal to. The validator will
    /// only pass when a given value is greater than or equal to this `value`.
    /// - Returns: A new validator that checks that a given parameter is greater than or equal to
    /// `value`.
    public func greaterThanEqual(_ value: Value) -> PushValidator {
        push {
            if $1 < value {
                throw ValidationError(message: "Must be greater than or equal to \(value).", path: path)
            }
        }
    }

}

/// Provides methods for reasoning about the number of elements in a collection.
extension ValidationPushProtocol where Value: Collection {

    /// Performs a validation that ensures that a given collection is empty.
    /// - Returns: A new validator that checks whether a given collection is empty. A non-empty collection
    /// will throw an error.
    public func empty() -> PushValidator {
        push {
            if !$1.isEmpty {
                throw ValidationError(message: "Must be empty.", path: path)
            }
        }
    }

    /// Performs a validation that ensures a given collection is not empty.
    /// - Returns: A new validator that verifies that a given collection is not empty.
    public func notEmpty() -> PushValidator {
        push {
            if $1.isEmpty {
                throw ValidationError(message: "Cannot be empty.", path: path)
            }
        }
    }

    /// Performs a validation that ensure a given collection has `length` elements.
    /// - Parameter length: The number of elements that passes this validation.
    /// - Returns: A new validator that performs a validation ensuring a collection has `length` elements.
    public func length(_ length: Int) -> PushValidator {
        if length == 0 {
            return empty()
        }
        return push {
            if $1.count != length {
                throw ValidationError(message: "Must have exactly \(length) elements.", path: path)
            }
        }
    }

    /// Performs a validation that verifies the given collection has at least `length` elements.
    /// - Parameter length: The minimum length of a given collection.
    /// - Returns: A new validator that verifies that a collection has at least `length` elements.
    public func minLength(_ length: Int) -> PushValidator {
        if length == 1 {
            return notEmpty()
        }
        return push {
            if $1.count < length {
                throw ValidationError(message: "Must provide at least \(length) values.", path: path)
            }
        }
    }

    /// Performs a validation that verifies a given collection has at most `length` elements.
    /// - Parameter length: The maximum number of elements within a given collection.
    /// - Returns: A new validator verifies that a collection has at most `length`
    /// elements.
    public func maxLength(_ length: Int) -> PushValidator {
        if length == 0 {
            return empty()
        }
        return push {
            if $1.count > length {
                throw ValidationError(message: "Must provide no more than \(length) values.", path: path)
            }
        }
    }

}

/// Add unique method.
extension ValidationPushProtocol where Value: Sequence {

    /// Creates a validator that checks that a transformed sequence contains unique elements, i.e. no
    /// duplicate elements.
    /// - Parameter transform: A function that transforms the given sequence into a sequence of 
    /// hashable elements.
    /// - Returns: A new validator that ensures a transformed collection only contains unique elements.
    public func unique<S: Sequence>(
        _ transform: @escaping (Value) -> S
    ) -> PushValidator where S.Element: Hashable {
        push { _, value in
            var set = Set<S.Element>()
            if transform(value).contains(where: {
                if set.contains($0) {
                    return true
                }
                set.insert($0)
                return false
            }) {
                throw ValidationError(message: "Must be unique", path: path)
            }
        }
    }

}

/// Add unique method for sequences of `Hashable` elements.
extension ValidationPushProtocol where Value: Sequence, Value.Element: Hashable {

    /// Creates a validator that ensures all elements within a given value are unique.
    /// - Returns: A new validator that verifies that all elements within a sequence are
    /// unique.
    public func unique() -> PushValidator {
        push { _, value in
            var set = Set<Value.Element>()
            if value.contains(where: {
                if set.contains($0) {
                    return true
                }
                set.insert($0)
                return false
            }) {
                throw ValidationError(message: "Must be unique", path: path)
            }
        }
    }

}

/// Provide `String` validation methods.
extension ValidationPushProtocol where Value: StringProtocol {

    public func alpha() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter }) {
                throw ValidationError(message: "Must be alphabetic.", path: path)
            }
        }
    }

    public func alphadash() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "-" }) {
                throw ValidationError(message: "Must be alphabetic with underscores and dashes allowed.", path: path)
            }
        }
    }

    public func alphafirst() -> PushValidator {
        return push {
            guard let firstChar = $1.first else {
                return
            }
            if !firstChar.isLetter {
                throw ValidationError(message: "First Character must be alphabetic.", path: path)
            }
        }
    }

    public func alphanumeric() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber }) {
                throw ValidationError(message: "Must be alphanumeric.", path: path)
            }
        }
    }

    public func alphaunderscore() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" }) {
                throw ValidationError(message: "Must be alphabetic with underscores allowed.", path: path)
            }
        }
    }

    public func alphaunderscorefirst() -> PushValidator {
        return push {
            guard let firstChar = $1.first else {
                return
            }
            if !(firstChar.isLetter || firstChar == "_") {
                throw ValidationError(message: "First Character must be alphabetic or an underscore.", path: path)
            }
        }
    }

    public func blacklist(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            if list.contains(String(val)) {
                throw ValidationError(message: "\(val) is a banned word.", path: path)
            }
        }
    }

    public func numeric() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isNumber }) {
                throw ValidationError(message: "Must be numeric.", path: path)
            }
        }
    }

    public func whitelist(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            if !list.contains(String(val)) {
                throw ValidationError(message: "\(val) is not valid, you must use pre-existing words. Candidates: \(list)", path: path)
            }
        }
    }

    public func greyList(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            guard let _ = list.first(where: { val.contains($0) }) else {
                throw ValidationError(message: "\(val) is not valid, it must contain pre-existing words. Candidates: \(list)", path: path)
            }
        }
    }

}
