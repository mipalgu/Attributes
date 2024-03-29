// Path+ConvertibleSearchablePath.swift 
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

/// ConvertibleSearchablePath conformance.
extension Path: ConvertibleSearchablePath {

    /// Checks if self is a parent or the same as a given path in a root object.
    /// - Parameters:
    ///   - path: The path to compare too.
    ///   - root: The root object containing the property pointed to by path.
    /// - Returns: True if self is a parent of the path, false otherwise.
    @inlinable
    public func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool {
        let anyPath = AnyPath(self)
        return anyPath.isSame(as: path) || anyPath.isParent(of: path)
    }

    /// Returns the paths from the Root object to the Value.
    /// - Parameter root: The root object.
    /// - Returns: An array of paths from root to the value pointed to by self.
    @inlinable
    public func paths(in root: Root) -> [Path<Root, Value>] {
        [self]
    }

    /// Creates a new path by appending a path to self. This changes the value pointed to by self in the new
    /// path.
    /// - Parameter path: The patht o append to self.
    /// - Returns: The new path.
    public func appending<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value {
        let ancestors = self.ancestors + path.ancestors.map { $0.changeRoot(path: self) }
        return AnySearchablePath(
            Attributes.Path<Root, Path.Value>(
                path: self.path.appending(path: path.path), ancestors: ancestors
            )
        )
    }

    /// Creates a new path that points to the same value as self but has a different root object.
    /// - Parameter path: A path from the new root object to the current root object.
    /// - Returns: The new path.
    public func toNewRoot<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root {
        let ancestors = path.ancestors + self.ancestors.map {
            $0.changeRoot(path: path)
        }
        let newPath = Attributes.Path<Path.Root, Value>(
            path: path.path.appending(path: self.path), ancestors: ancestors
        )
        return AnySearchablePath(newPath)
    }

}
