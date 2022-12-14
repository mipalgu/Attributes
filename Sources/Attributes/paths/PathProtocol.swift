/*
 * PathProtocol.swift
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

/// Path to a value that can only be read and written to.
public protocol PathProtocol: ReadOnlyPathProtocol {

    /// The Root type containing the value.
    associatedtype Root

    /// The type of the value.
    associatedtype Value

    /// A read-only equivalent type of this path.
    var readOnly: ReadOnlyPath<Root, Value> { get }

    /// An equivalent WriteableKeyPath of this type.
    var path: WritableKeyPath<Root, Value> { get }

    /// Creates a new Path that points to the same value but with a different root.
    /// - Parameter path: A path pointing from the new Root to this paths Root. This path
    ///                   is prepended to self.
    /// - Returns:  The new path containing the new Root but pointing to the same value.
    func changeRoot<Prefix: PathProtocol>(path: Prefix) -> Path<Prefix.Root, Value> where Prefix.Value == Root

}

/// KeyPath computed property.
extension PathProtocol {

    /// Creates an equivalent KeyPath of this path.
    public var keyPath: KeyPath<Root, Value> {
        self.path as KeyPath<Root, Value>
    }

}

/// Equality conformance.
extension PathProtocol {

    /// Checks whether 2 Paths are the same.
    /// - Parameters:
    ///   - lhs: The Path on the left-hand side of the == operator.
    ///   - rhs: The Path on the right-hand side of the == operator.
    /// - Returns: Whether lhs is equal to rhs,
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path == rhs.path
    }

}
