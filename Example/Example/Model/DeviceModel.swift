//
//  DeviceModel.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit
import CoreBluetooth
import Combine

class DeviceModel: PeripheralModel, DeviceModelProtocol {
    override class var requiredAdvertisedServices: [CBUUID] {
        []
    }

    override class var servicesToScan: [CBUUID] {
        [CBUUID(string: "180F"), CBUUID(string: "180A")]
    }

    @Published var batteryLevel = Characteristic<Int8>(initialValue: 0, uuid: CBUUID(string: "2A19"))
    @Published var manufacturerName = Characteristic<String>(initialValue: "Unknown manufacturer", uuid: CBUUID(string: "2A29"))

    var name: String {
        return self.peripheral.name ?? "Unknown Peripheral"
    }
}
