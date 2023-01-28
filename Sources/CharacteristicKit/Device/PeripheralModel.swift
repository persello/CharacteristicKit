//
//  PeripheralModel.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation
import CoreBluetooth

/// Represents the root class of a peripheral model.
public protocol PeripheralModel: GenericPeripheralModel, Equatable, Identifiable, Hashable {
    
    static var requiredAdvertisedServices: [CBUUID]? { get }
    static var servicesToScan: [CBUUID]? { get }
    static var centralManager: CBCentralManager? { get set }
    static var centralManagerDelegate: CBCentralManagerDelegate? { get set }
    
    /// The required reference to the peripheral delegate.
    var delegate: PeripheralDelegate<Self>? { get }
    
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
    func connect() {
        Self.centralManager?.connect(self.peripheral)
    }
    
    func disconnect() {
        Self.centralManager?.cancelPeripheralConnection(self.peripheral)
    }
    
    var state: CBPeripheralState {
        get {
            return peripheral.state
        }
        
        set {
            
        }
    }
}
