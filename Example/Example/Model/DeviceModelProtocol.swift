//
//  DeviceModelProtocol.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit

protocol DeviceModelProtocol: GenericPeripheralModel {
    associatedtype BatteryLevel: GeneralCharacteristicProtocol<Int8>
    associatedtype ManufacturerNameString: GeneralCharacteristicProtocol<String>

    var name: String { get }
    var batteryLevel: BatteryLevel { get }
    var manufacturerName: ManufacturerNameString { get }
}
