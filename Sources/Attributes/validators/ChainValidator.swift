//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation

/// A validator for chaining together a Path to a Root and a validator that validates a value in that
/// root. This validator allows additional validation of any children existing inside a paths value
/// that are not pointed to by that path.
@usableFromInline
struct ChainValidator<Path: ReadOnlyPathProtocol, Validator: ValidatorProtocol>: ValidatorProtocol where
    Path.Value == Validator.Root {

    /// The path to the root object being validated.
    @usableFromInline var path: Path

    /// A validator that validates a value in the root object.
    @usableFromInline var validator: Validator

    /// Create a ChainValidator with a path and validator. This init takes a path that points
    /// to a root object that the validator then acts upon.
    /// - Parameters:
    ///   - path: A path to the root object of the validator.
    ///   - validator: The validator that acts on the root object to validate some value.
    @inlinable
    init(path: Path, validator: Validator) {
        self.path = path
        self.validator = validator
    }

    /// Perform the validation of a root object pointed to by path.
    /// - Parameter root: The parent object containing the object that is to be validated.
    /// - Throws: Throws an AttributeError when the validation is unsusccessful.
    @inlinable
    func performValidation(_ root: Path.Root) throws {
        guard !path.isNil(root) else {
            throw AttributeError(message: "Path is nil!", path: path)
        }
        let value = root[keyPath: path.keyPath]
        do {
            try validator.performValidation(value)
        } catch let e as AttributeError<Validator.Root> {
            // swiftlint:disable:next force_unwrapping
            throw AttributeError(message: e.message, path: AnyPath(path).appending(e.path)!)
        }
    }

}
