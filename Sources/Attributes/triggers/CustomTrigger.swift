/*
 * CustomTrigger.swift
 * triggers
 *
 * Created by Callum McColl on 6/9/21.
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

/// A trigger that can be customised to perform a function when triggered.
public struct CustomTrigger<Path: ReadOnlyPathProtocol>: TriggerProtocol {

    /// The root of the trigger is equal to the path root.
    public typealias Root = Path.Root

    /// An AnyPath representation of the actualPath.
    public var path: AnyPath<Root> {
        AnyPath(actualPath)
    }

    /// The path to the object containing the property that triggers the actions of this trigger.
    private let actualPath: Path

    /// The trigger function which is enacted when this trigger fires.
    private let trigger: (inout Root) -> Result<Bool, AttributeError<Root>>

    /// Create a custom trigger for a given path and executing a custom trigger function.
    /// - Parameters:
    ///   - path: A path to a property that causes this trigger to fire when changed.
    ///   - trigger: The trigger function that is executed when this trigger fires.
    public init(path: Path, trigger: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>) {
        self.actualPath = path
        self.trigger = trigger
    }

    /// Execute the trigger function when the property in root pointed to by path changes.
    /// - Parameters:
    ///   - root: The root object containing the property.
    ///   - path: The path of the property within root.
    /// - Returns: The output of the trigger function if the path to the property is valid, .success(false)
    ///            otherwise.
    public func performTrigger(
        _ root: inout Root, for path: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Root>> {
        if !isTriggerForPath(path, in: root) {
            return .success(false)
        }
        return trigger(&root)
    }

    /// Check if a path triggers this object.
    /// - Parameters:
    ///   - path: The path to a property that may trigger this object.
    ///   - root: The root object containing the property pointed to by path.
    /// - Returns: Whether this trigger fires from path.
    public func isTriggerForPath(_ path: AnyPath<Root>, in root: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
