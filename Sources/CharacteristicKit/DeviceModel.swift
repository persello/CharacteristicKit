//
//  DeviceModel.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation

public protocol DeviceModel: CharacteristicContainer {
    var status: DeviceStatus { get set }
    var peripherals: PeripheralDelegate<Self> { get }
}
