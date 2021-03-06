//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol SchemaProtocol {
    
    associatedtype Root: Modifiable
    
    var groups: [AnyGroup<Root>] { get }
    
    var trigger: AnyTrigger<Root> { get }
    
    func findProperty<Path: PathProtocol>(path: Path, in root: Root) -> SchemaAttribute where Path.Root == Root, Path.Value == Attribute
    
    func makeValidator(root: Root) -> AnyValidator<Root>
    
}

public extension SchemaProtocol {
    
    typealias Group<GroupType: GroupProtocol> = Attributes.Group<GroupType>
    
    var trigger: AnyTrigger<Root> {
        AnyTrigger(groups.map(\.allTriggers))
    }
    
    var groups: [AnyGroup<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = ($0.value as? ConvertibleToGroup)?.anyGroup as? AnyGroup<Root> {
                return val
            }
            return nil
        }
    }
    
    func findProperty<Path: PathProtocol>(path: Path, in root: Root) -> SchemaAttribute where Path.Root == Root, Path.Value == Attribute {
        guard let property = groups.compactMap({ $0.findProperty(path: AnyPath(path), in: root) }).first else {
            fatalError()
        }
        return property
    }
    
    func makeValidator(root: Root) -> AnyValidator<Root> {
        AnyValidator(groups.enumerated().map {
            let path = Root.path.attributes[$0]
            let propertiesValidator = ChainValidator(path: path, validator: $1.propertiesValidator)
            let groupValidator = ChainValidator(path: path, validator: $1.groupValidation)
            let rootValidator = $1.rootValidation
            return AnyValidator([AnyValidator([propertiesValidator, groupValidator]), rootValidator])
        })
    }
    
}

//struct VHDLSettings: GroupProtocol {
//
//    var path: Path<EmptyModifiable, AttributeGroup>
//
//    typealias Root = EmptyModifiable
//
//    @GroupBoolProperty(label: "is_suspensible", trigger: .makeAvailable(\.suspendedState))
//    var isSuspensible
//    
//    @GroupProperty(label: "suspended_state", available: false, type: .line)
//    var suspendedState
//
//}
//
//struct TestSchema: SchemaProtocol {
//
//    typealias Root = EmptyModifiable
//
//    @Group(VHDLSettings(path: EmptyModifiable.path.attributes[0]))
//    var settings
//
//}
