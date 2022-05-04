//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

protocol ConvertibleToGroup {

    var anyGroup: Any { get }

}

@propertyWrapper
public struct Group<GroupType: GroupProtocol>: ConvertibleToGroup {

    public var projectedValue: Group<GroupType> { self }

    public var wrappedValue: GroupType

    public var anyGroup: Any {
        return AnyGroup<GroupType.Root>(wrappedValue)
    }

    public init(wrappedValue group: GroupType) {
        self.wrappedValue = group
    }

}
