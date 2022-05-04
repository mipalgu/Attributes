//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol GroupProtocol: Attributable where AttributeRoot == AttributeGroup {

    var triggers: AnyTrigger<Root> { get }

    @ValidatorBuilder<AttributeGroup>
    var groupValidation: AnyValidator<AttributeRoot> { get }

    @ValidatorBuilder<Root>
    var rootValidation: AnyValidator<Root> { get }

}

public extension GroupProtocol {

    var pathToFields: Path<AttributeGroup, [Field]> {
        Path<AttributeGroup, AttributeGroup>(path: \.self, ancestors: []).fields
    }

    var pathToAttributes: Path<AttributeGroup, [String: Attribute]> {
        Path<AttributeGroup, AttributeGroup>(path: \.self, ancestors: []).attributes
    }

}
