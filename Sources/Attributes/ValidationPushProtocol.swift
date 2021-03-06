/*
 * ValidationPushProtocol.swift
 * Attributes
 *
 * Created by Callum McColl on 8/11/20.
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

public protocol ValidationPushProtocol: ReadOnlyPathContainer {
    
    associatedtype Root
    associatedtype Value
    associatedtype PushValidator: PathValidator
    
    func push(_ f: @escaping (Root, Value) throws -> Void) -> PushValidator
    
}

extension ValidationPushProtocol {

    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Root> then builder: @escaping () -> AnyValidator<Root>
    ) -> PushValidator {
        return push {
            if condition($1) {
                try builder().performValidation($0)
            }
        }
    }

    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Root> then builder1: @escaping () -> AnyValidator<Root>,
        @ValidatorBuilder<Root> else builder2: @escaping () -> AnyValidator<Root>
    ) -> PushValidator {
        return push {
            if condition($1) {
                try builder1().performValidation($0)
            } else {
                try builder2().performValidation($0)
            }
        }
    }

}

//extension ValidationPushProtocol where Value: Nilable {
//
//    public func ifNil(@ValidatorBuilder<Root> then builder: @escaping () -> [AnyValidator<Root>]) -> PushValidator {
//        return push {
//            if $1.isNil {
//                try AnyValidator(builder()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNil(
//        @ValidatorBuilder<Root> then builder1: @escaping () -> [AnyValidator<Root>],
//        @ValidatorBuilder<Root> else builder2: @escaping () -> [AnyValidator<Root>]
//    ) -> PushValidator {
//        return push {
//            if $1.isNil {
//                try AnyValidator(builder1()).performValidation($0)
//            } else {
//                try AnyValidator(builder2()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNotNil(@ValidatorBuilder<Root> then builder: @escaping () -> [AnyValidator<Root>]) -> PushValidator {
//        return push {
//            if !$1.isNil {
//                try AnyValidator(builder()).performValidation($0)
//            }
//        }
//    }
//
//    public func ifNotNil(
//        @ValidatorBuilder<Root> then builder1: @escaping () -> [AnyValidator<Root>],
//        @ValidatorBuilder<Root> else builder2: @escaping () -> [AnyValidator<Root>]
//    ) -> PushValidator {
//        return push {
//            if !$1.isNil {
//                try AnyValidator(builder1()).performValidation($0)
//            } else {
//                try AnyValidator(builder2()).performValidation($0)
//            }
//        }
//    }
//
//}


extension ValidationPushProtocol where Value: Equatable {
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence, S2: Sequence>(_ p: P, transform: @escaping (S) -> S2) -> PushValidator where P.Root == Root, P.Value == S, S2.Element == Value {
        return push { (root, value) in
            let collection = transform(root[keyPath: p.keyPath])
            if nil == collection.first(where: { $0 == value }) {
                throw ValidationError(message: "Must equal on of the following: '\(collection.map { "\($0)" }.joined(separator: ", "))'.", path: AnyPath(path))
            }
        }
    }
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> PushValidator where P.Root == Root, P.Value == S, S.Element == Value {
        return push { (root, value) in
            let collection = root[keyPath: p.keyPath]
            if nil == collection.first(where: { $0 == value }) {
                throw ValidationError(message: "Must equal on of the following: '\(collection.map { "\($0)" }.joined(separator: ", "))'.", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: Hashable {
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P, transform: @escaping (S) -> Set<Value>) -> PushValidator where P.Root == Root, P.Value == S {
        return push {
            let set = transform($0[keyPath: p.keyPath])
            if !set.contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(set.map { "\($0)" }.joined(separator: ", "))'.", path: path)
            }
        }
    }
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> PushValidator where P.Root == Root, P.Value == S, S.Element == Value {
        return push {
            let set = Set($0[keyPath: p.keyPath])
            if !set.contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(set.map { "\($0)" }.joined(separator: ", "))'.", path: path)
            }
        }
    }
    
    public func `in`<P: ReadOnlyPathProtocol>(_ p: P) -> PushValidator where P.Root == Root, P.Value == Set<Value> {
        return push {
            let set = $0[keyPath: p.keyPath]
            if !set.contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(set.map { "\($0)" }.joined(separator: ", "))'.", path: path)
            }
        }
    }
    
    public func `in`(_ set: Set<Value>) -> PushValidator {
        return push {
            if !set.contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(set)'.", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: Equatable {
    
    public func equals(_ value: Value) -> PushValidator {
        return push {
            if $1 != value {
                throw ValidationError(message: "Must equal \(value).", path: path)
            }
        }
    }
    
    public func notEquals(_ value: Value) -> PushValidator {
        return push {
            if $1 == value {
                throw ValidationError(message: "Must not equal \(value).", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value == Bool {
    
    public func equalsFalse() -> PushValidator {
        return self.equals(false)
    }
    
    public func equalsTrue() -> PushValidator {
        return self.equals(true)
    }
    
}

extension ValidationPushProtocol where Value: Comparable {
    
    public func between(min: Value, max: Value) -> PushValidator {
        return push {
            if $1 < min || $1 > max {
                throw ValidationError(message: "Must be between \(min) and \(max).", path: path)
            }
        }
    }
    
    public func lessThan(_ value: Value) -> PushValidator {
        return push {
            if $1 >= value {
                throw ValidationError(message: "Must be less than \(value).", path: path)
            }
        }
    }
    
    public func lessThanEqual(_ value: Value) -> PushValidator {
        return push {
            if $1 > value {
                throw ValidationError(message: "Must be less than or equal to \(value).", path: path)
            }
        }
    }
    
    public func greaterThan(_ value: Value) -> PushValidator {
        return push {
            if $1 <= value {
                throw ValidationError(message: "Must be greater than \(value).", path: path)
            }
        }
    }
    
    public func greaterThanEqual(_ value: Value) -> PushValidator {
        return push {
            if $1 < value {
                throw ValidationError(message: "Must be greater than or equal to \(value).", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: Collection {
    
    public func empty() -> PushValidator {
        return push {
            if !$1.isEmpty {
                throw ValidationError(message: "Must be empty.", path: path)
            }
        }
    }
    
    public func notEmpty() -> PushValidator {
        return push {
            if $1.isEmpty {
                throw ValidationError(message: "Cannot be empty.", path: path)
            }
        }
    }
    
    public func length(_ length: Int) -> PushValidator {
        if length == 0 {
            return empty()
        }
        return push {
            if $1.count != length {
                throw ValidationError(message: "Must have exactly \(length) elements.", path: path)
            }
        }
    }
    
    public func minLength(_ length: Int) -> PushValidator {
        if length == 1 {
            return notEmpty()
        }
        return push {
            if $1.count < length {
                throw ValidationError(message: "Must provide at least \(length) values.", path: path)
            }
        }
    }
    
    public func maxLength(_ length: Int) -> PushValidator {
        if length == 0 {
            return empty()
        }
        return push {
            if $1.count > length {
                throw ValidationError(message: "Must provide no more than \(length) values.", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: Sequence {
    
    public func unique<S: Sequence>(_ transform: @escaping (Value) -> S) -> PushValidator where S.Element: Hashable {
        return push { (_, value) in
            var set = Set<S.Element>()
            if nil != transform(value).first(where: {
                if set.contains($0) {
                    return true
                }
                set.insert($0)
                return false
            }) {
                throw ValidationError(message: "Must be unique", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: Sequence, Value.Element: Hashable {
    
    public func unique() -> PushValidator {
        return push { (_, value) in
            var set = Set<Value.Element>()
            if nil != value.first(where: {
                if set.contains($0) {
                    return true
                }
                set.insert($0)
                return false
            }) {
                throw ValidationError(message: "Must be unique", path: path)
            }
        }
    }
    
}

extension ValidationPushProtocol where Value: StringProtocol {
    
    public func alpha() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter }) {
                throw ValidationError(message: "Must be alphabetic.", path: path)
            }
        }
    }
    
    public func alphadash() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "-" }) {
                throw ValidationError(message: "Must be alphabetic with underscores and dashes allowed.", path: path)
            }
        }
    }
    
    public func alphafirst() -> PushValidator {
        return push {
            guard let firstChar = $1.first else {
                return
            }
            if !firstChar.isLetter {
                throw ValidationError(message: "First Character must be alphabetic.", path: path)
            }
        }
    }
    
    public func alphanumeric() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber }) {
                throw ValidationError(message: "Must be alphanumeric.", path: path)
            }
        }
    }
    
    public func alphaunderscore() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" }) {
                throw ValidationError(message: "Must be alphabetic with underscores allowed.", path: path)
            }
        }
    }
    
    public func alphaunderscorefirst() -> PushValidator {
        return push {
            guard let firstChar = $1.first else {
                return
            }
            if !(firstChar.isLetter || firstChar == "_") {
                throw ValidationError(message: "First Character must be alphabetic or an underscore.", path: path)
            }
        }
    }
    
    public func blacklist(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            if list.contains(String(val)) {
                throw ValidationError(message: "\(val) is a banned word.", path: path)
            }
        }
    }
    
    public func numeric() -> PushValidator {
        return push {
            if nil != $1.first(where: { !$0.isNumber }) {
                throw ValidationError(message: "Must be numeric.", path: path)
            }
        }
    }
    
    public func whitelist(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            if !list.contains(String(val)) {
                throw ValidationError(message: "\(val) is not valid, you must use pre-existing words. Candidates: \(list)", path: path)
            }
        }
    }
    
    public func greyList(_ list: Set<String>) -> PushValidator {
        return push { (_, val) in
            guard let _ = list.first(where: { val.contains($0) }) else {
                throw ValidationError(message: "\(val) is not valid, it must contain pre-existing words. Candidates: \(list)", path: path)
            }
        }
    }
    
}

