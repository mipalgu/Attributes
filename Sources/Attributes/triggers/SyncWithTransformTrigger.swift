//
//  File.swift
//  File
//
//  Created by Morgan McColl on 24/7/21.
//

import Foundation

public struct SyncWithTransformTrigger<Source: PathProtocol, Target: SearchablePath>: TriggerProtocol where Source.Root == Target.Root {
    
    public typealias Root = Source.Root
    
    public var path: AnyPath<Root> {
        AnyPath(source)
    }
    
    let source: Source
    
    let target: Target
    
    let transform: (Source.Value, Target.Value) -> Target.Value
    
    public init(source: Source, target: Target, transform: @escaping (Source.Value, Target.Value) -> Target.Value) {
        self.source = source
        self.target = target
        self.transform = transform
    }
    
    public func performTrigger(_ root: inout Source.Root, for _: AnyPath<Root>) -> Result<Bool, AttributeError<Source.Root>> {
        for path in target.paths(in: root) {
            guard !path.isNil(root) else {
                return .failure(AttributeError(message: "Tried to trigger update to nil path", path: path))
            }
            root[keyPath: path.path] = transform(root[keyPath: source.keyPath], root[keyPath: path.keyPath])
        }
        return .success(true)
    }
    
    public func isTriggerForPath(_ path: AnyPath<Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }
    
}
