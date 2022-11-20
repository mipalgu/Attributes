/*
 * PathValidator.swift
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

/// Provides properties to allow for default implementations of `push` method.
internal protocol _Push {

    /// The type of the path used to reference a value that needs validation.
    associatedtype PathType: ReadOnlyPathProtocol

    /// The path to the value that needs validation.
    var path: PathType { get }

    // swiftlint:disable identifier_name

    /// A validate function that performs a validation on a value existing within a root object.
    var _validate: (PathType.Root, PathType.Value) throws -> Void { get }

    /// Instantiate the properties inside this protocol.
    /// - Parameters:
    ///   - path: The path to the value requiring validation.
    ///   - _validate: The validation method that performs the validation.
    init(_ path: PathType, _validate: @escaping (PathType.Root, PathType.Value) throws -> Void)

    // swiftlint:enable identifier_name

}

/// Default implementation of `push` method.
extension _Push {

    /// Create a new instance of ``_Push`` that contains the validation functions within `Self` and an
    /// additional validation function provided by the `f` parameter.
    /// - Parameter f: The extra validation function to perform.
    /// - Returns: A new instance of `Self` that uses the existing validation functions and the new
    /// validation function `f`.
    public func push(_ f: @escaping (PathType.Root, PathType.Value) throws -> Void) -> Self {
        Self(self.path) {
            try self._validate($0, $1)
            try f($0, $1)
        }
    }

}

/// Provides default implementations for ``PathValidator``.
internal typealias _PathValidator = _Push & PathValidator

/// Provides the means to perform validations using ``ReadOnlyPathProtocol``s. This protocol
/// allows the dynamic allocation of validation functions to members existing within a root
/// object by using a key path.
public protocol PathValidator: ValidatorProtocol, ValidationPushProtocol {

    /// The type of the path pointing to the value to be validated.
    associatedtype PathType: ReadOnlyPathProtocol

    /// The `PushValidator` existing within ``ValidationPushProtocol`` is `Self`.
    associatedtype PushValidator = Self

    /// The path to the value that needs to be validated.
    var path: PathType { get }

    /// Instantiate this validator from the path of the value that requires validation.
    /// - Parameter path: The path to the value that is to be validated.
    init(path: PathType)

    /// Push an additional validation function onto the stack of existing validation functions. This
    /// function acts as a pure function creating a new instance of `Self` with the new validation stack.
    /// - Parameter f: The validation function to perform in addition to the existing validation functions.
    /// - Returns: A new instance of `Self` that performs the validation functions contained within `self`
    /// and the new validation function `f`.
    func push(_ f: @escaping (Root, Value) throws -> Void) -> Self

}
