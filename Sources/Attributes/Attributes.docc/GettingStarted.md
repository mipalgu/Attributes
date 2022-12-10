# Getting Started

This guide provides on overview of the Attributes package in terms of the different features available
to developers.

## The Attributes Package at a Glance

The *Attributes* package contains a number of types and protocols for making underlying data used in Graphical User
Interfaces (GUIs) more accessible from different visualisation libraries and graphical frameworks. The main purpose
of this package is to provide scalability and availability to a wide range of different use-cases and projects that may
need data represented in a specific way. The *Attributes* package can be broken up into these distinct parts:

- Attributes
- Paths
- Validators
- Triggers
- Schemas and Properties

We have provided guides on all of these topics separately, but we will provide a quick introduction to each so that you may
have an overview of the purpose of each module.

## Attributes

The attributes form the core of this package. An attribute is simply a way of representing the possible values a data can have.
You may think of attributes as a pseudo-type system that restricts data to a specific form. For example, there is an integer
attribute that represents data as numeric integer values. In addition to this restriction, attribute are further broken up into
two types: ``LineAttribute``s and ``BlockAttribute``s.

A ``LineAttribute`` is one that can exist on it's own without any relation to another attribute type. A ``LineAttribute`` is
also one that you can typically render in one line in your chosen GUI. A ``BlockAttribute`` is the opposite of a ``LineAttribute``.
A ``BlockAttribute`` may (but not necessarily) nest attributes by containing one or more other ``LineAttribute``s (or recursive ``BlockAttribute``s).
A ``BlockAttribute`` cannot usually be rendered within a single line, but can take up the entire width and height of the element it is
within. Some examples of ``BlockAttribute``s are Tables, Text Blocks, Collections of ``LineAttribute``s and code blocks.

## Paths

The paths in this package are built on top of *Swift Key-Paths*. The paths are used to mutate attributes existing within a *Root* object
by using it's equivalent *Key-Path*. Our Paths however provide a means to determine if the path is valid in the root object removing runtime
crashes by using a well-defined checking mechanism. These paths can also determinine if higher elements in the membership heirarchy are
nil (or null-referenced by the key-path). Some examples might include invalid indexes in an array (such as indexes beyond the length of
the array) which would usually create index out of bounds crashes. These types of scenarios are checked by the paths in this package
and errors are thrown (or results return failures) when suitable.

Our paths are also separated into types that can mutate the root object, and types that cannot perform mutation. This distinction
is done by using different value-types without an inheritence heirarchy using reference-types. This method is beneficial as it
protects mutation when not needed and allows referential transparency by default.

## Validators

Validators provide the means of performing sanity checking for the underlying data of an attribute. Validators are designed to
be used in a declarative fashion using result builders similar to the style of *SwiftUI* views or alternatively via function chaining.
This feature allows validators to be combined together to create a custom validator rule programmatically, without the need of creating
a new validator type.

There is a large catalogue of supported validation rules provided in this package. Some examples include: *required*, *max length*,
*not nil*, etc.

## Triggers

Triggers provide the means of performing some functions when specific events happen within the attribute heirarchy. A trigger will perform
some user-defined function in response to some even that occured. An example of an event might be the mutation of a specific attribute, or
an attribute being rendered on-screen by a graphical library. This package provides a number of pre-defined actions that can be used without
creating a custom trigger. Some examples include: *when available/unavailable perform some function*, *when changed perform some function*,
*apply a change to all elements within a collection*, etc.

Triggers are design to be declarative using result builders similar to the style of *SwiftUI* views or alternatively via function chaining. This
process allows triggers to be combined programmatically to allow custom triggers from composing multiple sub-triggers without creating
a new trigger type.

## Schemas and Properties

The schemas and properties objects provide the means of bringing all of the previous discussed topics together. A schema represents the types
encapsulated within a view and how they relate to one another. For example, a form for a persons personal information might contain fields
for their given name and family name. In this case, a schema can be created for this view that groups these two attributes together and provides
validation and triggers for the fields separately (or together). Each view can be represented as a schema in a declarative fashion by using
properties. Properties are simply property wrapper versions of the attributes found within this package. A schema does not contain any data
itself, but provides the means of defining validation and trigger rules for attribute types within a view.
