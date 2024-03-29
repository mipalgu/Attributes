/*
 * ValidationPath.swift
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

/// Path to a value containing validation rules.
@dynamicMemberLookup
public struct ValidationPath<P: ReadOnlyPathProtocol>: _ValidationPath {

    /// PathType is a ReadOnlyPathProtocol instance.
    public typealias PathType = P

    /// The underlying path used in this object.
    public let path: PathType

    // swiftlint:disable identifier_name

    /// A validate method used to valid a given object and value.
    @usableFromInline internal let _validate: (PathType.Root, PathType.Value) throws -> Void

    // swiftlint:enable identifier_name

    /// Initialise this object from a path. The validation function in this
    /// initialiser always passes.
    /// - Parameter path: The path to the value being validated.
    @inlinable
    public init(path: PathType) {
        self.init(path) { _, _ in }
    }

    // swiftlint:disable identifier_name

    /// Initialise this object from a path and validation function.
    /// - Parameters:
    ///   - path: The path pointing to the value to validate.
    ///   - _validate: A validation function used to validate the value.
    @inlinable
    internal init(_ path: PathType, _validate: @escaping (PathType.Root, PathType.Value) throws -> Void) {
        self.path = path
        self._validate = _validate
    }

    // swiftlint:enable identifier_name

    /// Create a validator that validates the value pointed to by path.
    /// - Parameter builder: The builder used to construct the validator.
    /// - Returns: A type-erased validator.
    @inlinable
    public func validate(
        @ValidatorBuilder<PathType.Root> builder: (Self) -> AnyValidator<PathType.Root>
    ) -> AnyValidator<PathType.Root> {
        builder(self)
    }

    /// Append a path to this ValidationPath.
    /// - Parameter dynamicMember: The path to append to this path.
    /// - Returns: A new ValidationPath with dynamicMember appended.
    public subscript<AppendedValue>(
        dynamicMember member: KeyPath<P.Value, AppendedValue>
    ) -> ValidationPath<ReadOnlyPath<P.Root, AppendedValue>> {
        ValidationPath<ReadOnlyPath<P.Root, AppendedValue>>(
            path: ReadOnlyPath<Root, AppendedValue>(
                keyPath: path.keyPath.appending(path: member), ancestors: path.fullPath
            )
        )
    }

    /// Append a path to this ValidationPath.
    /// - Parameter dynamicMember: The path to append to this path.
    /// - Returns: A new ValidationPath with dynamicMember appended.
    public subscript<AppendedValue>(
        dynamicMember member: KeyPath<P.Value, AppendedValue>
    ) -> ValidationPath<ReadOnlyPath<P.Root, AppendedValue>> where AppendedValue: Nilable {
        ValidationPath<ReadOnlyPath<P.Root, AppendedValue>>(
            path: ReadOnlyPath<Root, AppendedValue>(
                keyPath: path.keyPath.appending(path: member), ancestors: path.fullPath
            )
        )
    }

}

/// Extra methods when Value conforms to Nilable.
extension ValidationPath where Value: Nilable {

    /// Create a required validator for the value.
    /// - Returns: The required validator.
    @inlinable
    public func required() -> RequiredValidator<P> {
        RequiredValidator(path: self.path)
    }

    /// Create an OptionalValidator for the value.
    /// - Returns: The OptionalValidator.
    @inlinable
    public func optional() -> OptionalValidator<P> {
        OptionalValidator(path: self.path)
    }

}
