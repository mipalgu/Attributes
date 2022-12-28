/*
 * Validator.swift
 * Machines
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

/// Container for storing validation functions for values specified with a Path.
public struct Validator<P: ReadOnlyPathProtocol>: _PathValidator {

    /// PathType is an instance of ReadOnlyPathProtocol.
    public typealias PathType = P

    /// The path to the value this validator acts on.
    public let path: PathType

    // swiftlint:disable identifier_name

    /// The function that performs the validation.
    @usableFromInline internal let _validate: (PathType.Root, PathType.Value) throws -> Void

    // swiftlint:enable identifier_name

    /// Initialise this object from a Path. The validation function does nothing in this
    /// initialiser.
    /// - Parameter path: The path to the value that is validated by this validator.
    @inlinable
    public init(path: PathType) {
        self.init(path) { _, _ in }
    }

    // swiftlint:disable identifier_name

    /// Initialise this object with an additional validation function.
    /// - Parameters:
    ///   - path: The path to the value that this Validator validates.
    ///   - _validate: The validation function which performs that validation on the value pointed to
    ///                by path.
    @inlinable
    internal init(_ path: PathType, _validate: @escaping (PathType.Root, PathType.Value) throws -> Void) {
        self.path = path
        self._validate = _validate
    }

    // swiftlint:enable identifier_name

    /// Perform the validation of a value contained within a Root object.
    /// - Parameter root: The root object containing the value pointed to by path. This
    ///                   function validates the value using an internal validation function.
    @inlinable
    public func performValidation(_ root: PathType.Root) throws {
        guard !path.isNil(root) else {
            throw ValidationError(message: "Path is nil!", path: path)
        }
        _ = try self._validate(root, root[keyPath: self.path.keyPath])
    }

    /// Creates a type-erased version of this Validator by using a builder function.
    /// - Parameter builder: The function which creates the validation rules from this validator.
    /// - Returns: A type-erased validator which performs the same validation as this validator.
    @inlinable
    public func validate(
        @ValidatorBuilder<PathType.Root> builder: (Self) -> [AnyValidator<PathType.Root>]
    ) -> AnyValidator<PathType.Root> {
        AnyValidator(builder(self))
    }

}
