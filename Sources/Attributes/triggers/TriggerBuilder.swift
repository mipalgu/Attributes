/*
 * SyncWithTransformTrigger.swift
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

// swiftlint:disable type_body_length

/// A `resultBuilder` for defining multiple Triggers.
@resultBuilder
public struct TriggerBuilder<Root> {

    /// Build a Trigger.
    public static func buildBlock<V0: TriggerProtocol>(_ v0: V0) -> V0 where V0.Root == Root {
        v0
    }

    /// Build a Trigger.
    public static func buildBlock<V0: TriggerProtocol, V1: TriggerProtocol>(_ v0: V0, _ v1: V1)
        -> AnyTrigger<Root> where V0.Root == Root, V1.Root == Root {
        AnyTrigger([AnyTrigger(v0), AnyTrigger(v1)])
    }

    /// Build a Trigger.
    public static func buildBlock<V0: TriggerProtocol, V1: TriggerProtocol, V2: TriggerProtocol>
    (
        _ v0: V0,
        _ v1: V1,
        _ v2: V2
    )
        -> AnyTrigger<Root> where V0.Root == Root, V1.Root == Root, V2.Root == Root {
        AnyTrigger([AnyTrigger(v0), AnyTrigger(v1), AnyTrigger(v2)])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol
    >(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root {
        AnyTrigger([AnyTrigger(v0), AnyTrigger(v1), AnyTrigger(v2), AnyTrigger(v3)])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol
    >(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4)
        ])
    }

    // swiftlint:disable function_parameter_count

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol
    >(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol
    >(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol,
        V7: TriggerProtocol
    >(
        _ v0: V0,
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6,
        _ v7: V7
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6),
            AnyTrigger(v7)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol,
        V7: TriggerProtocol,
        V8: TriggerProtocol
    >(
        _ v0: V0,
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6,
        _ v7: V7,
        _ v8: V8
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6),
            AnyTrigger(v7),
            AnyTrigger(v8)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol,
        V7: TriggerProtocol,
        V8: TriggerProtocol,
        V9: TriggerProtocol
    >(
        _ v0: V0,
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6,
        _ v7: V7,
        _ v8: V8,
        _ v9: V9
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6),
            AnyTrigger(v7),
            AnyTrigger(v8),
            AnyTrigger(v9)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol,
        V7: TriggerProtocol,
        V8: TriggerProtocol,
        V9: TriggerProtocol,
        V10: TriggerProtocol
    >(
        _ v0: V0,
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6,
        _ v7: V7,
        _ v8: V8,
        _ v9: V9,
        _ v10: V10
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root,
        V10.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6),
            AnyTrigger(v7),
            AnyTrigger(v8),
            AnyTrigger(v9),
            AnyTrigger(v10)
        ])
    }

    /// Build a Trigger.
    public static func buildBlock<
        V0: TriggerProtocol,
        V1: TriggerProtocol,
        V2: TriggerProtocol,
        V3: TriggerProtocol,
        V4: TriggerProtocol,
        V5: TriggerProtocol,
        V6: TriggerProtocol,
        V7: TriggerProtocol,
        V8: TriggerProtocol,
        V9: TriggerProtocol,
        V10: TriggerProtocol,
        V11: TriggerProtocol
    >(
        _ v0: V0,
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6,
        _ v7: V7,
        _ v8: V8,
        _ v9: V9,
        _ v10: V10,
        _ v11: V11
    ) -> AnyTrigger<Root> where
        V0.Root == Root,
        V1.Root == Root,
        V2.Root == Root,
        V3.Root == Root,
        V4.Root == Root,
        V5.Root == Root,
        V6.Root == Root,
        V7.Root == Root,
        V8.Root == Root,
        V9.Root == Root,
        V10.Root == Root,
        V11.Root == Root {
        AnyTrigger([
            AnyTrigger(v0),
            AnyTrigger(v1),
            AnyTrigger(v2),
            AnyTrigger(v3),
            AnyTrigger(v4),
            AnyTrigger(v5),
            AnyTrigger(v6),
            AnyTrigger(v7),
            AnyTrigger(v8),
            AnyTrigger(v9),
            AnyTrigger(v10),
            AnyTrigger(v11)
        ])
    }

    // swiftlint:enable function_parameter_count

    /// Create a single trigger by collapsing an array of trigger created in a ``TriggerBuilder``.
    /// - Parameter content: The builder creating the triggers.
    /// - Returns: A single trigger that performs all trigger functions generated by `content`.
    public func makeTrigger<Trigger: TriggerProtocol>(@TriggerBuilder _ content: () -> [Trigger])
        -> AnyTrigger<Root> where Trigger.Root == Root {
        AnyTrigger(content())
    }

    /// Make a trigger by collapsing trigger created in a ``TriggerBuilder``.
    /// - Parameter content: The builder generating the triggers.
    /// - Returns: A single representing the triggers created in the `content` function.
    public func makeTrigger<Trigger: TriggerProtocol>(@TriggerBuilder _ content: () -> Trigger)
        -> Trigger where Trigger.Root == Root {
        content()
    }

    /// Builds a trigger that performs no functions and always succeeds.
    func buildBlock() -> AnyTrigger<Root> { [] }

}

// swiftlint:enable type_body_length
