//
//  DeviceModel.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit
import CoreBluetooth

class DeviceModel: GenericPeripheralModel {
    let name: String
    @Published var status: CharacteristicKit.PeripheralStatus
    @Published var batteryLevel = Characteristic<Int8>(initialValue: 0, uuid: CBUUID(string: "2A19"))
    
    init() {
        name = "Riccardo's iPhone"
        status = .disconnected
    }
    
    func connect() {
        
    }
    
    func disconnect() {
        
    }
}
