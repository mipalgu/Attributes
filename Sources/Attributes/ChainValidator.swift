//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation

struct ChainValidator<Path: ReadOnlyPathProtocol, Validator: ValidatorProtocol>: ValidatorProtocol where Path.Value == Validator.Root {

    var path: Path

    var validator: Validator

    init(path: Path, validator: Validator) {
        self.path = path
        self.validator = validator
    }

    func performValidation(_ root: Path.Root) throws {
      let value = root[keyPath: path.keyPath]
      do {
          try validator.performValidation(value)
      } catch let e as AttributeError<Validator.Root> {
          throw AttributeError(message: e.message, path: AnyPath(path).appending(e.path)!)
      }
    }

}
