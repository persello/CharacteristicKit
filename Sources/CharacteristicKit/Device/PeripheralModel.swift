//
//  PeripheralModel.swift
//
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation
import CoreBluetooth
import Combine

/// A protocol for building peripheral models.
///
/// Conforming your device model class to ``PeripheralModel`` will allow to
open class PeripheralModel: GenericPeripheralModel, Equatable, Identifiable, Hashable {
    
    open class var requiredAdvertisedServices: [CBUUID] {
        []
    }
    
    open class var servicesToScan: [CBUUID] {
        []
    }

    static var centralManager: CBCentralManager? = nil
    static var centralManagerDelegate: CBCentralManagerDelegate? = nil

    /// The required reference to the peripheral delegate.
    var delegate: PeripheralDelegate!

    /// The required reference to the peripheral.
    public var peripheral: CBPeripheral
    
    public var valueChangeCancellable: AnyCancellable?

    /// Initialise the model from a Core Bluetooth peripheral.
    /// - Parameter peripheral: A Core Bluetooth peripheral.
    init(from peripheral: CBPeripheral) async {
        self.peripheral = peripheral
        self.delegate = await PeripheralDelegate(model: self)
        peripheral.delegate = self.delegate
    }
}

public extension PeripheralModel {
    static func == (lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        return lhs.id == rhs.id
    }

    var id: UUID {
        return peripheral.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.peripheral)
    }
}

public extension PeripheralModel {

    func initialiseDelegate() {
        Task {
            self.delegate = await PeripheralDelegate(model: self)
            peripheral.delegate = self.delegate
        }
    }

    func connect() {
        Self.centralManager?.connect(self.peripheral)
    }

    func disconnect() {
        Self.centralManager?.cancelPeripheralConnection(self.peripheral)
        self.valueChangeCancellable?.cancel()
    }

    var state: CBPeripheralState {
        get {
            return peripheral.state
        }

        // swiftlint:disable:next unused_setter_value
        set {

        }
    }
}
