//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

//var path: Path<Root, AttributeGroup> { get }
//
//var properties: [SchemaProperty<AttributeGroup>] { get }
//
//var propertiesValidator: AnyValidator<AttributeGroup> { get }
//
//@ValidatorBuilder<Root>
//var extraValidation: [AnyValidator<Root>] { get }

public struct AnyGroup<Root: Modifiable> {
    
    private let _path: () -> AnySearchablePath<Root, AttributeGroup>
    
    private let _pathToFields: () -> Path<AttributeGroup, [Field]>
    
    private let _pathToAttributes: () -> Path<AttributeGroup, [String : Attribute]>
    
    private let _properties: () -> [SchemaAttribute]
    
    private let _propertiesValidator: () -> AnyValidator<AttributeGroup>
    
    private let _triggers: () -> AnyTrigger<Root>
    
    private let _groupValidation: () -> AnyValidator<AttributeGroup>
    
    private let _rootValidation: () -> AnyValidator<Root>
    
    private let _findProperty: (AnyPath<Root>, Root) -> SchemaAttribute?
    
    let base: Any
    
    public var path: AnySearchablePath<Root, AttributeGroup> {
        _path()
    }
    
    public var pathToFields: Path<AttributeGroup, [Field]> {
        _pathToFields()
    }
    
    public var pathToAttributes: Path<AttributeGroup, [String : Attribute]> {
        _pathToAttributes()
    }
    
    public var properties: [SchemaAttribute] {
        _properties()
    }
    
    public var propertiesValidator: AnyValidator<AttributeGroup> {
        self._propertiesValidator()
    }
    
    public var triggers: AnyTrigger<Root> {
        self._triggers()
    }
    
    public var groupValidation: AnyValidator<AttributeGroup> {
        return self._groupValidation()
    }
    
    public var rootValidation: AnyValidator<Root> {
        return self._rootValidation()
    }
    
    public init<Base: GroupProtocol>(_ base: Base) where Base.Root == Root {
        self._path = { AnySearchablePath(base.path) }
        self._pathToFields = { base.pathToFields }
        self._pathToAttributes = { base.pathToAttributes }
        self._properties = { base.properties }
        self._propertiesValidator = { base.propertiesValidator }
        self._triggers = { base.triggers }
        self._groupValidation = { base.groupValidation }
        self._rootValidation = { base.rootValidation }
        self._findProperty = { base.findProperty(path: $0, in: $1) }
        self.base = base
    }
    
    func findProperty(path: AnyPath<Root>, in root: Root) -> SchemaAttribute? {
        self._findProperty(path, root)
    }
    
}
