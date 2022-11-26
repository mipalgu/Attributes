// ValidationPushProtocol+StringRules.swift 
// Attributes 
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

/// Provide `String` validation methods.
extension ValidationPushProtocol where Value: StringProtocol {

    /// All characters must be alphabetic (a-z, A-Z).
    /// - Returns: A new validator that ensures all characters within a given string are alphabetic.
    /// - Note: Empty strings will pass validation.
    public func alpha() -> PushValidator {
        push {
            if $1.contains(where: { !$0.isLetter }) {
                throw ValidationError(message: "Must be alphabetic.", path: path)
            }
        }
    }

    /// All characters must be alphabetic (a-z, A-Z), numeric (0-9), underscores (_) or dashes (-).
    /// - Returns: A new validator that verifies a string only contains alphabetic, numeric, underscores
    /// or dash characters.
    public func alphadash() -> PushValidator {
        push {
            if $1.contains(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "-" }) {
                throw ValidationError(
                    message: "Must be alphabetic with underscores and dashes allowed.", path: path
                )
            }
        }
    }

    /// The first character in a string must be alphabetic (a-z, A-Z).
    /// - Returns: A new validator that ensures the first character is alphabetic.
    /// - Note: Empty strings will pass validation.
    public func alphafirst() -> PushValidator {
        push {
            guard let firstChar = $1.first else {
                return
            }
            if !firstChar.isLetter {
                throw ValidationError(message: "First Character must be alphabetic.", path: path)
            }
        }
    }

    /// All characters within a string must either be alphabetic (a-z, A-Z) or numeric (0-9).
    /// - Returns: A new validator that verifies that a string contains only alphabetic or
    /// numeric characters.
    /// - Note: Empty strings will pass validation.
    public func alphanumeric() -> PushValidator {
        push {
            if $1.contains(where: { !$0.isLetter && !$0.isNumber }) {
                throw ValidationError(message: "Must be alphanumeric.", path: path)
            }
        }
    }

    /// All characters within a string must be alphabetic (a-z, A-Z), numeric (0-9), or underscores (_).
    /// - Returns: A new validator that ensures all characters within a given string are alphabetic,
    /// numeric, or underscores.
    /// - Note: Empty strings will pass validation.
    public func alphaunderscore() -> PushValidator {
        push {
            if $1.contains(where: { !$0.isLetter && !$0.isNumber && $0 != "_" }) {
                throw ValidationError(message: "Must be alphabetic with underscores allowed.", path: path)
            }
        }
    }

    /// The first character in a given string must be alphabetic (a-z, A-Z) or an underscore (_).
    /// - Returns: A new validator that verifies that the first character in a given string is
    /// an alphabetic character or an underscore.
    /// - Note: Empty strings will pass validation.
    public func alphaunderscorefirst() -> PushValidator {
        push {
            guard let firstChar = $1.first else {
                return
            }
            if !(firstChar.isLetter || firstChar == "_") {
                throw ValidationError(
                    message: "First Character must be alphabetic or an underscore.", path: path
                )
            }
        }
    }

    /// All characters within a string must be numeric (0-9).
    /// - Returns: A new validator that ensures all characters within a string are numeric.
    /// - Note: Empty strings will pass validation.
    public func numeric() -> PushValidator {
        push {
            if $1.contains(where: { !$0.isNumber }) {
                throw ValidationError(message: "Must be numeric.", path: path)
            }
        }
    }

    /// Creates a new validator that checks whether a given string matches a banned word. If
    /// the string matches the banned word, then the validation will fail.
    /// - Parameter list: The list of banned words.
    /// - Returns: A new validator that ensures a given string is not equal to a banned word
    /// contained within `list`.
    public func blacklist(_ list: Set<String>) -> PushValidator {
        push { _, val in
            if list.contains(String(val)) {
                throw ValidationError(message: "\(val) is a banned word.", path: path)
            }
        }
    }

    /// Creates a new validator that ensures a given string exist within a list of allowed
    /// words.
    /// - Parameter list: The list of permissible words.
    /// - Returns: A new validator that verifies that a given string exist within `list`.
    public func whitelist(_ list: Set<String>) -> PushValidator {
        push { _, val in
            if !list.contains(String(val)) {
                throw ValidationError(
                    message: "\(val) is not valid, you must use pre-existing words. Candidates: \(list)",
                    path: path
                )
            }
        }
    }

    /// Verifies that a given string contain a substring that exists within a list of permissible
    /// words.
    /// - Parameter list: The list of permissible words.
    /// - Returns: A new validator that ensures a given string contains a substring existing within
    /// `list`.
    public func greyList(_ list: Set<String>) -> PushValidator {
        push { _, val in
            guard list.contains(where: { val.contains($0) }) else {
                throw ValidationError(
                    message: "\(val) is not valid, it must contain pre-existing words. Candidates: \(list)",
                    path: path
                )
            }
        }
    }

}
