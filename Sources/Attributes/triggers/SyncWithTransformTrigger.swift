//
//  File.swift
//  File
//
//  Created by Morgan McColl on 24/7/21.
//

import Foundation

/// A trigger that overwrites a target value from a source value by using a transformation function.
/// This trigger will be enacted when the source value changes. Once the source value is changed,
/// this trigger will fire causing an update in the target value by using the transform function.
public struct SyncWithTransformTrigger<
    Source: PathProtocol, Target: SearchablePath
>: TriggerProtocol where Source.Root == Target.Root {

    /// The Root of the paths in this trigger..
    public typealias Root = Source.Root

    /// A type-erased path to the source value.
    public var path: AnyPath<Root> {
        AnyPath(source)
    }

    /// A path to the source value existing in `Root`.
    let source: Source

    /// A path to the target value existing in `Root`.
    let target: Target

    /// A transformation function that converts a `Source` value into a `Target` value.
    let transform: (Source.Value, Target.Value) -> Target.Value

    /// Initialise this trigger with path to the source & target. and a transformation function.
    /// - Parameters:
    ///   - source: The source value that will cause this trigger to fire.
    ///   - target: The target value which will be mutated by this trigger.
    ///   - transform: The transform function that converts the `source` value into a `target` value.
    public init(
        source: Source, target: Target, transform: @escaping (Source.Value, Target.Value) -> Target.Value
    ) {
        self.source = source
        self.target = target
        self.transform = transform
    }

    /// Converts a source value contained within `root`` into a new target value. This new target
    /// value then mutates `root` and updates the property pointed to by `target`.
    /// - Parameters:
    ///   - root: The root object containing the `source` and `target` properties.
    /// - Returns: Whether the trigger was successful. The bool in the success case will indicate
    /// that the values were mutated. The failure case will contain the error that occurred.
    public func performTrigger(
        _ root: inout Source.Root, for _: AnyPath<Root>
    ) -> Result<Bool, AttributeError<Source.Root>> {
        for path in target.paths(in: root) {
            guard !path.isNil(root) else {
                return .failure(AttributeError(message: "Tried to trigger update to nil path", path: path))
            }
            root[keyPath: path.path] = transform(root[keyPath: source.keyPath], root[keyPath: path.keyPath])
        }
        return .success(true)
    }

    /// Determins if a given path will cause this trigger to fire.
    /// - Parameters:
    ///   - path: The path to check.
    /// - Returns: Whether `path` will cause this trigger to fire.
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }

}
