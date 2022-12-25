/*
 * Attributable.swift
 * 
 *
 * Created by Callum McColl on 12/6/21.
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

/// This protocol provides the bare-minimum implementation for a group of attributes
/// that can be validated, triggered, and displayed. An instance of this protocol
/// represents the types of attributes accessible through this interface. Additionally,
/// this protocol defines the validators required for each attribute and all the attributes
/// as a whole. A similar requirement is placed on the triggers, where an instance may define a
/// trigger that reacts to target attributes within this protocol.
/// 
/// This protocol acts as the foundational protocol for the schema definitions. A schema is an
/// implementation of this protocol with additional structures for types that combine grouped attributes and
/// nested/recursive attributes. Each instance of Attributable is designed to work with a specific root
/// object that is ``Modifiable``. Changing the data in the root object may require validation rules specified
/// in this protocol and may trigger changes within the modifiable through the triggers defined in this
/// protocol.
/// 
/// Furthermore, this protocol is defined to work with a root attribute that will typically be a
/// ``BlockAttribute`` using nested attributes. The properties defined in this protocol should
/// reflect the attributes within the root attribute and the paths should point to where these
/// attributes are defined within the root object.
public protocol Attributable {

    /// The root object type that contains the data represented by this protocol.
    associatedtype Root: Modifiable

    /// The type of the root Attribute.
    associatedtype AttributeRoot

    /// The type of the triggers that are defined for this protocol.
    associatedtype TriggerType where TriggerType: TriggerProtocol, TriggerType.Root == Root,
        TriggerType.Root == SearchPath.Root

    /// The type of the path from the root to the root attribute.
    associatedtype SearchPath: ConvertibleSearchablePath where
        SearchPath.Root == Root, SearchPath.Value == AttributeRoot

    /// A path to the root attribute contained within the root object.
    var path: SearchPath { get }

    /// A path to the fields in the modifiable.
    var pathToFields: Path<AttributeRoot, [Field]> { get }

    /// Path to any nested attributes within the root attribute.
    var pathToAttributes: Path<AttributeRoot, [String: Attribute]> { get }

    /// All attributes within the root attribute. This property allows a declarative style of programming
    /// where attributes are defined using property wrappers. This property will represent all attributes
    /// contained within the root attribute.
    var properties: [SchemaAttribute] { get }

    /// The validator for all of the properties.
    var propertiesValidator: AnyValidator<AttributeRoot> { get }

    /// Additional triggers that are not defined for each attribute.
    var triggers: TriggerType { get }

    /// All triggers within this protocol.
    var allTriggers: AnyTrigger<Root> { get }

    /// A validation for the group containing the root attribute.
    var groupValidation: AnyValidator<AttributeRoot> { get }

    /// The validator for the root object.
    var rootValidation: AnyValidator<Root> { get }

}

/// Add default triggers.
public extension Attributable where TriggerType == AnyTrigger<Root> {

    /// No additional triggers by default.
    @TriggerBuilder<Root>
    @inlinable var triggers: TriggerType {
        AnyTrigger<Root>()
    }

}

/// Add helper methods to all Attributable implementations.
public extension Attributable {

    /// ComplexCollectionProperty definition.
    typealias ComplexCollectionProperty<Base> = Attributes.ComplexCollectionProperty<Base> where
        Base: ComplexProtocol, Base.Root == AttributeRoot

    /// ComplexProperty definition.
    typealias ComplexProperty<Base> = Attributes.ComplexProperty<Base> where
        Base: ComplexProtocol, Base.Root == AttributeRoot

    /// All of the triggers are those defined in the attribute properties and the additional
    /// triggers within the `triggers` property.
    @inlinable var allTriggers: AnyTrigger<Root> {
        let mirror = Mirror(reflecting: self)
        let childTriggers: [AnyTrigger<Root>] = mirror.children.compactMap {
            guard
                let val = $0.value as? SchemaAttributeConvertible,
                let triggers = val.allTriggers as? AnyTrigger<Root>
            else {
                return nil
            }
            return triggers
        }
        return AnyTrigger([AnyTrigger(triggers), AnyTrigger(childTriggers)])
    }

    /// No validation by default.
    @inlinable var groupValidation: AnyValidator<AttributeRoot> {
        AnyValidator<AttributeRoot>()
    }

    /// No validation by default.
    @inlinable var rootValidation: AnyValidator<Root> {
        AnyValidator<Root>()
    }

    /// The properties of an instance of this protocol are created through dynamic member lookup
    /// by default. This property will search the types within `Self` and find all properties that
    /// use an attribute property wrapper.
    @inlinable var properties: [SchemaAttribute] {
        let mirror = Mirror(reflecting: self)
        // swiftlint:disable:next closure_body_length
        return mirror.children.compactMap {
            switch $0.value {
            case let val as BoolProperty:
                return val.wrappedValue
            case let val as IntegerProperty:
                return val.wrappedValue
            case let val as FloatProperty:
                return val.wrappedValue
            case let val as ExpressionProperty:
                return val.wrappedValue
            case let val as EnumeratedProperty:
                return val.wrappedValue
            case let val as LineProperty:
                return val.wrappedValue
            case let val as CodeProperty:
                return val.wrappedValue
            case let val as TextProperty:
                return val.wrappedValue
            case let val as EnumerableCollectionProperty:
                return val.wrappedValue
            case let val as CollectionProperty:
                return val.wrappedValue
            case let val as TableProperty:
                return val.wrappedValue
            case let val as SchemaAttributeConvertible:
                if let attribute = val.schemaAttribute as? SchemaAttribute {
                    return attribute
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
    }

    /// This property reduces all attribute property validators into a single validator.
    @inlinable var propertiesValidator: AnyValidator<AttributeRoot> {
        let propertyValidators: [AnyValidator<AttributeRoot>] = properties.compactMap {
            $0.validate.toNewRoot(path: pathToAttributes[$0.label].wrappedValue)
        }
        return AnyValidator(propertyValidators)
    }

    /// Find the property located at a path in the root object that is affected by this instance.
    /// - Parameters:
    ///   - path: The path of the attribute.
    ///   - root: The root object containing the property.
    /// - Returns: The property of nil if the path is invalid. This function will also return
    /// nil for block attributes. It is assumed that the properties to locate exist within the
    /// root attribute.
    @inlinable
    func findProperty(path: AnyPath<Root>, in root: Root) -> SchemaAttribute? {
        guard let property = properties.first(where: {
            let searchPath = self.path(for: $0)
            return searchPath.isAncestorOrSame(of: path, in: root)
        }) else {
            return nil
        }
        switch property.type {
        case .block(.complex), .block(.collection), .block(.table):
            return nil
        default:
            return property
        }
    }

    /// Get a path for an attribute that exists within this type heirarchy.
    /// - Parameter attribute: The attribute to locate.
    /// - Returns: The path to the attribute to locate.
    @inlinable
    func path(for attribute: SchemaAttribute) -> AnySearchablePath<Root, Attribute> {
        self.path.appending(path: self.pathToAttributes[attribute.label].wrappedValue)
    }

    /// Get a path from the root object to an attribute that exists within the attributes dictionary.
    /// - Parameters:
    ///   - attribute: The attribute to locate.
    ///   - path: A path from the root object to the attributes dictionary that contains all attributes.
    /// - Returns: The new path from the root object to the attribute to locate.
    @inlinable
    func path(for attribute: SchemaAttribute, in path: Path<Root, AttributeRoot>) -> Path<Root, Attribute> {
        pathToAttributes.changeRoot(path: path)[attribute.label].wrappedValue
    }

    // swiftlint:disable identifier_name

    /// Creates a trigger that is fired when an attribute changes.
    /// - Parameter attribute: The attribute that causes the trigger to fire.
    /// - Returns: A new trigger.
    @inlinable
    func WhenChanged(_ attribute: SchemaAttribute) -> ForEach<
        AnySearchablePath<Self.Root, Attribute>,
        WhenChanged<Path<Self.Root, Attribute>,
        IdentityTrigger<Self.Root>>
    > {
        ForEach(path(for: attribute)) {
            Attributes.WhenChanged($0)
        }
    }

    /// Creates a trigger that performs a custom trigger function when a table row is mutated.
    /// - Parameters:
    ///   - value: A path to the row that causes the new trigger to fire.
    ///   - attribute: The table containing the row that causes this trigger to fire.
    ///   - perform: The custom trigger function to enact when the trigger fires.
    /// - Returns: The new trigger.
    /// - Warning: Passing non-table values into attribute will cause a run-time crash.
    @inlinable
    func WhenChanged<T>(
        _ value: Path<[LineAttribute], T>,
        in attribute: SchemaAttribute,
        perform: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>
    ) -> ForEach<
        Self.SearchPath,
        ForEach<
            CollectionSearchPath<Self.Root, [[LineAttribute]], T>,
            CustomTrigger<
                Path<
                    CollectionSearchPath<Self.Root, [[LineAttribute]], T>.Root,
                    CollectionSearchPath<Self.Root, [[LineAttribute]], T>.Value
                >
            >
        >
    > {
        if !attribute.type.isTable {
            fatalError("Calling `WhenChanged(_:in:)` on attribute that is not a table property")
        }
        return ForEach(self.path) { groupPath in
            let attributePath = self.path(for: attribute, in: groupPath)
            ForEach(
                CollectionSearchPath(collectionPath: attributePath.tableValue, elementPath: value)
            ) { path in
                Attributes.WhenChanged(path).custom(perform)
            }
        }
    }

    /// Creates a trigger that makes an attribute available when a boolean attribute is set to true.
    /// - Parameters:
    ///   - attribute: The boolean attribute that fires the new trigger.
    ///   - hiddenAttribute: The attribute to make available.
    /// - Returns: The new trigger.
    /// - Warning: Passing a non-boolean attribute into `attribute` will cause a runtime crash.
    @inlinable
    func WhenTrue(
        _ attribute: SchemaAttribute, makeAvailable hiddenAttribute: SchemaAttribute
    ) -> ForEach<
        Self.SearchPath,
        WhenChanged<
            Path<Self.Root, Attribute>,
            ConditionalTrigger<
                MakeAvailableTrigger<
                    Path<Self.Root, Attribute>,
                    Path<Self.Root, [Field]>,
                    Path<Self.Root, [String: Attribute]>
                >
            >
        >
    > {
        if attribute.type != .bool {
            fatalError("Calling `WhenTrue` when attributes type is not `bool`.")
        }
        let order: [String]
        if let index = properties.firstIndex(where: { $0.label == hiddenAttribute.label }) {
            order = Array(properties[0..<index].map(\.label))
        } else {
            order = []
        }
        return ForEach(self.path) { path in
            let attributePath = self.path(for: attribute, in: path)
            Attributes.WhenChanged(attributePath).when {
                attributePath.boolValue.isNil($0) ? false : $0[keyPath: attributePath.boolValue.keyPath]
            } then: { (trigger: WhenChanged<Path<Root, Attribute>, IdentityTrigger<Root>>) in
                trigger.makeAvailable(
                    field: Field(name: hiddenAttribute.label, type: hiddenAttribute.type),
                    after: order,
                    fields: pathToFields.changeRoot(path: path),
                    attributes: pathToAttributes.changeRoot(path: path)
                )
            }
        }
    }

    /// Creates a trigger that makes an attribute available when a boolean attribute is set to false.
    /// - Parameters:
    ///   - attribute: The boolean attribute that fires the new trigger.
    ///   - hiddenAttribute: The attribute to make available.
    /// - Returns: The new trigger.
    /// - Warning: Passing a non-boolean attribute into `attribute` will cause a runtime crash.
    @inlinable
    func WhenFalse(
        _ attribute: SchemaAttribute, makeAvailable hiddenAttribute: SchemaAttribute
    ) -> ForEach<
        Self.SearchPath,
        WhenChanged<
            Path<Self.Root, Attribute>,
            ConditionalTrigger<
                MakeAvailableTrigger<
                    Path<Self.Root, Attribute>,
                    Path<Self.Root, [Field]>,
                    Path<Self.Root, [String: Attribute]>
                >
            >
        >
    > {
        if attribute.type != .bool {
            fatalError("Calling `WhenTrue` when attributes type is not `bool`.")
        }
        let order: [String]
        if let index = properties.firstIndex(where: { $0.label == hiddenAttribute.label }) {
            order = Array(properties[0..<index].map(\.label))
        } else {
            order = []
        }
        return ForEach(self.path) { path in
            let attributePath = self.path(for: attribute, in: path)
            Attributes.WhenChanged(attributePath).when {
                attributePath.boolValue.isNil($0) ? false : !$0[keyPath: attributePath.boolValue.keyPath]
            } then: { (trigger: WhenChanged<Path<Root, Attribute>, IdentityTrigger<Root>>) in
                trigger.makeAvailable(
                    field: Field(name: hiddenAttribute.label, type: hiddenAttribute.type),
                    after: order,
                    fields: pathToFields.changeRoot(path: path),
                    attributes: pathToAttributes.changeRoot(path: path)
                )
            }
        }
    }

    /// Creates a trigger that makes an attribute unavailable when a boolean attribute is set to true.
    /// - Parameters:
    ///   - attribute: The boolean attribute that fires the new trigger.
    ///   - hiddenAttribute: The attribute to make unavailable.
    /// - Returns: The new trigger.
    /// - Warning: Passing a non-boolean attribute into `attribute` will cause a runtime crash.
    @inlinable
    func WhenTrue(
        _ attribute: SchemaAttribute, makeUnavailable hiddenAttribute: SchemaAttribute
    ) -> ForEach<
        Self.SearchPath,
        WhenChanged<
            Path<Self.Root, Attribute>,
            ConditionalTrigger<
                MakeUnavailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>>
            >
        >
    > {
        if attribute.type != .bool {
            fatalError("Calling `WhenTrue` when attributes type is not `bool`.")
        }
        return ForEach(self.path) { path in
            let attributePath = self.path(for: attribute, in: path)
            Attributes.WhenChanged(attributePath).when {
                attributePath.boolValue.isNil($0) ? false : $0[keyPath: attributePath.boolValue.keyPath]
            } then: { (trigger: WhenChanged<Path<Root, Attribute>, IdentityTrigger<Root>>) in
                trigger.makeUnavailable(
                    field: Field(name: hiddenAttribute.label, type: hiddenAttribute.type),
                    fields: pathToFields.changeRoot(path: path)
                )
            }
        }
    }

    /// Creates a trigger that makes an attribute unavailable when a boolean attribute is set to false.
    /// - Parameters:
    ///   - attribute: The boolean attribute that fires the new trigger.
    ///   - hiddenAttribute: The attribute to make unavailable.
    /// - Returns: The new trigger.
    /// - Warning: Passing a non-boolean attribute into `attribute` will cause a runtime crash.
    @inlinable
    func WhenFalse(
        _ attribute: SchemaAttribute, makeUnavailable hiddenAttribute: SchemaAttribute
    ) -> ForEach<
        Self.SearchPath,
        WhenChanged<
            Path<Self.Root, Attribute>,
            ConditionalTrigger<MakeUnavailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>>>
        >
    > {
        if attribute.type != .bool {
            fatalError("Calling `WhenTrue` when attributes type is not `bool`.")
        }
        return ForEach(self.path) { path in
            let attributePath = self.path(for: attribute, in: path)
            Attributes.WhenChanged(attributePath).when {
                attributePath.boolValue.isNil($0) ? false : !$0[keyPath: attributePath.boolValue.keyPath]
            } then: { (trigger: WhenChanged<Path<Root, Attribute>, IdentityTrigger<Root>>) in
                trigger.makeUnavailable(
                    field: Field(name: hiddenAttribute.label, type: hiddenAttribute.type),
                    fields: pathToFields.changeRoot(path: path)
                )
            }
        }
    }

    // swiftlint:enable identifier_name

}
