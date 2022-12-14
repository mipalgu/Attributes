// CollectionSearchPath.swift 
// Attributes 
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

/// A ``ConvertibleSearchablePath`` for referencing objects within a `Collection`. This path
/// stores a root path to the collection and an element path from the Collection element to
/// the value. The `CollectionSearchPath` can recursively use both of these paths to generate
/// valid key paths inside a root objects collection.
public struct CollectionSearchPath<Root, Collection, Value>: ConvertibleSearchablePath where
    Collection: MutableCollection, Collection.Index: BinaryInteger {

    /// The root object containing the collection.
    public typealias Root = Root

    /// The value of interest inside the elements of the collection.
    public typealias Value = Value

    /// A path pointing to the collection within a root object. This collection will store the
    /// elements that correspond to the root of `elementPath`.
    @usableFromInline var collectionPath: Path<Root, Collection>

    /// A path from the collection element to a value of interest.
    @usableFromInline var elementPath: Path<Collection.Element, Value>

    /// Initialise this `CollectionSearchPath` with a path from a root object to the collection and
    /// a path from the collections element to some value.
    /// - Parameters:
    ///   - collectionPath: A path pointing to the collection within a root object. This collection will
    /// store the elements that correspond to the root of `elementPath`.
    ///   - elementPath: A path from the collection element to a value of interest.
    @inlinable
    public init(collectionPath: Path<Root, Collection>, elementPath: Path<Collection.Element, Value>) {
        self.collectionPath = collectionPath
        self.elementPath = elementPath
    }

    /// Convenience initialiser when the value of interest is the elements of the collection itself.
    /// This initialiser will create an element path to `Element.self` and use this path with respect
    /// to the collection elements.
    /// - Parameter collectionPath: A path to the collection contained within the `Root` object. This
    /// collection must contain elements of type `Element`.
    public init(_ collectionPath: Path<Root, Collection>) where Collection.Element == Value {
        self.init(collectionPath: collectionPath, elementPath: Path(path: \.self, ancestors: []))
    }

    /// Check whether self is an ancestor or the same as a given path.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - root: The root object to act upon.
    /// - Returns: True if `self` is an ancestor of `path` inside the root object.
    @inlinable
    public func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool {
        root[keyPath: collectionPath.keyPath].indices.contains {
            let newElementPath = elementPath.changeRoot(path: collectionPath[$0])
            return newElementPath.isAncestorOrSame(of: path, in: root)
        }
    }

    /// Retrieve all paths within a root object that satisfy this `CollectionSearchPath`.
    /// - Parameter root: The root object containing the collection.
    /// - Returns: All paths within the root object that this `CollectionSearchPath` references. These paths
    /// will represent the values within the elements contained within the collection.
    @inlinable
    public func paths(in root: Root) -> [Path<Root, Value>] {
        root[keyPath: collectionPath.keyPath].indices.flatMap { index -> [Path<Root, Value>] in
            let newElementPath = elementPath.toNewRoot(path: collectionPath[index])
            return newElementPath.paths(in: root)
        }
    }

    /// Append a path to the end of `self`.
    /// - Parameter path: The path to append to self. The root of this path must be the `Value` pointed to
    /// by this `CollectionSearchPath`.
    /// - Returns: A new `CollectionSearchPath` pointing from `Root` to the new paths `Value`.
    @inlinable
    public func appending<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value {
        let newElementPath = path.changeRoot(path: elementPath)
        return AnySearchablePath(
            CollectionSearchPath<Root, Collection, Path.Value>(
                collectionPath: self.collectionPath, elementPath: newElementPath
            )
        )
    }

    /// Change the root of this path to a new value.
    /// - Parameter path: The path to prepend to the start of this `CollectionSearchPath`.
    /// - Returns: A new `CollectionSearchPath` pointing from the given paths `Root` to `Value`.
    @inlinable
    public func toNewRoot<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root {
        let newCollectionPath = collectionPath.changeRoot(path: path)
        return AnySearchablePath(
            CollectionSearchPath<Path.Root, Collection, Value>(
                collectionPath: newCollectionPath, elementPath: elementPath
            )
        )
    }

}
