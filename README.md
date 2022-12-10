# Attributes

This package provides a means to define common data types used in Graphical User Interfaces (GUIs). Types defined
using this package can be used with other existing projects to create cross-platform GUIs including
[SwiftUI/TokamakUI](https://github.com/mipalgu/AttributeViews) and [GTK 4.0+](https://github.com/mipalgu/AttributesGTKViews).

This package also supports data validation/sanitation and a type-safe means of performing callback functions triggered
by altering attribute values. We also provide a simple interface for determining when to redraw views without using
Combine or some other observation mechanism. This entire process is separate from any visualisation library and can
be disregarded for projects not requiring it. There is no aspect of a view in this package removing any dependency
to an underlying graphical library; we instead focus on how data is represented and related. In other words, data that is mutated
may require related data to be updated also.

## Prerequisites

This package requires swift version 5.6 on linux and macOS distributions. We believe this package may be
supported on Windows natively, but we are not officially supporting it in our CI infrastructure. If you would like
to use Windows in a supported manner, then you may use the WSL Ubuntu images with swift 5.6 installed to compile
this package.

## Usage

This package can be embedded directly in a Swift project that utilises the Swift Package Manager. Simply
add this package as a dependency in your package manifest.

```swift
Package(
    name: "<package_name>",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "git@github.com:mipalgu/Attributes.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a
        // module or a test suite. Targets can depend on other targets in this package,
        // and on products in packages this package depends on.
        .target(
            name: "<target_name>",
            dependencies: ["Attributes"]
        ),
    ]
)

```

## Documentation

The documentation for the main branch can be seen on the [GitHub Pages Website](https://mipalgu.github.io/Attributes/).
For documentation on releases or other branches, you may generate the documentation locally by using the swift DocC plugin.

```shell
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target Attributes --output-path ./docs \
    --transform-for-static-hosting --hosting-base-path Attributes
swift package --disable-sandbox preview-documentation --target Attributes
```
