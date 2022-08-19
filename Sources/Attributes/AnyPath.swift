/*
 * AnyPath.swift
 * Attributes
 *
 * Created by Callum McColl on 5/11/20.
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

/// A Path that points to a type-erased quantity within some Root type.
public struct AnyPath<Root> {

    /// Other paths that contain this root.
    public let ancestors: [AnyPath<Root>]

    /// A partialKeyPath equivalent type of this AnyPath.
    public let partialKeyPath: PartialKeyPath<Root>

    /// Whether this path points to an optional value.
    public let isOptional: Bool

    /// The type of the value pointed to by this AnyPath.
    public let targetType: Any.Type

    // swiftlint:disable identifier_name

    /// A function for retrieving the value pointed to by this AnyPath.
    let _value: (Root) -> Any

    /// A function for discerning whether the value pointed to by this AnyPath
    /// is nil.
    let _isNil: (Root) -> Bool

    /// A function for discerning whether a PartialKeyPath points to the same value
    /// as this AnyPath.
    let _isSame: (PartialKeyPath<Root>) -> Bool

    // swiftlint:enable identifier_name

    /// Initialise object from a PartialKeyPath.
    /// - Parameters:
    ///   - path: The path to initialise this AnyPath from.
    ///   - ancestors: The ancestors of this path.
    ///   - targetType: The type pointed to by this path.
    ///   - isOptional: Whether the value pointed to by this path is optional.
    ///   - isNil: A function that determins whether an object containing the value pointed
    ///            to by this path contains a nil value at this paths location.
    ///   - isSame: A function for determining whether a PartialKeyPath is the same as this
    ///             AnyPath.
    private init(
        _ path: PartialKeyPath<Root>,
        ancestors: [AnyPath<Root>],
        targetType: Any.Type,
        isOptional: Bool,
        isNil: @escaping (Root) -> Bool,
        isSame: @escaping (PartialKeyPath<Root>) -> Bool
    ) {
        self.ancestors = ancestors
        self.partialKeyPath = path
        self.targetType = targetType
        self._value = { $0[keyPath: path] as Any }
        self.isOptional = isOptional || (ancestors.last?.isOptional ?? false)
        self._isNil = { root in ancestors.last?.isNil(root) ?? false || isNil(root) }
        self._isSame = isSame
    }

    /// Initialise this AnyPath from a ReadOnlyPathProtocol instance.
    /// - Parameters:
    ///   - path: The path to convert to an AnyPath.
    ///   - isOptional: Wether the value pointed to by this path is optional.
    ///   - isNil: A function used to determine if the value pointed to by this path is nil.
    ///   - isSame: A function used to determine whether a PartialKeyPath is equivalent to
    ///             this AnyPath.
    private init<P: ReadOnlyPathProtocol>(
        _ path: P,
        isOptional: Bool,
        isNil: @escaping (Root) -> Bool,
        isSame: @escaping (PartialKeyPath<Root>) -> Bool
    ) where P.Root == Root {
        self.init(
            path.keyPath,
            ancestors: path.ancestors,
            targetType: P.Value.self,
            isOptional: isOptional,
            isNil: isNil,
            isSame: isSame
        )
    }

    /// Initialise this AnyPath from a ReadOnlyPath where the value pointed to by the path cannot be
    /// optional.
    /// - Parameter path: The path to convert to an AnyPath.
    public init<P: ReadOnlyPathProtocol>(_ path: P) where P.Root == Root {
        self.init(path, isOptional: false, isNil: { path.isNil($0) }, isSame: { $0 == path.keyPath })
    }

    /// Initialise this AnyPath from a value that is optional.
    /// - Parameter path: The path to a value that may be nil.
    public init<P: ReadOnlyPathProtocol>(optional path: P) where P.Root == Root, P.Value: Nilable {
        self.init(
            path,
            isOptional: true,
            isNil: { path.isNil($0) },
            isSame: { $0 == path.keyPath || $0 == path.keyPath.appending(path: \.wrappedValue) }
        )
    }

    /// Evaluated whether this AnyPath is a member of another AnyPath's ancestors.
    /// - Parameter path: The path to check.
    /// - Returns: Whether path is a child of self.
    public func isParent(of path: AnyPath<Root>) -> Bool {
        path.isChild(of: self)
    }

    /// Evaluated whether this AnyPath is a member of another ReadOnlyPathProtocol's ancestors.
    /// - Parameter path: The path to check.
    /// - Returns: Whether path is a child of self.
    public func isParent<Path: ReadOnlyPathProtocol>(of path: Path) -> Bool where Path.Root == Root {
        self.isParent(of: AnyPath(path))
    }

    /// Evaluated whether this AnyPath contains another AnyPath as an ancestor.
    /// - Parameter path: The path to check.
    /// - Returns: Whether path is an ancestor of self.
    public func isChild(of path: AnyPath<Root>) -> Bool {
        self.isChild(of: path.partialKeyPath)
    }

    /// Evaluated whether this AnyPath contains another PartialKeyPath as an ancestor.
    /// - Parameter path: The path to check.
    /// - Returns: Whether path is an ancestor of self.
    public func isChild(of path: PartialKeyPath<Root>) -> Bool {
        nil != self.ancestors.first { $0.isSame(as: path) }
    }

    /// Evaluated whether this AnyPath contains another ReadOnlyPathProtocol as an ancestor.
    /// - Parameter path: The path to check.
    /// - Returns: Whether path is an ancestor of self.
    public func isChild<Path: ReadOnlyPathProtocol>(of path: Path) -> Bool where Path.Root == Root {
        self.isChild(of: path.keyPath)
    }

    /// Checks whether the value in root is nil.
    /// - Parameter root: The object to check.
    /// - Returns: Whether the object contained in root that this path points to is nil.
    public func hasValue(_ root: Root) -> Bool {
        !isOptional || !isNil(root)
    }

    /// Use self to retrieve the value it points to in a root object.
    /// - Parameter root: The root object to retrieve from.
    /// - Returns: The fetched value as a type-erased quantity.
    public func value(_ root: Root) -> Any {
        self._value(root)
    }

    /// Check whether the value pointed to by this path is nil in a given object.
    /// - Parameter root: The object that contains the value.
    /// - Returns: Whether the value is nil in root.
    public func isNil(_ root: Root) -> Bool {
        self._isNil(root)
    }

    /// Check if an AnyPath with the same Root points to the same member as this AnyPath.
    /// - Parameter path: The path to compare against.
    /// - Returns: Whether path points to the same member as self.
    public func isSame(as path: AnyPath<Root>) -> Bool {
        self._isSame(path.partialKeyPath)
    }

    /// Check if a PartialKeyPath with the same Root points to the same member as this AnyPath.
    /// - Parameter path: The path to compare against.
    /// - Returns: Whether path points to the same member as self.
    public func isSame(as path: PartialKeyPath<Root>) -> Bool {
        self._isSame(path)
    }

    /// Check if a ReadOnlyPathProtocol with the same Root points to the same member as this AnyPath.
    /// - Parameter path: The path to compare against.
    /// - Returns: Whether path points to the same member as self.
    public func isSame<Path: ReadOnlyPathProtocol>(as path: Path) -> Bool where Path.Root == Root {
        self._isSame(path.keyPath)
    }

    /// Changes the root of this AnyPath to a suitable ancestor.
    /// - Parameter path: A path where the value is equal to the Root of this AnyPath.
    /// - Returns: A new AnyPath from the root of path to the value of this AnyPath.
    public func changeRoot<Prefix: ReadOnlyPathProtocol>(path: Prefix)
        -> AnyPath<Prefix.Root> where Prefix.Value == Root {
        guard let newPath = (path.keyPath as PartialKeyPath<Prefix.Root>).appending(
            path: partialKeyPath as AnyKeyPath
        ) else {
            fatalError("Failed to create new path")
        }
        return AnyPath<Prefix.Root>(
            newPath,
            ancestors: path.ancestors + self.ancestors.map { $0.changeRoot(path: path) },
            targetType: targetType,
            isOptional: isOptional,
            isNil: { root in
                path.ancestors.last?.isNil(root) ?? false || _isNil(root[keyPath: path.keyPath])
            },
            isSame: { path in path == newPath }
        )
    }

    /// Appends a path to this path creating a new AnyPath. This method acts as a pure function creating
    /// a new AnyPath in the process.
    /// - Parameter path: The path to append to self.
    /// - Returns: A new AnyPath with the path appended or nil if the operation was unsuccessful.
    public func appending<Value>(_ path: AnyPath<Value>) -> AnyPath<Root>? {
        guard
            let keyPath = self.partialKeyPath as? KeyPath<Root, Value>,
            let newPartialKeyPath = self.partialKeyPath.appending(path: path.partialKeyPath)
        else {
            return nil
        }
        let ancestors = self.ancestors + path.ancestors.map {
            $0.changeRoot(path: ReadOnlyPath(keyPath: keyPath, ancestors: self.ancestors))
        }
        return AnyPath(
            newPartialKeyPath,
            ancestors: ancestors,
            targetType: Any.self,
            isOptional: path.isOptional,
            isNil: { path.isNil($0[keyPath: keyPath]) },
            isSame: { $0 == newPartialKeyPath }
        )
    }

}

/// Equatable conformance.
extension AnyPath: Equatable {

    /// Equality operation. Delegates to PartialKeyPath equality conformance.
    /// - Parameters:
    ///   - lhs: The AnyPath on the left-hand side of the == operator.
    ///   - rhs: The AnyPath on the right-hand side of the == operator.
    /// - Returns: Whether lhs is equal to rhs using value equality.
    public static func == <Root>(lhs: AnyPath<Root>, rhs: AnyPath<Root>) -> Bool {
        lhs.partialKeyPath == rhs.partialKeyPath
    }

}

/// Hashable conformance.
extension AnyPath: Hashable {

    /// Define which members are used in the hashing function.
    /// - Parameter hasher: The hasher to perform the hashing function.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ancestors)
        hasher.combine(self.partialKeyPath)
    }

}

/// CustomStringConvertible conformance.
extension AnyPath: CustomStringConvertible {

    /// A string describing the instance of AnyPath.
    public var description: String {
        (self.ancestors.map { String(describing: $0.partialKeyPath) } +
            [String(describing: self.partialKeyPath)]).joined(separator: " -> ")
    }

}
