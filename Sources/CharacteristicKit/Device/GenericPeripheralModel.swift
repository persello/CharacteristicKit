//
//  GenericPeripheralModel.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth
import Combine

public protocol GenericPeripheralModel: CharacteristicContainer, ObservableObject {
    
    /// A cancellable that works as a sink for all the object change notifications generated from the nested characteristics.
    var valueChangeCancellable: AnyCancellable? { get set }

    /// The status of the device is updated by the delegate.
    var state: CBPeripheralState { get set }
    
    /// Try to connect to the peripheral.
    func connect()
    
    /// Terminate the connection with the peripheral.
    func disconnect()
}
