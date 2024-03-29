/*
 * SyncTrigger.swift
 * Attributes
 *
 * Created by Callum McColl on 17/6/21.
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

/// A trigger that updates a target value with a source value when that source value changes.
public struct SyncTrigger<Source: PathProtocol, Target: SearchablePath>: TriggerProtocol where
    Source.Root == Target.Root, Source.Value == Target.Value {

    /// The Root of the Trigger matches the `Source` and `Target`.
    public typealias Root = Source.Root

    /// The source path as a type-erased path.
    @inlinable public var path: AnyPath<Root> {
        AnyPath(source)
    }

    /// The source path.
    @usableFromInline let source: Source

    /// The target path.
    @usableFromInline let target: Target

    /// Initialise this trigger with a source and target. This initialiser sets the source paths that
    /// specify that value to update the target paths with when the trigger fires.
    /// - Parameters:
    ///   - source: The source path. This path points to the values to copy into the properties located
    ///             in the target path.
    ///   - target: The target path. These values will be mutated when the trigger fires.
    @inlinable
    public init(source: Source, target: Target) {
        self.source = source
        self.target = target
    }

    /// Perform the synchonisation function of this trigger. This functions updates the target values with
    /// the source values.
    /// - Parameters:
    ///   - root: The object containing the source and target values.
    ///   - _: Unused. This parameter remains in the function delcaration to preserve protocol conformance
    ///        with ``TriggerProtocol``.
    /// - Returns: Always returns `.succes(true)` indicating that the target was successfully updated.
    @inlinable
    public func performTrigger(
        _ root: inout Source.Root, for _: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Source.Root>> {
        for path in target.paths(in: root) {
            root[keyPath: path.path] = root[keyPath: source.keyPath]
        }
        return .success(true)
    }

    /// Check whether this trigger is fired by a value pointed to by a path.
    /// - Parameters:
    ///   - path: The path is check.
    ///   - _: Unused. This parameter remains in the function delcaration to preserve protocol conformance
    ///        with ``TriggerProtocol``.
    /// - Returns: Whether this trigger is fired by `path`.
    @inlinable
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
