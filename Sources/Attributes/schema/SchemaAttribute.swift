//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

/// SchemaAttribute defines a label, type, and validation rules for an Attribute.
public struct SchemaAttribute {

    /// The label for this attribute.
    public var label: String

    /// The type of this attribute.
    public var type: AttributeType

    /// The validation rules associated with this attribute.
    public var validate: AnyValidator<Attribute>

    /// Data initialisation.
    /// - Parameters:
    ///   - label: The label for this attribute.
    ///   - type: The type of this attribute.
    ///   - validate: The validator for this attribute.
    @inlinable
    public init(label: String, type: AttributeType, validate: AnyValidator<Attribute> = AnyValidator()) {
        self.label = label
        self.type = type
        self.validate = validate
    }

}
