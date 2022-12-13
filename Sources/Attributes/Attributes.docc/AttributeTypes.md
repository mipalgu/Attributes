# Attribute Types

This document provides an overview of the different attribute types available to the developer.

## Overview

Recall that an attribute is a general datatype that can be related to other attribute types through recursive relationships. Attributes come in two kinds:
a ``LineAttribute`` or a ``BlockAttribute``. A ``LineAttribute`` is an attribute that does not contain any other recursive
attribute in its definition. A ``LineAttribute`` is rendered within a single line and may appear in the same line as
other ``LineAttribute`` types in a view hierarchy. A ``BlockAttribute`` is an attribute that can contain other recursive
attributes, including different (or identical) `BlockAttribute` types. A ``BlockAttribute`` is rendered independently and may not appear
next to other attributes. In the coming sections, we will explore the attributes currently supported in this package.

## Line Attributes

All of the supported line attributes are listed below. Each attribute has a name, a description, and an example of how to instantiate it.
All of these values exist within the ``LineAttribute`` enumeration. ``LineAttributeType`` similarly contains the type information.

| Name | Description | Example |
| ---- | ----------- | ------- |
| Boolean | A boolean value. | `LineAttribute.bool(true)` or `LineAttribute.bool(false)` |
| Integer | An integer value. | `LineAttribute.integer(42)` |
| Float | A floating point value. | `LineAttribute.float(3.14)` |
| Expression | An expression in a programming language. See ``Language`` for a full list of supported languages. | `LineAttribute.expression("x + y", language: .swift)` |
| Enumerated | A value from a list of possible values. | `LineAttribute.enumerated("red", validValues: ["red", "green", "blue"])` |
| Line | A line of text. | `LineAttribute.line("Hello, world!")` |

## Block Attributes

All of the supported block attributes are listed below. Each attribute has a name, a description, and an example of how to instantiate it.
All of these values exist within the ``BlockAttribute`` enumeration. ``BlockAttributeType`` similarly contains the type information.

| Name | Description | Example |
| ---- | ----------- | ------- |
| Code | A block of code. See ``Language`` for a full list of supported languages. | `BlockAttribute.code("print(\"Hello, world!\")", language: .swift)` |
| Collection | A collection of attributes. | `BlockAttribute.collection([LineAttribute.line("Hello, world!")], display: ReadOnlyPath(Attribute.self).lineValue, type: AttributeType.line)` |
| Complex | A group of related attributes that have different types. This attribute is similar to a struct of common properties. | `BlockAttribute.complex(["Name": Attribute.line("Alice"), "Age": Attribute.integer(25)], layout: [Field(name: "Name", type: AttributeType.line), Field(name: "Age", type: AttributeType.integer)])` |
| Enumerable Collection | A collection of values that exist within a Set of valid values. | `BlockAttribute.enumerableCollection(["red", "green"], validValues: ["red", "green", "blue"])` |
| Text | A block of text. | `BlockAttribute.text("Hello, world!")` |
| Table | A table of data. | `BlockAttribute.table([[LineAttribute.line("Alice"), LineAttribute.integer(42)], [LineAttribute.line("Bob"), LineAttribute.integer(21)]], columns: [BlockAttributeType.TableColumn(name: "Name", type: LineAttributeType.line), BlockAttributeType.TableColumn(name: "Age", type: LineAttributeType.integer)])` |

## Attribute

It is worth noting that some of these definitions are recursive and use the ``Attribute`` type rather than ``LineAttribute`` or ``BlockAttribute``. ``Attribute``
is an enumeration that wraps both ``LineAttribute`` and ``BlockAttribute``. This wrapper allows for a single type to be used for defining attributes, and
we have placed static functions that enable the creation of both ``LineAttribute`` and ``BlockAttribute`` types. For example, we can instantiate the `LineAttribute.float` case
using `Attribute.float` or `Attribute.line(.float)`. Similarly, we can instantiate the `BlockAttribute.code` case using `Attribute.code`.
