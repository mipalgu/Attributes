# ``Attributes``

A swift abstraction for defining types of data commonly rendered within a Graphical User Interface (GUI). This package provides
the means to define, validate, and relate different forms of data.

## Usage

You may depend on this package by using the [Swift Package Manager](https://www.swift.org/package-manager/). Simple place this
package as a dependency in your package manifest.

```swift
// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExamplePackage",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ExamplePackage",
            targets: ["ExamplePackage"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
	    .package(url: "git@github.com:mipalgu/Attributes.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ExamplePackage",
            dependencies: ["Attributes"]
        ),
        .testTarget(
            name: "ExamplePackageTests",
            dependencies: ["ExamplePackage", "Attributes"]
        )
    ]
)
```

## Topics

### Essentials

- <doc:GettingStarted>

### Attributes
- ``Attribute``
- ``AttributeType``
- ``BlockAttribute``
- ``BlockAttributeType``
- ``Code``
- ``Expression``
- ``Label``
- ``LineAttribute``
- ``LineAttributeType``

### Paths

- ``AnyPath``
- ``AnySearchablePath``
- ``CollectionSearchPath``
- ``ConvertibleSearchablePath``
- ``Path``
- ``PathContainer``
- ``PathProtocol``
- ``ReadOnlyPath``
- ``ReadOnlyPathContainer``
- ``ReadOnlyPathProtocol``
- ``SearchablePath``
- ``ValidationPath``
- ``ValidationPathProtocol``

### Properties

- ``BoolProperty``
- ``CodeProperty``
- ``CollectionProperty``
- ``ComplexCollectionProperty``
- ``ComplexProperty``
- ``EnumerableCollectionProperty``
- ``EnumeratedProperty``
- ``ExpressionProperty``
- ``FloatProperty``
- ``IntegerProperty``
- ``LineProperty``
- ``SchemaAttributeConvertible``
- ``TableColumn``
- ``TableProperty``
- ``TextProperty``

### Triggers

- ``AnyTrigger``
- ``ConditionalTrigger``
- ``CustomTrigger``
- ``ForEach``
- ``IdentityTrigger``
- ``MakeAvailableTrigger``
- ``MakeUnavailableTrigger``
- ``SyncTrigger``
- ``SyncWithTransformTrigger``
- ``TriggerBuilder``
- ``TriggerProtocol``
- ``WhenChanged``

### Validators

- ``AnyValidator``
- ``OptionalValidator``
- ``PathValidator``
- ``RequiredValidator``
- ``ValidationError``
- ``ValidationPushProtocol``
- ``Validator``
- ``ValidatorBuilder``
- ``ValidatorFactory``
- ``ValidatorProtocol``
