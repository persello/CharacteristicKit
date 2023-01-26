//
//  DeviceModelProtocol.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit

protocol DeviceModelProtocol: GenericPeripheralModel {
    associatedtype BatteryLevel: CharacteristicProtocol<Int8>
    
    var name: String { get }
    var batteryLevel: BatteryLevel { get }
}

