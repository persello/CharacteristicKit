//
//  PeripheralModel.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation
import CoreBluetooth

/// Represents the root class of a peripheral model.
public protocol PeripheralModel: GenericPeripheralModel {
    
    /// The required reference to the peripheral delegate.
    var delegate: PeripheralDelegate<Self>? { get }
    
    /// The required reference to the peripheral.
    var peripheral: CBPeripheral? { get }
    
    /// Initialise the model from a Core Bluetooth peripheral.
    /// - Parameter peripheral: A Core Bluetooth peripheral.
    init(from peripheral: CBPeripheral?)
}
