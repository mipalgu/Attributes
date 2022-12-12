// AnyTrigger.swift 
// Attributes 
// 
// Created by Morgan McColl.
// Copyright © 2021 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
//

/// A Type-erased trigger.
public struct AnyTrigger<Root>: TriggerProtocol {

    /// The callback for performing the `isTriggerForPath` method.
    private let _isTriggerForPath: (AnyPath<Root>, Root) -> Bool

    /// The callback for performing the `performTrigger` method.
    private let _trigger: (inout Root, AnyPath<Root>) -> Result<Bool, AttributeError<Root>>

    /// Type-erase a trigger.
    /// - Parameter base: The trigger to type-erase.
    public init<Base: TriggerProtocol>(_ base: Base) where Base.Root == Root {
        self._isTriggerForPath = { base.isTriggerForPath($0, in: $1) }
        self._trigger = { base.performTrigger(&$0, for: $1) }
    }

    /// Create a type-erased trigger by using a trigger function and a search path. This initialiser
    /// will create a trigger that will perform the trigger function when a given path in the
    /// trigger function is a child of the `path` provided in this initialiser.
    /// - Parameters:
    ///   - path: A path to the value that contains children that will enable this trigger. Changing
    ///           all children of this path will cause the trigger function to fire.
    ///   - trigger: The trigger function to perform.
    public init<SearchPath: SearchablePath>(
        path: SearchPath,
        trigger: @escaping (inout Root, AnyPath<Root>) -> Result<Bool, AttributeError<Root>>
    ) where SearchPath.Root == Root {
        self._isTriggerForPath = { path.isAncestorOrSame(of: $0, in: $1) }
        self._trigger = trigger
    }

    /// Copy a type-erased trigger.
    /// - Parameter trigger: The trigger to copy.
    @inlinable
    public init(_ trigger: AnyTrigger<Root>) {
        self = trigger
    }

    /// Initialise a type-erased trigger from a ``TriggerBuilder``.
    /// - Parameter builder: The builder that creates the triggers used by this type-erased trigger.
    @inlinable
    public init(
        @TriggerBuilder<Root>
        builder: () -> AnyTrigger<Root>
    ) {
        self.init(builder())
    }

    /// Create a type-erased trigger from a sequence of typed triggers.
    /// - Parameter triggers: The triggers that will be used by this type-erased trigger.
    public init<S: Sequence, V: TriggerProtocol>(_ triggers: S) where S.Element == V, V.Root == Root {
        self._isTriggerForPath = { path, root in
            triggers.contains { $0.isTriggerForPath(path, in: root) }
        }
        self._trigger = { root, path in triggers.reduce(.success(false)) {
            let result = $1.performTrigger(&root, for: path)
            switch ($0, result) {
            case (.success(let leftValue), .success(let rightValue)):
                return .success(leftValue || rightValue)
            case (.failure, _):
                return $0
            case (_, .failure):
                return result
            }
        } }
    }

    /// Type-erased version of `isTriggerForPath`. This function determins if this trigger
    /// should fire for a given path.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - root: The object to perform the trigger function in.
    /// - Returns: Whether a trigger function should be enacted for a given path.
    public func isTriggerForPath(_ path: AnyPath<Root>, in root: Root) -> Bool {
        self._isTriggerForPath(path, root)
    }

    /// Type-erased version of `performTrigger`. This method performs the trigger functions
    /// of the typed triggers that this object was initialised from.
    /// - Parameters:
    ///   - root: The root object to perform the trigger in.
    ///   - path: The path to the value this trigger acts upon.
    /// - Returns: A `Result`` indicating whether the trigger was successful.
    public func performTrigger(_ root: inout Root, for path: AnyPath<Root>)
        -> Result<Bool, AttributeError<Root>> {
        _trigger(&root, path)
    }

}

/// `ExpressibleByArrayLiteral` conformance.
extension AnyTrigger: ExpressibleByArrayLiteral {

    /// The element is more type-erased triggers.
    public typealias ArrayLiteralElement = AnyTrigger<Root>

    /// Initialise this trigger from a variadic list of other type-erased triggers.
    /// - Parameter triggers: The triggers used by this type-erased trigger.
    @inlinable
    public init(arrayLiteral triggers: ArrayLiteralElement...) {
        self.init(triggers)
    }

}
