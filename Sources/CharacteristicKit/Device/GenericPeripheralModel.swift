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
    
    func connect()
    func disconnect()
}
