// MockFunctionCreator.swift 
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

/// A struct that helps with mocking functions.
struct MockFunctionCreator<T, U> {

    /// The times the function was called.
    var timesCalled: UInt = 0

    /// The parameters fed into the function.
    var parameters: T?

    /// The returned result from the function.
    var returns: U?

    /// The function to perform.
    var fn: (inout T) -> U

    /// Track a functions calls using this struct.
    /// - Parameter fn: The function to call.
    init(fn: @escaping (inout T) -> U) {
        self.fn = fn
    }

    /// Perform the function.
    /// - Parameter parameter: The parameters fed into the function.
    /// - Returns: The output from the function.
    mutating func perform(parameter: inout T) -> U {
        self.timesCalled += 1
        self.parameters = parameter
        let result = fn(&parameter)
        self.returns = result
        return result
    }

    /// Reset the tracking variables for a new function call.
    mutating func reset() {
        self.timesCalled = 0
        self.parameters = nil
        self.returns = nil
    }

    /// Test equality of function by checking behaviour.
    func isEqual(data: inout T, f: (inout T) -> U) -> Bool where T: Equatable, U: Equatable {
        let result = f(&data)
        return timesCalled == 1 && parameters == data && returns == result
    }

    /// Verifies that the function was called exactly once with input returning output.
    /// - Parameters:
    ///   - input: The input fed into the function.
    ///   - output: The output returns from the function.
    /// - Returns: A bool indicating that the function was called exactly once with the expected input
    ///            returning the expected output.
    func verify(input: T, output: U) -> Bool where T: Equatable, U: Equatable {
        input == parameters && output == returns && timesCalled == 1
    }

}
