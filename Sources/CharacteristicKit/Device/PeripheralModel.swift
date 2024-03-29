//
//  PeripheralModel.swift
//
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation
import CoreBluetooth

/// A protocol for building peripheral models.
///
/// Conforming your device model class to ``PeripheralModel`` will allow to
public protocol PeripheralModel: GenericPeripheralModel, Equatable, Identifiable, Hashable {

    static var requiredAdvertisedServices: [CBUUID]? { get }
    static var servicesToScan: [CBUUID]? { get }
    static var centralManager: CBCentralManager? { get set }
    static var centralManagerDelegate: CBCentralManagerDelegate? { get set }

    /// The required reference to the peripheral delegate.
    var delegate: PeripheralDelegate<Self>? { get set }

    /// The required reference to the peripheral.
    var peripheral: CBPeripheral { get }

    /// Initialise the model from a Core Bluetooth peripheral.
    /// - Parameter peripheral: A Core Bluetooth peripheral.
    init(from peripheral: CBPeripheral)
}

public extension PeripheralModel {
    static func == (lhs: Self, rhs: Self) -> Bool {
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
