/*
 * SearchPath.swift
 * Attributes
 *
 * Created by Callum McColl on 24/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

public protocol SearchablePath {
    
    associatedtype Root
    associatedtype Value

    func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool
    
    func paths(in root: Root) -> [Path<Root, Value>]
    
}

public protocol ConvertibleSearchablePath: SearchablePath {
    
    associatedtype Value
    
    func appending<Path: PathProtocol>(path: Path) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value
    
    func toNewRoot<Path: PathProtocol>(path: Path) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root
    
}

extension Path: ConvertibleSearchablePath {
    
    public func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool {
        let anyPath = AnyPath(self)
        return anyPath.isSame(as: path) || anyPath.isParent(of: path)
    }
    
    public func paths(in root: Root) -> [Path<Root, Value>] {
        return [self]
    }
    
    public func appending<Path: PathProtocol>(path: Path) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value {
        let ancestors = self.ancestors + path.ancestors.map { $0.changeRoot(path: self) }
        return AnySearchablePath(Attributes.Path<Root, Path.Value>(path: self.path.appending(path: path.path), ancestors: ancestors))
    }
    
    public func toNewRoot<Path: PathProtocol>(path: Path) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root {
        let ancestors = self.ancestors.map {
            $0.changeRoot(path: path)
        }
        return AnySearchablePath(Attributes.Path<Path.Root, Value>(path: path.path.appending(path: self.path), ancestors: ancestors))
    }
    
}

public struct CollectionSearchPath<Root, Collection, Value>: ConvertibleSearchablePath where Collection: MutableCollection, Collection.Index: BinaryInteger {
    
    public typealias Root = Root
    public typealias Value = Value
    
    var collectionPath: Path<Root, Collection>
    
    var elementPath: Path<Collection.Element, Value>
    
    public init(collectionPath: Path<Root, Collection>, elementPath: Path<Collection.Element, Value>) {
        self.collectionPath = collectionPath
        self.elementPath = elementPath
    }
    
    public init(_ collectionPath: Path<Root, Collection>) where Collection.Element == Value {
        self.init(collectionPath: collectionPath, elementPath: Path(path: \.self, ancestors: []))
    }
    
    public func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool {
        nil != root[keyPath: collectionPath.keyPath].indices.first {
            let newElementPath = elementPath.changeRoot(path: collectionPath[$0])
            return newElementPath.isAncestorOrSame(of: path, in: root)
        }
    }
    public func paths(in root: Root) -> [Path<Root, Value>] {
        return root[keyPath: collectionPath.keyPath].indices.flatMap { (index) -> [Path<Root, Value>] in
            let newElementPath = elementPath.toNewRoot(path: collectionPath[index])
            return newElementPath.paths(in: root)
        }
    }
    
    public func appending<Path: PathProtocol>(path: Path) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value {
        let newElementPath = path.changeRoot(path: elementPath)
        return AnySearchablePath(CollectionSearchPath<Root, Collection, Path.Value>(collectionPath: self.collectionPath, elementPath: newElementPath))
    }
    
    public func toNewRoot<Path: PathProtocol>(path: Path) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root {
        let newCollectionPath = collectionPath.changeRoot(path: path)
        return AnySearchablePath(CollectionSearchPath<Path.Root, Collection, Value>(collectionPath: newCollectionPath, elementPath: elementPath))
    }
    
}

public struct AnySearchablePath<Root, Value>: SearchablePath {
    
    private let _isAncestorOrSame: (AnyPath<Root>, Root) -> Bool
    private let _paths: (Root) -> [Path<Root, Value>]
    
    public init<Base: SearchablePath>(_ base: Base) where Base.Root == Root, Base.Value == Value {
        self._isAncestorOrSame = { base.isAncestorOrSame(of: $0, in: $1) }
        self._paths = { base.paths(in: $0) }
    }
    
    public func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool {
        self._isAncestorOrSame(path, root)
    }
    
    public func paths(in root: Root) -> [Path<Root, Value>] {
        self._paths(root)
    }
    
    
}
