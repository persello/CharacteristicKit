//
//  CharacteristicProtocol.swift
//
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth
import Combine

/// A protocol that defines a standardised interface for ``Characteristic`` and its mock ``MockCharacteristic``.
public protocol GeneralCharacteristicProtocol<T>: ObservableObject, Equatable {

    /// The type of this characteristic's represented value.
    associatedtype T: Equatable     // swiftlint:disable:this type_name

    /// The wrapped value.
    var value: T { get set }

    /// Core Bluetooth identifier associated with this characteristic.
    var uuid: CBUUID { get }

    /// Set the internal value.
    /// - Parameter value: new value.
    func setLocalValue(value: T)

    /// Set the internal value from a buffer of bytes.
    /// - Parameter data: Raw value representation.
    func setLocalValue(data: Data)
}

/// An internal protocol for using ``Characteristic<T>`` generically.
protocol CharacteristicProtocol: GeneralCharacteristicProtocol
where ObjectWillChangePublisher == ObservableObjectPublisher {

    /// Initialise the internal peripheral reference and try to
    /// discover the correspondent Core Bluetooth characteristic.
    /// - Parameter peripheral: Core Bluetooth peripheral on which the characteristic has been discovered.
    func onDiscovered(in peripheral: CBPeripheral)

    /// Refreshes the internal value by fetching it from the peripheral.
    func refreshValue()

}
