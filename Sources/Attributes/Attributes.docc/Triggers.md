# Triggers

This guide presents the triggers that are available to the user by default.

## Overview

Triggers are a way to execute code when a specific event occurs. For example, when a user clicks a button, you can perform a function that will change the text of the button.
In the context of this package, this behaviour is equivalent to removing or mutating attributes in a data object when this event occurs.

## Core Triggers

We have created several core triggers to perform most of your frequent tasks. We will examine creating triggers in a future document, but now
you can see the core triggers in the table below.

| Trigger | Description |
| --- | --- |
| ``AnyTrigger`` | A type-erased trigger. |
| ``ConditionalTrigger`` | A trigger that executes another trigger when a condition is met. |
| ``CustomTrigger`` | A trigger that executes a closure when a value pointed to by a path (``ReadOnlyPathProtocol``) is changed. |
| ``ForEach`` | A trigger that executes a trigger for each element in a collection. |
| ``IdentityTrigger`` | A trigger that performs no function. |
| ``MakeAvailableTrigger`` | A trigger that makes an attribute available to the view hierarchy. |
| ``MakeUnavailableTrigger`` | A trigger that makes an attribute unavailable to the view hierarchy. |
| ``SyncTrigger`` | A trigger that synchronizes the value of an attribute with another attribute. |
| ``SyncWithTransformTrigger`` | A trigger that synchronizes the value of an attribute with another attribute, first applying a transformation. |
| ``WhenChanged`` | A trigger that executes another trigger when a value is changed. |
