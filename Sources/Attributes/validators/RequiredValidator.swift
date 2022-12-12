/*
 * RequiredValidator.swift
 * Attributes
 *
 * Created by Callum McColl on 21/11/20.
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

/// A validator that requires values to be present (not nil) for a validation rule.
public struct RequiredValidator<P: ReadOnlyPathProtocol>: PathValidator where P.Value: Nilable {

    /// The type of the object containing the value to be validated.
    public typealias Root = P.Root

    /// The type of the value being validated.
    public typealias Value = P.Value.Wrapped

    /// The type of the Path pointing to the value.
    public typealias PathType = P

    /// The path pointing to the value.
    public let path: PathType

    // swiftlint:disable identifier_name

    /// The function performing the validation.
    @usableFromInline internal let _validate: (Root, Value) throws -> Void

    // swiftlint:enable identifier_name

    /// Create a RequiredValidator for a specific path. This initialiser does not perform any validation on
    /// the value. Essentially this init is used to setup the *required* relationship. The validation will
    /// throw errors if the value is equal to nil but perform no other checks.
    /// - Parameter path: The path to the value to validate.
    @inlinable
    public init(path: PathType) {
        self.init(path) { _, _ in }
    }

    // swiftlint:disable identifier_name

    /// Create a RequiredValidator for a specific path with an extra validation rule. The validator will
    /// still check the value for the presence of nil but may also perform an extra validation step using
    /// the function passed in this init.
    /// - Parameters:
    ///   - path: The path to the value being validated.
    ///   - _validate: An additional validation rule performed after the *required* rule is checked.
    @inlinable
    internal init(_ path: PathType, _validate: @escaping (Root, Value) throws -> Void) {
        self.path = path
        self._validate = _validate
    }

    // swiftlint:enable identifier_name

    /// Perform the validation on a value. This function will check the precense of nil before enacting the
    /// validation function stored in `_validate`. A nil value will through a validation error.
    /// - Parameter root: The root object containing the value to be validated.
    /// - Throws: Throws a ValidationError when the value is nil.
    /// - Throws: Throws an Error when the validation is unsusccessful.
    @inlinable
    public func performValidation(_ root: PathType.Root) throws {
        let value = root[keyPath: self.path.keyPath]
        if value.isNil {
            throw ValidationError(message: "Required", path: self.path)
        }
        _ = try self._validate(root, value.wrappedValue)
    }

    /// Create a new validator that performs an additional validation function immediately after the
    /// validation function stored in self is executed.
    /// - Parameter f: The function to execute after `_validate` is performed.
    /// - Returns: A new validator performing the function composition in it's `performValidation`
    ///            method.
    @inlinable
    public func push(_ f: @escaping (Root, Value) throws -> Void) -> RequiredValidator<P> {
        RequiredValidator(self.path) {
            try self._validate($0, $1)
            try f($0, $1)
        }
    }

    /// Create a type-erased validator from self.
    /// - Parameter builder: The builder used to construct the AnyValidator.
    /// - Returns: The new type-erased validator.
    @inlinable
    public func validate(
        @ValidatorBuilder<PathType.Root> builder: (Self) -> [AnyValidator<PathType.Root>]
    ) -> AnyValidator<PathType.Root> {
        AnyValidator(builder(self))
    }

}
