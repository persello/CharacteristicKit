//
//  DeviceModel.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation

/// Represents the root class of a peripheral model.
public protocol DeviceModel: CharacteristicContainer {
    
    /// The status of the device is updated by the delegate.
    var status: DeviceStatus { get set }
    
    /// The required reference to the peripheral delegate.
    var delegate: PeripheralDelegate<Self>? { get }
}
