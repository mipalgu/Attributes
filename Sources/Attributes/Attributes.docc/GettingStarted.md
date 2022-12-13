# Getting Started

This guide provides an overview of the Attributes package regarding the different features available
to developers.

## The Attributes Package at a Glance

The *Attributes* package contains several types and protocols for making underlying data used in Graphical User
Interfaces (GUIs) more accessible from different visualisation libraries and graphical frameworks. The primary
purpose of this package is to provide scalability and availability to a wide range of use cases and projects that may
need data represented in a specific way. The *Attributes* package contains these distinct parts:

- Attributes
- Paths
- Validators
- Triggers
- Schemas and Properties

We have provided guides on all of these topics separately, but we will give a quick introduction to each so that you may
have an overview of the purpose of each module.

## Attributes

The attributes form the core of this package. An attribute is simply a way of representing some data's possible domain of values.
You may think of attributes as a pseudo-type system that restricts data to a specific form. For example, an integer attribute
represents data as numeric integer values. In addition to this restriction, attributes can be one of
two types: ``LineAttribute`` or ``BlockAttribute``.

A `LineAttribute` can exist independently without any relation to another attribute type. A ``LineAttribute`` is
also one that you can typically render in one line in your chosen GUI. A ``BlockAttribute`` is the opposite of a ``LineAttribute``.
A ``BlockAttribute`` may (but not necessarily) nest attributes by containing one or more other ``LineAttribute``s (or recursive ``BlockAttribute``s).
A ``BlockAttribute`` cannot usually be rendered within a single line but can take up the entire width and height of the element it is
within. Some examples of ``BlockAttribute``s are tables, text blocks, Collections of ``LineAttribute``s and code blocks.

## Paths

The paths in this package exist on top of *Swift Key-Paths*. The most common use case for our paths is to mutate attributes existing within a *Root* object
using its equivalent *Key-Path*. Our Paths, however, provide a means to determine if the path is valid in the root object, removing runtime
crashes via a well-defined checking mechanism. These paths can also determine if higher elements in the membership hierarchy are nil (or
null-referenced by the key-path). Some examples might include invalid indexes in an array (such as indexes beyond the length of
the array) which would usually create index out-of-bounds crashes. The paths may check for these scenarios, and errors are thrown
(or results return failures) when suitable.

Our paths also support two fundamental types of operations: those that can mutate the root object and those that cannot perform mutation.
This distinction is done by using different value types without an inheritance hierarchy using reference types. This method is beneficial as it
protects mutation when not needed and allows referential transparency by default.

## Validators

Validators provide the means of performing sanity checking for the underlying data of an attribute. We have designed Validators to
be used in a declarative fashion using result builders similar to the style of *SwiftUI* views or via function chaining.
This feature allows users to programmatically combine validators to create custom validation rules without creating a new validator type.
There is an extensive catalogue of supported validation rules provided in this package. Some examples include: *required*, *max length*,
*not nil*, etc.

## Triggers

Triggers provide the means of performing some functions when specific events happen within the attribute hierarchy. A trigger will perform
some user-defined function in response to some event that occurred. An example of an event might be the mutation of a specific attribute or
an attribute rendered on-screen by a graphical library. This package provides several pre-defined actions that a developer can use without
creating a custom trigger. Some examples include: *when available/unavailable, perform some function*, *when changed, perform some function*,
*apply a change to all elements within a collection*, etc.

We have designed Triggers to be declarative using result builders similar to the style of *SwiftUI* views or via function chaining. This
process allows the developer to programmatically compose triggers enabling the definition of custom triggers from multiple sub-triggers without creating
a new trigger type.

## Schemas and Properties

The schemas and properties objects provide the means of bringing all the previously discussed topics together. A schema represents the types
encapsulated within a view and how they relate. For example, a person's information form might contain fields for their given name and family name.
In this case, the developer can create a schema for this view that groups these two attributes together. The developer can optionally define
validation and triggers for the fields separately (or together). Each view can be represented as a schema in a declarative fashion by using
properties. Properties are simply property wrapper versions of the attributes found within this package. A schema does not contain any data,
but provides the means of defining validation and trigger rules for attribute types within a view.
