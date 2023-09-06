# ``CharacteristicKit``

Create reactive models for your BLE peripherals.

## Overview

CharacteristicKit allows you to build a model for your Bluetooth Low Energy peripherals.

You can create classes and protocols that represent the BLE model of your peripheral, discover them and interact with their characteristics in a type-safe way, with automatic notifications for value changes, compatible with Combine and SwiftUI.

## Topics

### Creating peripheral models

The main feature of CharacteristicKit is the creation of device objects instantiated from a class implementing the ``PeripheralModel`` protocol.

- ``PeripheralModel``

### Creating peripheral protocols

In some cases, it can be useful to define a protocol that lists all the characteristics of a peripheral, such as mocks and generic parts of models.

- ``GenericPeripheralModel``

### Creating mock device models

A mock model can be built in order to simulate a peripheral in-app, or to implement other communication protocols by retaining the same structure of your peripherals' BLE interface.

- ``MockPeripheralModel``
