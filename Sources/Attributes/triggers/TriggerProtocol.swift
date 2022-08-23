//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

/// Trigger definition. A Trigger represent a type that performs some function in response to an event
/// that occurs in some other part of the system. The Trigger contains a `performTrigger` function 
/// that mutates a root object. Different Trigger may perform different actions by implementing
/// the `performTrigger` method in different ways. The TriggerProtocol also requires a helper
/// method called `isTriggerForPath` that allows querying of whether a trigger is enacted
/// when a variable changes (as represented with a `Path`).
public protocol TriggerProtocol {

    /// The root object that this trigger acts upon.
    associatedtype Root

    /// Perform the trigger function in a root object.
    /// - Parameters:
    ///   - root: The root object affected by the trigger.
    ///   - path: The path that made the trigger fire. This path may be used to influence the behaviour
    ///           of the trigger.
    /// - Returns: A result indicating that the trigger was successfully enacted, or an error. The success
    ///            case of the result will contain a boolean value indicating that the trigger caused a
    ///            change that will require a view to redraw.
    func performTrigger(_ root: inout Root, for path: AnyPath<Root>) -> Result<Bool, AttributeError<Root>>

    /// Check whether the trigger acts on an object specified by path.
    /// - Parameters:
    ///   - path: The path to check.
    ///   - root: The object containing the property pointed to by path.
    /// - Returns: True if the trigger is fired by the path, or false otherwise.
    func isTriggerForPath(_ path: AnyPath<Root>, in root: Root) -> Bool

}
