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

public protocol Attributable {
    
    associatedtype Root: Modifiable
    associatedtype AttributeRoot
    associatedtype SearchPath: ConvertibleSearchablePath where SearchPath.Root == Root, SearchPath.Value == AttributeRoot
    
    var path: SearchPath { get }
    
    var pathToFields: Path<AttributeRoot, [Field]> { get }
    
    var pathToAttributes: Path<AttributeRoot, [String: Attribute]> { get }
    
    var available: Set<String> { get }

    var properties: [SchemaAttribute] { get }
    
    var propertiesValidator: AnyValidator<AttributeRoot> { get }
    
    var triggers: AnyTrigger<Root> { get }
    
    var allTriggers: AnyTrigger<Root> { get }
    
    var groupValidation: AnyValidator<AttributeRoot> { get }

    var rootValidation: AnyValidator<Root> { get }
    
}

public extension Attributable {
    
    typealias ComplexCollectionProperty<Base> = Attributes.ComplexCollectionProperty<Base> where Base: ComplexProtocol, Base.Root == AttributeRoot
    
    typealias ComplexProperty<Base> = Attributes.ComplexProperty<Base> where Base: ComplexProtocol, Base.Root == AttributeRoot
    
    var available: Set<String> {
        Set(properties.map(\.label))
    }
    
    var triggers: AnyTrigger<Root> {
        AnyTrigger<Root>()
    }
    
    var allTriggers: AnyTrigger<Root> {
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
        return AnyTrigger([triggers, AnyTrigger(childTriggers)])
    }
    
    var groupValidation: AnyValidator<AttributeRoot> {
        AnyValidator<AttributeRoot>()
    }
    
    var rootValidation: AnyValidator<Root> {
        AnyValidator<Root>()
    }
    
    var properties: [SchemaAttribute] {
        let mirror = Mirror(reflecting: self)
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
                    fallthrough
                }
            default:
                return nil
            }
        }
    }
    
    var propertiesValidator: AnyValidator<AttributeRoot>  {
        let available = self.available
        let propertyValidators: [AnyValidator<AttributeRoot>] = properties.compactMap {
            if !available.contains($0.label) {
                return nil
            }
            return $0.validate.toNewRoot(path: pathToAttributes[$0.label].wrappedValue)
        }
        return AnyValidator(propertyValidators)
    }
    
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
    
    func path(for attribute: SchemaAttribute) -> AnySearchablePath<Root, Attribute> {
        self.path.appending(path: self.pathToAttributes[attribute.label].wrappedValue)
    }
    
    func path(for attribute: SchemaAttribute, in path: Path<Root, AttributeRoot>) -> Path<Root, Attribute> {
        pathToAttributes.changeRoot(path: path)[attribute.label].wrappedValue
    }
    
    func WhenChanged(_ attribute: SchemaAttribute) -> ForEach<AnySearchablePath<Self.Root, Attribute>, WhenChanged<Path<Self.Root, Attribute>, IdentityTrigger<Self.Root>>> {
        ForEach(path(for: attribute)) {
            Attributes.WhenChanged($0)
        }
    }
    
    func WhenChanged<T>(_ value: Path<[LineAttribute], T>, in attribute: SchemaAttribute, perform: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>) -> ForEach<Self.SearchPath, ForEach<CollectionSearchPath<Self.Root, [[LineAttribute]], T>, CustomTrigger<Path<CollectionSearchPath<Self.Root, [[LineAttribute]], T>.Root, CollectionSearchPath<Self.Root, [[LineAttribute]], T>.Value>>>> {
        if !attribute.type.isTable {
            fatalError("Calling `WhenChanged(_:in:)` on attribute that is not a table property")
        }
        return ForEach(self.path) { groupPath in
            let attributePath = self.path(for: attribute, in: groupPath)
            ForEach(CollectionSearchPath(collectionPath: attributePath.tableValue, elementPath: value)) { path in
                Attributes.WhenChanged(path).custom(perform)
            }
        }
    }
    
    func WhenTrue(_ attribute: SchemaAttribute, makeAvailable hiddenAttribute: SchemaAttribute) -> ForEach<Self.SearchPath, WhenChanged<Path<Self.Root, Attribute>, ConditionalTrigger<MakeAvailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>, Path<Self.Root, [String : Attribute]>>>>> {
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
    
    func WhenFalse(_ attribute: SchemaAttribute, makeAvailable hiddenAttribute: SchemaAttribute) -> ForEach<Self.SearchPath, WhenChanged<Path<Self.Root, Attribute>, ConditionalTrigger<MakeAvailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>, Path<Self.Root, [String : Attribute]>>>>> {
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
    
    func WhenTrue(_ attribute: SchemaAttribute, makeUnavailable hiddenAttribute: SchemaAttribute) -> ForEach<Self.SearchPath, WhenChanged<Path<Self.Root, Attribute>, ConditionalTrigger<MakeUnavailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>>>>> {
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
    
    func WhenFalse(_ attribute: SchemaAttribute, makeUnavailable hiddenAttribute: SchemaAttribute) -> ForEach<Self.SearchPath, WhenChanged<Path<Self.Root, Attribute>, ConditionalTrigger<MakeUnavailableTrigger<Path<Self.Root, Attribute>, Path<Self.Root, [Field]>>>>> {
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

}
