# Validators

This section describes the validators that are available in the `Attributes` module.

## Overview

A validator can be considered a function that takes a value and throws errors when that value is incorrect.
The `Attributes` module provides several validators that a developer can use to validate the raw data
for different attributes. We will explore how to create validators and chain them to create custom validation
rules in the coming documents. This guide introduces the validators available in this package
and what each validation rule accomplishes.

## Core Validators

Below are the core validators used to validate the raw data for different attributes. You will typically not create these validators outright but instead
use a ``ValidatorFactory`` to create them. The ``ValidatorFactory`` is a struct with static functions that generate the core validators.

| Validator | Description |
| --- | --- |
| ``OptionalValidator`` | This validator marks an attribute as optional. The validator will not throw an error if the attribute is not present in the raw data. |
| ``RequiredValidator`` | This validator marks an attribute as required. The validator will throw an error if the attribute is not present in the raw data. |
| ``Validator`` | This validator is used to create custom validation functions. |
| ``AnyValidator`` | This validator represents a type-erased validator that can validate any attribute with a validation function. |

## Validation Rules

We will now examine the pre-defined rules for the different attributes. These rules exist within the ``ValidatorFactory`` struct.

| Validation Rule | Description | Supported Attributes|
| --- | --- | --- |
| `alpha` | This rule validates that the attribute is an alphabetic string. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `alphadash` | This rule validates that the attribute is an alphanumeric string with dashes and underscores. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `alphafirst` | This rule validates that the attribute starts with an alphabetic character. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `alphanumeric` | This rule validates that the attribute is an alphanumeric string. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `alphaunderscore` | This rule validates that the attribute is an alphanumeric string with underscores. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `alphaunderscorefirst` | This rule validates that the attribute starts with an alphabetic character or an underscore. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `between` | This rule validates that the attribute is between the given range. | Comparable Attributes |
| `blacklist` | This rule validates that the attribute is not in the given Set. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `empty` | This rule validates that the attribute is empty. | Collection Attributes |
| `equals` | This rule validates that the attribute is equal to the given value. | Equatable Attributes |
| `equalsFalse` | This rule validates that the attribute is equal to `false`. | `LineAttributeType.bool` |
| `equalsTrue` | This rule validates that the attribute is equal to `true`. | `LineAttributeType.bool` |
| `greaterThan` | This rule validates that the attribute is greater than the given value. | Comparable Attributes |
| `greaterThanEqual` | This rule validates that the attribute is greater than or equal to the given value. | Comparable Attributes |
| `greyList` | This rule validates that the attribute contains a substring that is in the given Set. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `if` | This rule creates a conditional validator. The validator will only be applied if the condition is true. This validator may optionally take an `else` function that is executed in the case the condition is not true | All |
| `length` | This rule validates that the attribute has the given length. | Collection Attributes |
| `lessThan` | This rule validates that the attribute is less than the given value. | Comparable Attributes |
| `lessThanEqual` | This rule validates that the attribute is less than or equal to the given value. | Comparable Attributes |
| `maxLength` | This rule validates that the attribute has a length less than or equal to the given length. | Collection Attributes |
| `minLength` | This rule validates that the attribute has a length greater than or equal to the given length. | Collection Attributes |
| `notEmpty` | This rule validates that the attribute is not empty. | Collection Attributes |
| `notEquals` | This rule validates that the attribute is not equal to the given value. | Equatable Attributes |
| `numeric` | This rule validates that the attribute is a numeric string. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |
| `optional` | This rule marks an attribute as optional. The validator will not throw an error if the attribute is not present in the raw data. | All |
| `required` | This rule marks an attribute as required. The validator will throw an error if the attribute is not present in the raw data. | All |
| `unique` | This rule validates that the attribute has unique elements. | Sequence Attributes |
| `whitelist` | This rule validates that the attribute is in the given Set. | `LineAttributeType.line`, `LineAttributeType.expression`, `BlockAttributeType.code`, `BlockAttributeType.text` |

See ``ValidationPushProtocol`` for a more detailed description of each rule.
