/*
 * GroupProtocol.swift
 * Attributes
 *
 * Created by Morgan McColl on 30/5/21.
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

/// A schema is the top-level representation of an attribute heirarchy. A schema
/// contains type information, validators, and triggers for all attributes that
/// are related. A schema can only contain groups, and you may use the `@Group`
/// property wrapper to define the groups within this schema.
public protocol SchemaProtocol {

    /// The data container holding the groups defined by this schema.
    associatedtype Root: Modifiable

    /// The groups within this schema.
    var groups: [AnyGroup<Root>] { get }

    /// The trigger for every group within this schema.
    var trigger: AnyTrigger<Root> { get }

    /// Create a validator for every group within this schema for a given
    /// root.
    /// - Parameter root: The root to validate.
    /// - Returns: The new validator.
    func makeValidator(root: Root) -> AnyValidator<Root>

}

/// Add extra helper functions to a schema.
public extension SchemaProtocol {

    /// A group definition.
    typealias Group<GroupType: GroupProtocol> = Attributes.Group<GroupType>

    /// The trigger is all the group triggers by default.
    var trigger: AnyTrigger<Root> {
        AnyTrigger(groups.map(\.allTriggers))
    }

    /// All of the groups within the schema.
    var groups: [AnyGroup<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = ($0.value as? ConvertibleToGroup)?.anyGroup as? AnyGroup<Root> {
                return val
            }
            return nil
        }
    }

    /// Creates a validator that is equivalent to every validator within all of the groups
    /// for a specific root object.
    /// - Parameter root: The root object.
    /// - Returns: The new validator.
    func makeValidator(root: Root) -> AnyValidator<Root> {
        let groups: [AnyGroup<Root>] = self.groups
        return AnyValidator(groups.enumerated().map {
            let path: ReadOnlyPath<Root, AttributeGroup> = Root.path.attributes[$0]
            let propertiesValidator = ChainValidator(path: path, validator: $1.propertiesValidator)
            let groupValidator = ChainValidator(path: path, validator: $1.groupValidation)
            let rootValidator = $1.rootValidation
            return AnyValidator([AnyValidator([propertiesValidator, groupValidator]), rootValidator])
        })
    }

}
