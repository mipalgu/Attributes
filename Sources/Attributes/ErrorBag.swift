/*
 * ErrorBag.swift
 * Machines
 *
 * Created by Callum McColl on 14/11/20.
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

import Foundation
import swift_helpers

public struct ErrorBag<Root> {
    
    private var sortedCollection = SortedCollection(compare: { (lhs: AttributeError<Root>, rhs: AttributeError<Root>) -> ComparisonResult in
        if lhs.path.isSame(as: rhs.path) {
            return .orderedSame
        }
        if lhs.path.isParent(of: rhs.path) {
            return .orderedAscending
        }
        return .orderedDescending
    })
    
    public var allErrors: [AttributeError<Root>] {
        return Array(sortedCollection)
    }
    
    public init() {}
    
    public mutating func empty() {
        self.sortedCollection.empty()
    }
    
    public func errors(includingDescendantsForPath path: AnyPath<Root>) -> [AttributeError<Root>] {
        return Array(sortedCollection[index(includingDescendantsForPath: path)])
    }
    
    public func errors<Path: ReadOnlyPathProtocol>(includingDescendantsForPath path: Path) -> [AttributeError<Root>] where Path.Root == Root {
        return self.errors(includingDescendantsForPath: AnyPath(path))
    }
    
    public func errors<Path: PathProtocol>(includingDescendantsForPath path: Path) -> [AttributeError<Root>] where Path.Root == Root {
        return self.errors(includingDescendantsForPath: AnyPath(path))
    }
    
    public func errors(forPath path: AnyPath<Root>) -> [AttributeError<Root>] {
        func isAttributeType(_ type: Any.Type) -> Bool {
            return type == Attribute.self || type == BlockAttribute.self || type == LineAttribute.self
        }
        // Do we have an ancestor who is an attribute type?
        let ancestorIndex = path.ancestors.lastIndex(where: { isAttributeType($0.targetType) })
        // Is path an attribute type or does it have an ancestor which is an attribute type?
        guard isAttributeType(path.targetType) || nil != ancestorIndex else {
            let range = sortedCollection.range(of: AttributeError(message: "", path: path))
            return Array(self.sortedCollection[range])
        }
        // Operate with the path that is the attribute type.
        let path = isAttributeType(path.targetType) ? path : path.ancestors[ancestorIndex!]
        // Treat all subpaths of the attribute type as the same when fetching the errors.
        return self.errors(includingDescendantsForPath: path)
    }
    
    public func errors<Path: ReadOnlyPathProtocol>(forPath path: Path) -> [AttributeError<Root>] where Path.Root == Root {
        return self.errors(forPath: AnyPath(path))
    }
    
    public func errors<Path: PathProtocol>(forPath path: Path) -> [AttributeError<Root>] where Path.Root == Root {
        return self.errors(forPath: AnyPath(path))
    }
    
    public mutating func remove(includingDescendantsForPath path: AnyPath<Root>) {
        sortedCollection.removeSubrange(self.index(includingDescendantsForPath: path))
    }
    
    public mutating func remove<Path: ReadOnlyPathProtocol>(includingDescendantsForPath path: Path) where Path.Root == Root {
        self.remove(includingDescendantsForPath: AnyPath(path))
    }
    
    public mutating func remove<Path: PathProtocol>(includingDescendantsForPath path: Path) where Path.Root == Root {
        self.remove(includingDescendantsForPath: AnyPath(path))
    }
    
    public mutating func remove(forPath path: AnyPath<Root>) {
        sortedCollection.removeAll(AttributeError(message: "", path: path))
    }
    
    public mutating func remove<Path: ReadOnlyPathProtocol>(forPath path: Path) where Path.Root == Root {
        self.remove(forPath: AnyPath(path))
    }
    
    public mutating func remove<Path: PathProtocol>(forPath path: Path) where Path.Root == Root {
        self.remove(forPath: AnyPath(path))
    }
    
    public mutating func insert(_ error: AttributeError<Root>) {
        self.sortedCollection.insert(error)
    }
    
    private func index(includingDescendantsForPath path: AnyPath<Root>) -> Range<Int> {
        let elements = self.sortedCollection.right(ofAndIncluding: AttributeError(message: "", path: path))
        let index = elements.firstIndex { !path.isParent(of: $0.path) } ?? elements.endIndex
        return elements.startIndex..<index
    }
    
}
