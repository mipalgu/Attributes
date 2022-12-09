/*
 * ComplexProtocol.swift
 * Attributes
 *
 * Created by Callum McColl on 12/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

/// A protocol for defining an ``Attributable`` that represents data using a `complex`
/// ``Attribute``. This protocol allows a cleaner implementation by providing default
/// paths to the respective complex data (both fields and values). To implement
/// this protocol, the user need only provide a container that stores the data
/// and the path to the complex attribute stored within it by setting the
/// `path` property of the conforming type. Once these paths are set up, the user
/// must provide the properties within the complex attribute as local properties
/// of the conforming type using the property wrappers for the respective attributes.
/// 
/// Consider a `Person` whom is representeed as a *complex attribute*. A person may contain
/// 3 properties - namely *first_name*, *last_name*, and *age*. You may conform this *Person*
/// to this protocol by adopting the structure below.
/// ```swift
/// struct Person: ComplexProtocol {
///
///     typealias Root = EmptyModifiable 
/// 
///     let path = Path(EmptyModifiable.self).attributes[0].attributes["person"].wrappedValue
/// 
///     var data: EmptyModifiable
/// 
///     @LineProperty(label: "first_name")
///     var firstName
/// 
///     @LineProperty(label: "last_name")
///     var lastName
/// 
///     @IntegerProperty(label: "age")
///     var age
/// 
/// }
/// ```
/// Note that the `Person` struct is using an ``EmptyModifiable`` to store it's data in the *person*
/// attribute. Each of the properties are defined with default validation and triggers as not to complicate
/// this small example. In summary, the struct above denotes a *Person* as a *complex attribute* that
/// contains two line attributes (*first_name* & *last_name), and an integer attribute (*age*).
public protocol ComplexProtocol: Attributable where AttributeRoot == Attribute {

    /// All of the triggers for each attribute contained within this complex.
    var triggers: AnyTrigger<Root> { get }

    /// The validators for the attributes contained within this complex.
    @ValidatorBuilder<Attribute>
    var groupValidation: AnyValidator<AttributeRoot> { get }

    ///  The validator for the root object that contains the complex attribute.
    @ValidatorBuilder<Root>
    var rootValidation: AnyValidator<Root> { get }

}

/// Default implementations.
public extension ComplexProtocol {

    /// The path to the complex attributes fields.
    var pathToFields: Path<Attribute, [Field]> {
        Path<Attribute, Attribute>(path: \.self, ancestors: []).blockAttribute.complexFields
    }

    /// The path to the complex attributes values.
    var pathToAttributes: Path<Attribute, [String: Attribute]> {
        Path<Attribute, Attribute>(path: \.self, ancestors: []).blockAttribute.complexValue
    }

}
