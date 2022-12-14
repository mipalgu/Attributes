/*
 * SyncWithTransformTrigger.swift
 * Attributes
 *
 * Created by Morgan McColl on 24/7/21.
 * Copyright © 2021 Morgan McColl. All rights reserved.
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

/// A trigger that overwrites a target value from a source value by using a transformation function.
/// This trigger will be enacted when the source value changes. Once the source value is changed,
/// this trigger will fire causing an update in the target value by using the transform function.
public struct SyncWithTransformTrigger<
    Source: PathProtocol, Target: SearchablePath
>: TriggerProtocol where Source.Root == Target.Root {

    /// The Root of the paths in this trigger..
    public typealias Root = Source.Root

    /// A type-erased path to the source value.
    @inlinable public var path: AnyPath<Root> {
        AnyPath(source)
    }

    /// A path to the source value existing in `Root`.
    @usableFromInline let source: Source

    /// A path to the target value existing in `Root`.
    @usableFromInline let target: Target

    /// A transformation function that converts a `Source` value into a `Target` value.
    @usableFromInline let transform: (Source.Value, Target.Value) -> Target.Value

    /// Initialise this trigger with path to the source & target. and a transformation function.
    /// - Parameters:
    ///   - source: The source value that will cause this trigger to fire.
    ///   - target: The target value which will be mutated by this trigger.
    ///   - transform: The transform function that converts the `source` value into a `target` value.
    @inlinable
    public init(
        source: Source, target: Target, transform: @escaping (Source.Value, Target.Value) -> Target.Value
    ) {
        self.source = source
        self.target = target
        self.transform = transform
    }

    /// Converts a source value contained within `root`` into a new target value. This new target
    /// value then mutates `root` and updates the property pointed to by `target`.
    /// - Parameters:
    ///   - root: The root object containing the `source` and `target` properties.
    /// - Returns: Whether the trigger was successful. The bool in the success case will indicate
    /// that the values were mutated. The failure case will contain the error that occurred.
    @inlinable
    public func performTrigger(
        _ root: inout Source.Root, for _: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Source.Root>> {
        for path in target.paths(in: root) {
            guard !path.isNil(root) else {
                return .failure(AttributeError(message: "Tried to trigger update to nil path", path: path))
            }
            root[keyPath: path.path] = transform(root[keyPath: source.keyPath], root[keyPath: path.keyPath])
        }
        return .success(true)
    }

    /// Determins if a given path will cause this trigger to fire.
    /// - Parameters:
    ///   - path: The path to check.
    /// - Returns: Whether `path` will cause this trigger to fire.
    @inlinable
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
