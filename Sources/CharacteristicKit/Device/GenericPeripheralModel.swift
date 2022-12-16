//
//  GenericPeripheralModel.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation

public protocol GenericPeripheralModel: CharacteristicContainer, ObservableObject {
    /// The status of the device is updated by the delegate.
    var status: PeripheralStatus { get set }
    
    /// Try to connect to the peripheral.
    func connect()
    
    /// Terminate the connection with the peripheral.
    func disconnect()
}
