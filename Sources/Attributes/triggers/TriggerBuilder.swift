//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

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
