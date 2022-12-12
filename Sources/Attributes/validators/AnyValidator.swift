/*
 * AnyValidator.swift
 * Attributes
 *
 * Created by Callum McColl on 6/11/20.
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

/// A type-erased validator.
public struct AnyValidator<Root>: ValidatorProtocol {

    /// The validate function that is performed by this validator.
    private let _validate: (Root) throws -> Void

    /// Initialise this validator with a validate function.
    /// - Parameter validate: The function to use when validating a value.
    public init(validate: @escaping (Root) throws -> Void) {
        self._validate = validate
    }

    /// Initialise this validator with another validator. This validator will act
    /// in the same way as the given validator but as a type-erased version.
    /// - Parameter validator: A validator to use with this validator.
    public init<V: ValidatorProtocol>(_ validator: V) where V.Root == Root {
        self._validate = { try validator.performValidation($0) }
    }

    /// Initialise this validator with another AnyValidator. This is equivalent to a copy
    /// constructor.
    /// - Parameter validator: The equivalent validator to self.
    @inlinable
    public init(_ validator: AnyValidator<Root>) {
        self = validator
    }

    /// Initialise this validator with a builder. This initialiser will use the output from
    /// the builder to initialise self.
    /// - Parameter builder: The function used to construct an array of AnyValidators.
    public init(@ValidatorBuilder<Root> builder: () -> [AnyValidator<Root>]) {
        self.init(builder())
    }

    /// Initialise this validator from an array of AnyValidator's. This validator will use
    /// each validators performValidation function when validating values.
    /// - Parameter validators: An array of AnyValidators to initialise from.
    public init<S: Sequence>(_ validators: S) where S.Element == AnyValidator<Root> {
        self._validate = { root in try validators.forEach { try $0.performValidation(root) } }
    }

    /// Initialise this AnyValidator from an array of generic Validators. This init is similar to the
    /// AnyValidator Sequence init, except it uses typed versions of a Validator.
    /// - Parameter validators: The validators to use by this validator.
    public init<S: Sequence, V: ValidatorProtocol>(_ validators: S) where S.Element == V, V.Root == Root {
        self._validate = { root in try validators.forEach { try $0.performValidation(root) } }
    }

    /// Perform a validation of a root value. This function uses the underlying validation rules specified
    /// in the initialiser.
    /// - Parameter root: The value to validate.
    /// - Throws: Throws an Error when the validation is unsusccessful.
    public func performValidation(_ root: Root) throws {
        try self._validate(root)
    }

    /// Changes the Root of the validate function to allow for different parameters to be passed to
    /// performValidation. This method acts as a pure function returning a new AnyValidator with the
    /// new Root.
    /// - Parameter path: A path pointing from the new Root to the Root of this AnyValidator.
    /// - Returns: A new validator with a validate method that enacts the same validation rules but
    ///            uses a new Root.
    @inlinable
    public func toNewRoot<NewPath: ReadOnlyPathProtocol>(path: NewPath)
        -> AnyValidator<NewPath.Root> where NewPath.Value == Root {
        AnyValidator<NewPath.Root> {
            try performValidation($0[keyPath: path.keyPath])
        }
    }

}

/// ExpressibleByArrayLiteral conformance.
extension AnyValidator: ExpressibleByArrayLiteral {

    /// The elements of the array will be AnyValidators.
    public typealias ArrayLiteralElement = AnyValidator<Root>

    /// Initialise this AnyValidator from a variadic parameter list of other AnyValidator's.
    /// - Parameter validators: The validators to use in this validator.
    public init(arrayLiteral validators: ArrayLiteralElement...) {
        self._validate = { root in try validators.forEach { try $0.performValidation(root) } }
    }

}
