// TriggerProtocol.swift 
// Attributes 
// 
// Created by Morgan McColl on 30/5/21.
// Copyright © 2021 2022 Morgan McColl. All rights reserved.
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
