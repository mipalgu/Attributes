//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol GroupProtocol: Attributable where AttributeRoot == AttributeGroup {
    
    @TriggerBuilder<AttributeRoot>
    var triggers: AnyTrigger<AttributeRoot> { get }
    
    @ValidatorBuilder<AttributeRoot>
    var extraValidation: AnyValidator<AttributeRoot> { get }
    
}

public extension GroupProtocol {
    
    var pathToAttributes: Path<AttributeGroup, [String: Attribute]> {
        Path<AttributeGroup, AttributeGroup>(path: \.self, ancestors: []).attributes
    }
    
}
