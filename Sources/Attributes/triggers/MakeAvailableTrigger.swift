/*
 * MakeAvailableTrigger.swift
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

/// This trigger adds a field and attribute value to an object when triggered.
public struct MakeAvailableTrigger<
    Source: ReadOnlyPathProtocol,
    Fields: PathProtocol,
    Attributes: PathProtocol
>: TriggerProtocol where Source.Root == Fields.Root,
    Fields.Root == Attributes.Root,
    Fields.Value == [Field],
    Attributes.Value == [String: Attribute] {

    /// The Root of this trigger is the same as the Path roots.
    public typealias Root = Fields.Root

    /// An AnyPath version of the source.
    @inlinable public var path: AnyPath<Root> {
        AnyPath(source)
    }

    /// The field to make available in the object.
    @usableFromInline let field: Field

    /// The position to place the new field in the object. The trigger will find the first Field matching
    /// a name in this array and place the new field immediately before it.
    @usableFromInline let order: [String]

    /// The path to the element triggering this trigger.
    @usableFromInline let source: Source

    /// A path to the fields to change when this trigger is activated.
    @usableFromInline let fields: Fields

    /// A path to the attributes to change when this trigger is activated.
    @usableFromInline let attributes: Attributes

    /// Initialise this trigger with paths to relavent properties. This trigger assumes that an object
    /// contains a property with an array of Fields, and a property with a dictionary of Field name to
    /// Attribute. The trigger will mutate both of these properties when it fires.
    /// - Parameters:
    ///   - field: The new field to add to the root object.
    ///   - order: The order to place the new field in. The trigger will search this array and the fields
    ///            in the object for a suitable place for the new field. If a field matches one in this array
    ///            then the new field will be placed immediately before it.
    ///   - source: A path to the source object that is causing this trigger to act. All children of the
    ///             source will also cause this trigger to fire.
    ///   - fields: A path to the fields to mutate when adding the new field.
    ///   - attributes: A path to the attributes to mutate when this trigger is fired.
    @inlinable
    public init(field: Field, after order: [String], source: Source, fields: Fields, attributes: Attributes) {
        self.field = field
        self.order = order
        self.source = source
        self.fields = fields
        self.attributes = attributes
    }

    /// Perform the trigger function which adds the new field to an object.
    /// - Parameters:
    ///   - root: The object to mutate.
    ///   - _: A null path, this value is not used in this trigger but remains for API stability.
    /// - Returns: A result indicating the success of the trigger. A success result indicates that
    ///            the new field was made available. The boolean contained within the success case
    ///            indicates whether to redraw the view.
    @inlinable
    public func performTrigger(
        _ root: inout Source.Root, for _: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Source.Root>> {
        if root[keyPath: fields.keyPath].contains(where: { $0.name == field.name }) {
            return .success(false)
        }
        let indices = order.compactMap {
            root[keyPath: fields.path].lazy.map(\.name).firstIndex(of: $0)
        }
        root[keyPath: fields.path].insert(field, at: indices.first ?? 0)
        if root[keyPath: attributes.keyPath][field.name] == nil {
            root[keyPath: attributes.path][field.name] = field.type.defaultValue
        }
        return .success(true)
    }

    /// Check whether a given path will cause this trigger to act.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - _: 
    /// - Returns: A boolean indicating whether this trigger is triggered by the path.
    @inlinable
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
