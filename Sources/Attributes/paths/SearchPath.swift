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

/// Provides functions for searching a path for sub-paths that exist between the Root and
/// Value pointed to by the path.
public protocol SearchablePath {

    /// The type of the root object pointed to by this path.
    associatedtype Root

    /// The type of the value within the Root object pointed to by this path.
    associatedtype Value

    /// Check whether a Path exists within a sub-path between the Root object and the Value pointed to by this
    /// path.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - root: The root object containing the value pointed to by this path.
    /// - Returns: Whether path exists between the root object and value pointed to by this path.
    func isAncestorOrSame(of path: AnyPath<Root>, in root: Root) -> Bool

    /// Create an array of all possible paths that match self in the root object. For example, consider a
    /// collection that contains an array of 
    /// - Parameter root: The root object containing the properties pointed to by this path.
    /// - Returns: An array of all paths matching the SearchablePath.
    func paths(in root: Root) -> [Path<Root, Value>]

}

/// Provides methods for modifying a path such as appending path components and changing the root
/// of the path.
public protocol ConvertibleSearchablePath: SearchablePath {

    /// The value pointed to by this path.
    associatedtype Value

    /// Append a new path to end of this path.
    /// - Parameter path: The path to append to this path.
    /// - Returns: The new path with the path appended to self.
    @inlinable
    func appending<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Root, Path.Value> where Path.Root == Value

    /// Change the root of this path.
    /// - Parameter path: The path containing the new root.
    /// - Returns: A new path pointing to the same value as this path but with a different root.
    @inlinable
    func toNewRoot<Path: PathProtocol>(
        path: Path
    ) -> AnySearchablePath<Path.Root, Value> where Path.Value == Root

}
