/*
 * AnyGroup.swift
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

/// A Type-Erased version of types conforming to ``GroupProtocol``.
public struct AnyGroup<Root: Modifiable> {

    /// The path to the attribute groups within the group.
    private let _path: () -> AnySearchablePath<Root, AttributeGroup>

    /// A path to the fields in the group.
    private let _pathToFields: () -> Path<AttributeGroup, [Field]>

    /// A path to the attributes in the group.
    private let _pathToAttributes: () -> Path<AttributeGroup, [String: Attribute]>

    /// The properties in the group.
    private let _properties: () -> [SchemaAttribute]

    /// The validator for the properties in the group.
    private let _propertiesValidator: () -> AnyValidator<AttributeGroup>

    /// The triggers for the root object.
    private let _triggers: () -> AnyTrigger<Root>

    /// All the triggers in the group.
    private let _allTriggers: () -> AnyTrigger<Root>

    /// The validator for the attribute group.
    private let _groupValidation: () -> AnyValidator<AttributeGroup>

    /// The validator for the root object.
    private let _rootValidation: () -> AnyValidator<Root>

    /// A function to find the property from a path.
    private let _findProperty: (AnyPath<Root>, Root) -> SchemaAttribute?

    /// The type-erased wrapped value.
    let base: Any

    /// The path to the attribute groups.
    public var path: AnySearchablePath<Root, AttributeGroup> {
        _path()
    }

    /// The path to the fields within the group.
    public var pathToFields: Path<AttributeGroup, [Field]> {
        _pathToFields()
    }

    /// The path to the attributes within the group.
    public var pathToAttributes: Path<AttributeGroup, [String: Attribute]> {
        _pathToAttributes()
    }

    /// All properties within the group.
    public var properties: [SchemaAttribute] {
        _properties()
    }

    /// The validator for the properties.
    public var propertiesValidator: AnyValidator<AttributeGroup> {
        self._propertiesValidator()
    }

    /// The triggers for the root object.
    public var triggers: AnyTrigger<Root> {
        self._triggers()
    }

    /// All triggers in this group.
    public var allTriggers: AnyTrigger<Root> {
        self._allTriggers()
    }

    /// A validator for an attribute group.
    public var groupValidation: AnyValidator<AttributeGroup> {
        self._groupValidation()
    }

    /// The root validator.
    public var rootValidation: AnyValidator<Root> {
        self._rootValidation()
    }

    /// Create a type-erased version of an instance of ``GroupProtocol``.
    /// - Parameter base: The group to type-erase.
    public init<Base: GroupProtocol>(_ base: Base) where Base.Root == Root {
        self._path = { AnySearchablePath(base.path) }
        self._pathToFields = { base.pathToFields }
        self._pathToAttributes = { base.pathToAttributes }
        self._properties = { base.properties }
        self._propertiesValidator = { base.propertiesValidator }
        self._triggers = { AnyTrigger(base.triggers) }
        self._allTriggers = { base.allTriggers }
        self._groupValidation = { base.groupValidation }
        self._rootValidation = { base.rootValidation }
        self._findProperty = { base.findProperty(path: $0, in: $1) }
        self.base = base
    }

    /// Find a property for a value specified by a path existing within a root object.
    /// - Parameters:
    ///   - path: The path pointing to the object.
    ///   - root: The root object containing the member pointed to by `path`.
    /// - Returns: The property or nil.
    func findProperty(path: AnyPath<Root>, in root: Root) -> SchemaAttribute? {
        self._findProperty(path, root)
    }

}
