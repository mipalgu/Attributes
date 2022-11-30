/*
 * Path.swift
 * Attributes
 *
 * Created by Callum McColl on 4/11/20.
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

/// Path that points to values that can be read and written to.
@dynamicMemberLookup
public struct Path<Root, Value>: PathProtocol {

    /// The ancestors of this path. These paths contain properties that contains this paths value.
    public var ancestors: [AnyPath<Root>]

    /// A WriteableKeyPath equivalent type of this Path.
    public var path: WritableKeyPath<Root, Value>

    /// A function for discerning whether the path points to a value that is nil in
    /// a given Root object.
    private let _isNil: (Root) -> Bool

    /// Create a read-only equivalent path.
    public var readOnly: ReadOnlyPath<Root, Value> {
        ReadOnlyPath(keyPath: self.path as KeyPath<Root, Value>, ancestors: self.ancestors)
    }

    /// Initialise this object with a WriteableKeyPath and a custom function that checks for nil values
    /// pointed to by the given key path.
    /// - Parameters:
    ///   - path: The WriteableKeyPath pointing to the value this path points to.
    ///   - ancestors: The ancestors of this path.
    ///   - isNil: A function that checks for the presence of nil values in an object.
    init(path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>], isNil: @escaping (Root) -> Bool) {
        self.path = path
        self.ancestors = ancestors.reversed().drop { $0.partialKeyPath == path }.reversed()
        self._isNil = { root in ancestors.last?.isNil(root) ?? false || isNil(root) }
    }

    /// Initialise this object with a path that points to a non-optional value.
    /// - Parameters:
    ///   - path: The path this object is initialised from.
    ///   - ancestors: The ancestors of path.
    init(path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>]) {
        self.init(path: path, ancestors: ancestors) { _ in false }
    }

    /// Initialise this object from a path that points to an optional value.
    /// - Parameters:
    ///   - path: The path this object is initialised from.
    ///   - ancestors: The ancestors of path.
    init(
        path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>]
    ) where Value: Nilable {
        self.init(path: path, ancestors: ancestors) { root in root[keyPath: path].isNil }
    }

    /// Initialise self from the type of Value. This initialiser sets value as the Root and
    /// the destination of the key path. This path is basically equivalent to \Value.self.
    /// - Parameter type: The type that this path points to.
    public init(_ type: Value.Type) where Root == Value {
        self.init(path: \.self, ancestors: [])
    }

    /// Append a path to this Path.
    /// - Parameter path: The path to append to self.
    /// - Returns: A new path pointing from Root to the given paths values.
    public func appending<NewValue>(path: Path<Value, NewValue>) -> Path<Root, NewValue> {
        path.changeRoot(path: self)
    }

    /// Change the Root of this path. This function is equivalent to prepending a path to self.
    /// This method acts as a pure function by creating a new path with the result.
    /// - Parameter path: The path to prepend to self.
    /// - Returns: A new path pointing from the path Root to self's Value.
    public func changeRoot<Prefix: PathProtocol>(
        path: Prefix
    ) -> Path<Prefix.Root, Value> where Prefix.Value == Root {
        let ancestors = path.fullPath + self.ancestors.dropFirst().map {
            $0.changeRoot(path: path.readOnly)
        }
        return Path<Prefix.Root, Value>(path: path.path.appending(path: self.path), ancestors: ancestors)
    }

    /// Checks whether the value pointed to by this path is nil in a given object.
    /// - Parameter root: The object containing the value pointed to be this Path.
    /// - Returns: Whether the value is nil in root.
    public func isNil(_ root: Root) -> Bool {
        self._isNil(root)
    }

    /// Append to this path with a keyPath. This operation acts as a pure function by returning a new
    /// Path with the keyPath appended.
    /// - Parameter dynamicMember: The keyPath to append to this path.
    /// - Returns: A new path with the keyPath appended to self.
    public subscript<AppendedValue>(
        dynamicMember member: KeyPath<Value, AppendedValue>
    ) -> ReadOnlyPath<Root, AppendedValue> {
        ReadOnlyPath<Root, AppendedValue>(keyPath: path.appending(path: member), ancestors: fullPath)
    }

    /// Append to this path with a keyPath. This operation acts as a pure function by returning a new
    /// Path with the keyPath appended.
    /// - Parameter dynamicMember: The keyPath to append to this path.
    /// - Returns: A new path with the keyPath appended to self.
    public subscript<AppendedValue>(
        dynamicMember member: KeyPath<Value, AppendedValue>
    ) -> ReadOnlyPath<Root, AppendedValue> where AppendedValue: Nilable {
        let newPath = path.appending(path: member)
        return ReadOnlyPath<Root, AppendedValue>(keyPath: newPath, ancestors: fullPath) {
            $0[keyPath: newPath].isNil
        }
    }

    /// Append a WriteableKeyPath to self. This function creates a new Path pointing from self's Root to
    /// the new Path's value.
    /// - Parameter dynamicMember: The WriteableKeyPath to be appended to self.
    /// - Returns: A new Path with dynamicMember appended to self.
    public subscript<AppendedValue>(
        dynamicMember member: WritableKeyPath<Value, AppendedValue>
    ) -> Path<Root, AppendedValue> {
        Path<Root, AppendedValue>(path: path.appending(path: member), ancestors: fullPath)
    }

    /// Append a WriteableKeyPath to self. This function creates a new Path pointing from self's Root to
    /// the new Path's value.
    /// - Parameter dynamicMember: The WriteableKeyPath to be appended to self.
    /// - Returns: A new Path with dynamicMember appended to self.
    public subscript<AppendedValue>(
        dynamicMember member: WritableKeyPath<Value, AppendedValue>
    ) -> Path<Root, AppendedValue> where AppendedValue: Nilable {
        let newPath = path.appending(path: member)
        return Path<Root, AppendedValue>(path: newPath, ancestors: fullPath) {
            $0[keyPath: newPath].isNil
        }
    }

}

/// Equatable and Hashable conformance.
extension Path {

    /// Perform and equality operation by using value-equality. This function compares the ancestors
    /// and keyPaths of the Path objects.
    /// - Parameters:
    ///   - lhs: The Path on the left-hand side of the == operator.
    ///   - rhs: The Path on the right-hand side of the == operator.
    /// - Returns: Whether lhs is equal to rhs.
    public static func == (lhs: Path<Root, Value>, rhs: Path<Root, Value>) -> Bool {
        lhs.ancestors == rhs.ancestors && lhs.keyPath == rhs.keyPath
    }

    /// Define the members included in the hashing function for this type.
    /// - Parameter hasher: The hasher that performs the hashing function.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ancestors)
        hasher.combine(self.keyPath)
    }

}

/// Add validate function to Path.
extension Path {

    /// Creates a type-erased validator that performs a validation on the value pointed to by
    /// this path.
    /// - Parameter builder: A function that creates the type-erased validator.
    /// - Returns: A type-erased validator which performs a validation function on a value pointed
    ///            to by self.
    public func validate(
        @ValidatorBuilder<Root> builder: (
            ValidationPath<Path<Root, Value>>
        ) -> AnyValidator<Root>
    ) -> AnyValidator<Root> {
        builder(ValidationPath(path: Path(path: self.path, ancestors: self.fullPath)))
    }

}

/// Add trigger function to Path.
extension Path {

    /// Creates a trigger that is enacted when self is changed.
    /// - Parameter builder: A function that creates the trigger.
    /// - Returns: A type-erased trigger that performs an action when the value
    ///            pointed to by self is changed.
    public func trigger(
        @TriggerBuilder<Root> builder: (
            WhenChanged<Path<Root, Value>, IdentityTrigger<Root>>
        ) -> [AnyTrigger<Root>]
    ) -> AnyTrigger<Root> {
        AnyTrigger(builder(WhenChanged(Path(path: self.path, ancestors: self.fullPath))))
    }

}
