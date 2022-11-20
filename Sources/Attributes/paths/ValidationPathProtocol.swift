/*
 * ValidationPathProtocol.swift
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

/// Provides properties required to add a default `push` method.
internal protocol _PushValidator {

    /// The type of the path pointing to a value that needs validation.
    associatedtype PathType: ReadOnlyPathProtocol

    /// The path pointing to the value to be validated.
    var path: PathType { get }

}

/// Add default push method.
extension _PushValidator {

    /// Add a new validation onto the queue of existing validation methods.
    /// - Parameter f: The new validation method to perform in addition to the existing methods.
    /// - Returns: A new validator that contains the existing validation function and the new validation
    /// function `f`.
    public func push(_ f: @escaping (PathType.Root, PathType.Value) throws -> Void) -> Validator<PathType> {
        Validator(path, _validate: f)
    }

}

/// Performs a validator for values pointed to by a ``ReadOnlyPath``.
public protocol ValidationPathProtocol: ValidationPushProtocol {

    /// The type of the path pointing to a value that is to be validated.
    associatedtype PathType: ReadOnlyPathProtocol

    /// The `PushValidator` associatedType is a ``Validator``.
    associatedtype PushValidator = Validator<PathType>

    /// The path to the value required validation.
    var path: PathType { get }

    /// Initialise `Self` from the path to a value that requires validation.
    /// - Parameter path: The path pointing to the value to be verified.
    init(path: PathType)

}

/// Typealias for default implementation conformance.
internal typealias _ValidationPath = _PushValidator & ValidationPathProtocol
