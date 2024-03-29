/*
 * MakeUnavailableTrigger.swift
 * Attributes
 *
 * Created by Callum McColl on 21/6/21.
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

/// A trigger that removes a field when fired.
public struct MakeUnavailableTrigger<Source: PathProtocol, Fields: PathProtocol>: TriggerProtocol where
    Source.Root == Fields.Root, Fields.Value == [Field] {

    /// The Root is the same as the paths.
    public typealias Root = Fields.Root

    /// An AnyPath representation of source.
    @inlinable public var path: AnyPath<Root> {
        AnyPath(source)
    }

    /// The field to remove when the trigger is fired.
    @usableFromInline let field: Field

    /// The source path containing the field.
    @usableFromInline let source: Source

    /// The path to the fields array.
    @usableFromInline let fields: Fields

    /// Initialise this trigger from the field to remove and the paths affected.
    /// - Parameters:
    ///   - field: The field to remove from the source object.
    ///   - source: A path to the source object containing the Field to remove.
    ///   - fields: A path to the array of fields that hold the Field to remove.
    @inlinable
    public init(field: Field, source: Source, fields: Fields) {
        self.field = field
        self.source = source
        self.fields = fields
    }

    /// Perform the trigger function which removes the Field from the objects fields array.
    /// - Parameters:
    ///   - root: The source object containing the fields.
    ///   - _: 
    /// - Returns: Success when this trigger fired successfully. The trigger also returns a bool
    ///            indicating that a view needs to redraw.
    @inlinable
    public func performTrigger(
        _ root: inout Source.Root, for _: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Source.Root>> {
        if fields.isNil(root) {
            return .success(false)
        }
        let indexes = root[keyPath: fields.keyPath].indices.filter {
            root[keyPath: fields.keyPath][$0] == field
        }
        guard !indexes.isEmpty else {
            return .success(false)
        }
        indexes.reversed().forEach {
            root[keyPath: fields.path].remove(at: $0)
        }
        return .success(true)
    }

    /// Whether the path given will fire the trigger.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - _: 
    /// - Returns: True if this path fires the trigger, false otherwise.
    @inlinable
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
