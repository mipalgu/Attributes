/*
 * ForEach.swift
 * Attributes
 *
 * Created by Callum McColl on 30/6/21.
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

/// A trigger that will apply a separate trigger to all elements within a collection.
public struct ForEach<SearchPath: SearchablePath, Trigger: TriggerProtocol>: TriggerProtocol where
    Trigger.Root == SearchPath.Root {

    /// The path to the root object that contains the elements to iterate over.
    private let path: SearchPath

    /// A builder that will create a suitable trigger for each element.
    private let builder: (Path<SearchPath.Root, SearchPath.Value>) -> Trigger

    /// Create a `ForEach` trigger that will be applied to all subpaths within `path`. This trigger
    /// applies a separate trigger created from `builder`.
    /// - Parameters:
    ///   - path: The path to the root object containing the elements to iterate over.
    ///   - builder: The trigger to apply to each element.
    public init(
        _ path: SearchPath,
        @TriggerBuilder<SearchPath.Root> each builder: @escaping (
            Path<SearchPath.Root, SearchPath.Value>
        ) -> Trigger
    ) {
        self.path = path
        self.builder = builder
    }

    /// Perform the trigger within `builder` to each element within `root` pointed to by `path`.
    /// - Parameters:
    ///   - root: The root object containing the elements to iterate over.
    ///   - path: The path to the property containing the elements.
    /// - Returns: A result from the `performTrigger` method of the trigger created from `builder`.
    public func performTrigger(
        _ root: inout SearchPath.Root, for path: AnyPath<SearchPath.Root>
    ) -> Result<Bool, AttributeError<SearchPath.Root>> {
        var changed = false
        for subpath in self.path.paths(in: root) {
            let trigger = builder(subpath)
            let result = trigger.performTrigger(&root, for: path)
            switch result {
            case .success(let shouldNotify):
                changed = changed || shouldNotify
                continue
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(changed)
    }

    /// Check whether a given path within a root object will cause this trigger to fire.
    /// - Parameters:
    ///   - path: The path to the element within root that might cause this trigger to fire.
    ///   - root: The root object.
    /// - Returns: Whether this trigger is fired by `path` within `root`.
    public func isTriggerForPath(_ path: AnyPath<SearchPath.Root>, in root: SearchPath.Root) -> Bool {
        self.path.isAncestorOrSame(of: path, in: root)
    }

}

/// Add standard triggers.
extension ForEach where
    Trigger == WhenChanged<Path<SearchPath.Root, SearchPath.Value>,
    IdentityTrigger<SearchPath.Root>> {

    /// Create ``WhenChanged`` trigger.
    /// - Parameters:
    ///   - condition: The condition causing the trigger to fire.
    ///   - builder: The trigger eneacted when the `condition` is true.
    /// - Returns: The new trigger.
    /// - SeeAlso: ``WhenChanged``.
    public func when<NewTrigger: TriggerProtocol>(
        _ condition: @escaping (Root) -> Bool,
        @TriggerBuilder<Root> then builder: @escaping (Trigger) -> NewTrigger
    ) -> ForEach<
        SearchPath, WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>
    > where NewTrigger.Root == Root {
        ForEach<
            SearchPath, WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>
        >(self.path) { actualPath -> WhenChanged<
            Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>
        > in
            WhenChanged<Path<SearchPath.Root, SearchPath.Value>, ConditionalTrigger<NewTrigger>>(
                actualPath: actualPath,
                trigger: ConditionalTrigger<NewTrigger>(
                    condition: condition, trigger: builder(self.builder(actualPath))
                )
            )
        }
    }

    /// Create a ``SyncTrigger``.
    /// - Parameter target: The target to update when this trigger fires.
    /// - Returns: The new trigger.
    /// - SeeAlso: ``SyncTrigger``.
    public func sync<TargetPath: SearchablePath>(
        target: TargetPath
    ) -> ForEach<SearchPath, SyncTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>> where
        TargetPath.Root == Root, TargetPath.Value == SearchPath.Value {
        ForEach<SearchPath, SyncTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>>(path) {
            SyncTrigger(source: $0, target: target)
        }
    }

    /// Create a ``SyncTrigger`` that enacts a transform.
    /// - Parameters:
    ///   - target: The target to update when the new trigger fires.
    ///   - transform: The transform applied to the source to create the target.
    /// - Returns: The new trigger.
    /// - SeeAlso: ``SyncTrigger``.
    public func sync<TargetPath: SearchablePath>(
        target: TargetPath,
        transform: @escaping (SearchPath.Value, TargetPath.Value) -> TargetPath.Value
    ) -> ForEach<
        SearchPath,
        SyncWithTransformTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>
    > where TargetPath.Root == Root {
        ForEach<
            SearchPath, SyncWithTransformTrigger<Path<SearchPath.Root, SearchPath.Value>, TargetPath>
        >(path) {
            SyncWithTransformTrigger(source: $0, target: target, transform: transform)
        }
    }

    /// Create a ``MakeAvailable`` trigger.
    /// - Parameters:
    ///   - field: The new field to make available.
    ///   - order: The order to place the new field in. (see ``MakeAvailable``).
    ///   - fields: A path to the fields array to mutate.
    ///   - attributes: A path to the attributes array to mutate.
    /// - Returns: The new trigger.
    /// - SeeAlso: ``MakeAvailable``.
    public func makeAvailable<FieldsPath: PathProtocol, AttributesPath: PathProtocol>(
        field: Field, after order: [String], fields: FieldsPath, attributes: AttributesPath
    ) -> ForEach<
        SearchPath,
        MakeAvailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath, AttributesPath>
    > where FieldsPath.Root == Root, FieldsPath.Value == [Field],
        AttributesPath.Value == [String: Attribute] {
        ForEach<
            SearchPath,
            MakeAvailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath, AttributesPath>
        >(path) {
            MakeAvailableTrigger(
                field: field, after: order, source: $0, fields: fields, attributes: attributes
            )
        }
    }

    /// Create a ``MakeUnavailable`` trigger.
    /// - Parameters:
    ///   - field: The field to remove.
    ///   - fields: A path to the fields array to mutate.
    /// - Returns: The new trigger.
    /// - SeeAlso: ``MakeUnavailable``.
    public func makeUnavailable<FieldsPath: PathProtocol>(
        field: Field, fields: FieldsPath
    ) -> ForEach<
        SearchPath, MakeUnavailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath>
    > where FieldsPath.Root == Root, FieldsPath.Value == [Field] {
        ForEach<
            SearchPath, MakeUnavailableTrigger<Path<SearchPath.Root, SearchPath.Value>, FieldsPath>
        >(path) {
            MakeUnavailableTrigger(field: field, source: $0, fields: fields)
        }
    }

}
