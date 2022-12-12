/*
 * WhenChanged.swift
 * Attributes
 *
 * Created by Morgan McColl on 31/5/21.
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

/// A trigger that initiates another trigger when a specific value is changed. This
/// trigger will monitor a value through a path and initiate a trigger function when the
/// value changes.
public struct WhenChanged<
    Path: ReadOnlyPathProtocol, Trigger: TriggerProtocol
>: TriggerProtocol where Path.Root == Trigger.Root {

    /// The Root containing the value that is monitored.
    public typealias Root = Path.Root

    /// The path to the value that fires this trigger.
    private let actualPath: Path

    /// The trigger that is enacted when this trigger is fired.
    private let trigger: Trigger

    /// A type-erased version of `actualPath`.
    public var path: AnyPath<Root> {
        AnyPath(actualPath)
    }

    /// Initialise this trigger with a path to a monitored value and the trigger to
    /// use when that value changes.
    /// - Parameters:
    ///   - actualPath: A path to a value that causes this trigger to fire.
    ///   - trigger: The trigger enacted when this trigger fires.
    init(actualPath: Path, trigger: Trigger) {
        self.actualPath = actualPath
        self.trigger = trigger
    }

    /// Performs the trigger function within the `trigger` property.
    /// - Parameters:
    ///   - root: The root object.
    ///   - path: The path to the value within `root` that is causing this trigger
    /// to fire.
    /// - Returns: The result from the `trigger`'s `performTrigger` function.
    public func performTrigger(
        _ root: inout Path.Root, for path: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Path.Root>> {
        guard isTriggerForPath(path, in: root) else {
            return .success(false)
        }
        return trigger.performTrigger(&root, for: path)
    }

    /// Check whether a path causes this trigger to fire.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - _: Unused. Preserved for protocol conformance.
    /// - Returns: Whether `path` causes this trigger to fire.
    @inlinable
    public func isTriggerForPath(_ path: AnyPath<Path.Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}

/// Add common triggers.
extension WhenChanged where Trigger == IdentityTrigger<Path.Root> {

    /// Creates a trigger that is fired when a value changes. This trigger does nothing
    /// and will always succeed.
    /// - Parameter path: The path the causes this trigger to fire.
    /// - SeeAlso: ``IdentityTrigger``.
    public init(_ path: Path) {
        self.init(actualPath: path, trigger: IdentityTrigger())
    }

    /// Creates a trigger that performs many trigger functions created from a ``TriggerBuilder``. The newly
    /// created trigger will only fire when a condition is `true`.
    /// - Parameters:
    ///   - condition: The condition that causes the new trigger to fire.
    ///   - builder: The trigger functions that are performed by the new trigger.
    /// - Returns: The new trigger.
    public func when<NewTrigger: TriggerProtocol>(
        _ condition: @escaping (Root) -> Bool,
        @TriggerBuilder<Root> then builder: (WhenChanged<Path, Trigger>) -> NewTrigger
    ) -> WhenChanged<Path, ConditionalTrigger<NewTrigger>> where NewTrigger.Root == Root {
        WhenChanged<Path, ConditionalTrigger<NewTrigger>>(
            actualPath: actualPath,
            trigger: ConditionalTrigger(condition: condition, trigger: builder(self))
        )
    }

    /// Creates a ``SyncTrigger`` that updates a target path from the path stored in this trigger.
    /// - Parameter target: The target path to update.
    /// - Returns: A ``SyncTrigger`` that updated `target` from `self.actualPath`.
    /// - SeeAlso: ``SyncTrigger``.
    public func sync<TargetPath: SearchablePath>(
        target: TargetPath
    ) -> SyncTrigger<Path, TargetPath> where TargetPath.Root == Root, TargetPath.Value == Path.Value {
        SyncTrigger(source: actualPath, target: target)
    }

    /// Creates a ``SyncTrigger`` that update a target path from a the path stored in this trigger.
    /// In addition to this, the value located at `self.actualPath` is transformed using a
    /// transformation function.
    /// - Parameter target: The target to update.
    /// - Parameter transform: The transformation that transforms the value at `actualPath` to a new value
    /// in the target.
    /// - Returns: A new ``SyncTrigger``.
    /// - SeeAlso: ``SyncTrigger``.
    public func sync<TargetPath: SearchablePath>(
        target: TargetPath, transform: @escaping (Path.Value, TargetPath.Value) -> TargetPath.Value
    ) -> SyncWithTransformTrigger<Path, TargetPath> where TargetPath.Root == Root {
        SyncWithTransformTrigger(source: actualPath, target: target, transform: transform)
    }

    /// Creates a ``MakeAvailableTrigger`` with a source specified by this objects `actualPath`.
    /// - Parameters:
    ///   - field: The new field.
    ///   - order: The fields to place immediately after the new field.
    ///   - fields: A path to the fields property in the root object.
    ///   - attributes: A path to the attributes property in the root object.
    /// - Returns: A new ``MakeAvailableTrigger``.
    /// - SeeAlso: ``MakeAvailableTrigger``.
    public func makeAvailable<FieldsPath: PathProtocol, AttributesPath: PathProtocol>(
        field: Field, after order: [String], fields: FieldsPath, attributes: AttributesPath
    ) -> MakeAvailableTrigger<Path, FieldsPath, AttributesPath> where
        FieldsPath.Root == Root,
        FieldsPath.Value == [Field],
        AttributesPath.Value == [String: Attribute] {
        MakeAvailableTrigger(
            field: field, after: order, source: self.actualPath, fields: fields, attributes: attributes
        )
    }

    /// Create a ``MakeUnavailableTrigger`` with a source specified by this objects `actualPath`.
    /// - Parameters:
    ///   - field: The field to make unavailable.
    ///   - fields: A path to the fields property in the root object.
    /// - Returns: A new ``MakeUnavailableTrigger``.
    /// - SeeAlso: ``MakeUnavailableTrigger``.
    public func makeUnavailable<FieldsPath: PathProtocol>(
        field: Field, fields: FieldsPath
    ) -> MakeUnavailableTrigger<Path, FieldsPath> where FieldsPath.Root == Root, FieldsPath.Value == [Field] {
        MakeUnavailableTrigger(field: field, source: actualPath, fields: fields)
    }

    /// Creates a ``CustomTrigger`` that is triggered by changing the value located at `actualPath`.
    /// - Parameter trigger: The custom trigger function to enact when the new trigger fires.
    /// - Returns: A new ``CustomTrigger``.
    /// - SeeAlso: ``CustomTrigger``.
    public func custom(
        _ trigger: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>
    ) -> CustomTrigger<Path> {
        CustomTrigger(path: actualPath, trigger: trigger)
    }

}
