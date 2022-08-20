//
/*
 * OptionalValidator.swift
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

/// Validator that performs validation only when the value is not nil. A nil value does not throw
/// any errors during a validation. For a validator that throws errors for nil values, see
/// `RequiredValidator`
/// - SeeAlso: `RequiredValidator`
public struct OptionalValidator<P: ReadOnlyPathProtocol>: PathValidator where P.Value: Nilable {

    /// The Root of the validator.
    public typealias Root = P.Root

    /// The type of the value contained in root.
    public typealias Value = P.Value.Wrapped

    /// The type of the path pointing to value from root.
    public typealias PathType = P

    /// The path that points to the value to be validated.
    public let path: PathType

    // swiftlint:disable identifier_name

    /// The validation function which performs the validation.
    internal let _validate: (Root, Value) throws -> Void

    // swiftlint:enable identifier_name

    /// Initialise this validator with a Path. This init creates a null-validation function
    /// All values will pass validation without error using this init.
    /// - Parameter path: The path containing the location of the value to validate.
    public init(path: PathType) {
        self.init(path) { _, _ in }
    }

    // swiftlint:disable identifier_name

    /// Instantiate this validator with a Path and validation function. This initialiser
    /// sets up the validator to perform some validation function on a specified value.
    /// - Parameters:
    ///   - path: The path pointing to the location of the value to validate.
    ///   - _validate: The function used to validate the value.
    internal init(_ path: PathType, _validate: @escaping (Root, Value) throws -> Void) {
        self.path = path
        self._validate = _validate
    }

    // swiftlint:enable identifier_name

    /// Perform a validation on a root type containing the value located at path. This
    /// function checks the presence of a nil value and returns early in that case.
    /// Nil values are considered to be automatically validated.
    /// - Parameter root: The root object containing the value to validate.
    public func performValidation(_ root: PathType.Root) throws {
        let value = root[keyPath: self.path.keyPath]
        guard !value.isNil else {
            return
        }
        _ = try self._validate(root, value.wrappedValue)
    }

    /// Create a new validator that performs an additional validation function in conjunction
    /// with the validation function stored in self.
    /// - Parameter f: The additional validation function.
    /// - Returns: A new validator that performs the validation function in self and the validation
    ///            function given in the parameters of this function call.
    public func push(_ f: @escaping (Root, Value) throws -> Void) -> OptionalValidator<P> {
        OptionalValidator(self.path) {
            try self._validate($0, $1)
            try f($0, $1)
        }
    }

    /// Create a type-erased version of this validator.
    /// - Parameter builder: The builder used to create the type-erased version.
    /// - Returns: A type-erased version of self.
    public func validate(
        @ValidatorBuilder<PathType.Root> builder: (Self) -> [AnyValidator<PathType.Root>]
    ) -> AnyValidator<PathType.Root> {
        AnyValidator(builder(self))
    }

}
