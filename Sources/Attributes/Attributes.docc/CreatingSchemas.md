# Creating Schemas

This tutorial demonstrates how to create a schema for a simple Person view. This guide will also introduce the methods of creating
validators and triggers for a view hierarchy.

## The Problem

We want to create a simple form for a person. This form will have a name, age, and a list of friends the user can add and remove.
This package does not depend on graphical libraries, so we will only present the type information for such a view using Schemas.

## The Architecture

We will create a schema for a Person view. This schema will have name, age, and friends list attributes. The schema will also
contain triggers for mutating the data in the model and validators for sanitising any data entry the user will perform. The
model will be an object of a particular form that the schema will use. This model will conform to the `Modifiable` protocol,
allowing the schema to mutate the model. This package already provides a ``Modifiable`` implementation that we will use
in this example called ``EmptyModifiable``.

The ``EmptyModifiable`` struct will treat the person as a *complex attribute* containing other attributes for the
name, age, and friends list. Our schema will also reflect this structure by using a struct that conforms to
``ComplexProtocol`` to represent our person. It is crucial to match the design of our ``Modifiable``
model with that of our schema. The schema acts as a bridge between the model and the view by defining
the type-information within our model. The schema also defines how the type-information relates to other artefacts in our system
and the mechanisms triggered when data changes in our attributes.

## The Person Complex

Since our Person represents a complex attribute, we can define a struct that conforms to ``ComplexProtocol`` to represent this
information. This package provides methods for performing declarative programming to determine the structure of our schema.

```swift
/// A person struct represented as a Complex.
struct Person: ComplexProtocol {

    /// The search path.
    typealias SearchPath = Path<EmptyModifiable, Attribute>

    /// The data root.
    typealias Root = EmptyModifiable

    /// The attribute root.
    typealias AttributeRoot = Attribute

    /// The first name type information.
    @LineProperty(
        label: "first_name",
        validation: { $0.alpha().minLength(1).maxLength(20) }
    )
    var firstName

    /// The last name type information.
    @LineProperty(
        label: "last_name",
        validation: { $0.alpha().minLength(1).maxLength(20) }
    )
    var lastName

    /// The age type information.
    @IntegerProperty(
        label: "age",
        validation: { $0.between(min: 0, max: 150) }
    )
    var age

    /// A table of friends.
    @TableProperty(
        label: "friends",
        columns: [
            TableColumn.line(
                label: "first_name",
                validation: .required().alpha().minLength(1).maxLength(20)
            ),
            TableColumn.line(
                label: "last_name",
                validation: .required().alpha().minLength(1).maxLength(20)
            )
        ],
        validation: { $0.maxLength(512).minLength(0).unique() }
    )
    var friends

    /// Whether to add a new friend.
    @BoolProperty(label: "add_friend")
    var addFriend

    /// A table to create a new friend.
    @TableProperty(
        label: "new_friend",
        columns: [
            TableColumn.line(
                label: "first_name",
                validation: .required().alpha().minLength(1).maxLength(20)
            ),
            TableColumn.line(
                label: "last_name",
                validation: .required().alpha().minLength(1).maxLength(20)
            )
        ],
        validation: { $0.maxLength(1).minLength(0) }
    )
    var newFriend

    /// Hide or display the new friend table.
    @TriggerBuilder<EmptyModifiable>
    var triggers: some TriggerProtocol {
        WhenTrue(
            SchemaAttribute(label: "add_friend", type: .bool),
            makeAvailable: SchemaAttribute(
                label: "new_friend",
                type: .table(columns: [("first_name", .line), ("last_name", .line)])
            )
        )
        WhenFalse(
            SchemaAttribute(label: "add_friend", type: .bool),
            makeUnavailable: SchemaAttribute(
                label: "new_friend",
                type: .table(columns: [("first_name", .line), ("last_name", .line)])
            )
        )
    }

    /// The path to the data represented by this struct.
    let path = Path(EmptyModifiable.self).attributes[0].attributes["person"].wrappedValue

}
```
