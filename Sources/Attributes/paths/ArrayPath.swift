/*
 * ArrayPath.swift
 * Attributes
 *
 * Created by Callum McColl on 4/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation

/// Add subscript.
extension ReadOnlyPathProtocol where Value: Collection, Value.Index: BinaryInteger {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> ReadOnlyPath<Root, Value.Element> {
        ReadOnlyPath<Root, Value.Element>(
            keyPath: self.keyPath.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            self.isNil(root) || index < 0 || root[keyPath: keyPath].count <= index
        }
    }

}

/// Add subscript.
extension ReadOnlyPathProtocol where Value: MutableCollection, Value.Index: BinaryInteger {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> ReadOnlyPath<Root, Value.Element> {
        ReadOnlyPath<Root, Value.Element>(
            keyPath: self.keyPath.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            self.isNil(root) || index < 0 || root[keyPath: keyPath].count <= index
        }
    }

}

/// Add subscript for dictionary access.
extension ReadOnlyPath where Value: DictionaryProtocol {

    /// Creates a new path to the value located at `key` in the dictionary.
    public subscript(key: Value.Key) -> ReadOnlyPath<Root, Value.Value?> {
        ReadOnlyPath<Root, Value.Value?>(
            keyPath: self.keyPath.appending(path: \.[key]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            self.isNil(root) || root[keyPath: keyPath][key].isNil
        }
    }

}

/// Add subscript.
extension ReadOnlyPathProtocol where Value: Collection, Value.Index: BinaryInteger, Value.Element: Nilable {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> ReadOnlyPath<Root, Value.Element> {
        ReadOnlyPath<Root, Value.Element>(
            keyPath: self.keyPath.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            guard index >= 0, !self.isNil(root) else {
                return true
            }
            let collection = root[keyPath: keyPath]
            guard collection.count > index else {
                return true
            }
            return collection[index].isNil
        }
    }

}

/// Add subscript.
extension ReadOnlyPathProtocol where
    Value: MutableCollection, Value.Index: BinaryInteger, Value.Element: Nilable {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> ReadOnlyPath<Root, Value.Element> {
        ReadOnlyPath<Root, Value.Element>(
            keyPath: self.keyPath.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            guard index >= 0, !self.isNil(root) else {
                return true
            }
            let collection = root[keyPath: keyPath]
            guard collection.count > index else {
                return true
            }
            return collection[index].isNil
        }
    }

}

/// Add subscript.
extension PathProtocol where Value: MutableCollection, Value.Index: BinaryInteger {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> Path<Root, Value.Element> {
        Path<Root, Value.Element>(
            path: self.path.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            self.isNil(root) || index < 0 || root[keyPath: self.path].count <= index
        }
    }

}

/// Add subscript.
extension PathProtocol where Value: MutableCollection, Value.Index: BinaryInteger, Value.Element: Nilable {

    /// Creates a new path to the value located at `index` in the collection.
    public subscript(index: Value.Index) -> Path<Root, Value.Element> {
        Path<Root, Value.Element>(
            path: self.path.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            guard index >= 0, !self.isNil(root) else {
                return true
            }
            let collection = root[keyPath: keyPath]
            guard collection.count > index else {
                return true
            }
            return collection[index].isNil
        }
    }

}

/// Add subscript for dictionary access.
extension PathProtocol where Value: DictionaryProtocol {

    /// Creates a new path to the value located at `key` in the dictionary.
    public subscript(key: Value.Key) -> Path<Root, Value.Value?> {
        Path<Root, Value.Value?>(
            path: self.path.appending(path: \.[key]),
            ancestors: self.ancestors + [AnyPath(self)]
        ) { root in
            self.isNil(root) || root[keyPath: keyPath][key].isNil
        }
    }

}

/// Add each method.
extension Path where Value: MutableCollection, Value.Index: Hashable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection.
    /// - Parameter f: A function to transform the path.
    /// - Returns: An array of transformed paths.
    @inlinable
    public func each<T>(_ f: @escaping (Value.Index, Path<Root, Value.Element>) -> T) -> (Root) -> [T] {
        { root in
            root[keyPath: self.path].indices.map {
                f($0, self[$0])
            }
        }
    }

}

/// Add each method.
extension Path where Value: MutableCollection, Value.Index: Hashable, Value.Element: Nilable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection.
    /// - Parameter f: A function to transform the path.
    /// - Returns: An array of transformed paths.
    @inlinable
    public func each<T>(_ f: @escaping (Value.Index, Path<Root, Value.Element>) -> T) -> (Root) -> [T] {
        { root in
            root[keyPath: self.path].indices.map {
                f($0, self[$0])
            }
        }
    }

}

/// Add each method.
extension ValidationPath where P.Value: Collection, P.Value.Index: Hashable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection. This
    /// allows the chaining of validators for each element in a collection.
    /// - Parameter builder: The validators to apply to each element.
    /// - Returns: A single validator that will perform the validators in `builder` to each element.
    public func each(
        @ValidatorBuilder<Root> builder: @escaping (
            Value.Index,
            ValidationPath<ReadOnlyPath<Root, Value.Element>>
        ) -> AnyValidator<Root>
    ) -> PushValidator {
        push { root, value in
            let validators: [AnyValidator<Root>] = value.indices.map { index -> AnyValidator<Root> in
                builder(
                    index,
                    ValidationPath<ReadOnlyPath<Root, Value.Element>>(
                        path: ReadOnlyPath<Root, Value.Element>(
                            keyPath: self.path.keyPath.appending(path: \.[index]),
                            ancestors: self.path.fullPath
                        )
                    )
                )
            }
            return try AnyValidator(validators).performValidation(root)
        }
    }

}

/// Add each method.
extension ValidationPath where P.Value: MutableCollection, P.Value.Index: Hashable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection. This
    /// allows the chaining of validators for each element in a collection.
    /// - Parameter builder: The validators to apply to each element.
    /// - Returns: A single validator that will perform the validators in `builder` to each element.
    public func each(
        @ValidatorBuilder<Root> builder: @escaping (
            Value.Index,
            ValidationPath<ReadOnlyPath<Root, Value.Element>>
        ) -> AnyValidator<Root>
    ) -> PushValidator {
        push { root, value in
            let validators: [AnyValidator<Root>] = value.indices.map { index -> AnyValidator<Root> in
                builder(
                    index,
                    ValidationPath<ReadOnlyPath<Root, Value.Element>>(
                        path: ReadOnlyPath<Root, Value.Element>(
                            keyPath: self.path.keyPath.appending(path: \.[index]),
                            ancestors: self.path.fullPath
                        )
                    )
                )
            }
            return try AnyValidator(validators).performValidation(root)
        }
    }

}

/// Add each method.
extension ValidationPath where P.Value: Collection, P.Value.Index: Hashable, P.Value.Element: Nilable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection. This
    /// allows the chaining of validators for each element in a collection.
    /// - Parameter builder: The validators to apply to each element.
    /// - Returns: A single validator that will perform the validators in `builder` to each element.
    public func each(
        @ValidatorBuilder<Root> builder: @escaping (
            Value.Index,
            ValidationPath<ReadOnlyPath<Root, Value.Element>>
        ) -> AnyValidator<Root>
    ) -> PushValidator {
        push { root, value in
            let validators: [AnyValidator<Root>] = value.indices.map { index -> AnyValidator<Root> in
                builder(
                    index,
                    ValidationPath<ReadOnlyPath<Root, Value.Element>>(
                        path: ReadOnlyPath<Root, Value.Element>(
                            keyPath: self.path.keyPath.appending(path: \.[index]),
                            ancestors: self.path.fullPath
                        )
                    )
                )
            }
            return try AnyValidator(validators).performValidation(root)
        }
    }

}

/// Add each method.
extension ValidationPath where P.Value: MutableCollection, P.Value.Index: Hashable, P.Value.Element: Nilable {

    /// Allows the use of a `map` mechanism accross the paths to each element in the root collection. This
    /// allows the chaining of validators for each element in a collection.
    /// - Parameter builder: The validators to apply to each element.
    /// - Returns: A single validator that will perform the validators in `builder` to each element.
    public func each(
        @ValidatorBuilder<Root> builder: @escaping (
            Value.Index,
            ValidationPath<ReadOnlyPath<Root, Value.Element>>
        ) -> AnyValidator<Root>
    ) -> PushValidator {
        push { root, value in
            let validators: [AnyValidator<Root>] = value.indices.map { index -> AnyValidator<Root> in
                builder(
                    index,
                    ValidationPath<ReadOnlyPath<Root, Value.Element>>(
                        path: ReadOnlyPath<Root, Value.Element>(
                            keyPath: self.path.keyPath.appending(path: \.[index]),
                            ancestors: self.path.fullPath
                        )
                    )
                )
            }
            return try AnyValidator(validators).performValidation(root)
        }
    }

}
