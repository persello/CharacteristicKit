//
//  DeviceModel.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit
import CoreBluetooth

final class DeviceModel: DeviceModelProtocol, PeripheralModel {
    static var centralManager: CBCentralManager?
    static var centralManagerDelegate: CBCentralManagerDelegate?
    static var requiredAdvertisedServices: [CBUUID]? = nil
    static var servicesToScan: [CBUUID]? = [CBUUID(string: "180F")]
    
    @Published var batteryLevel = Characteristic<Int8>(initialValue: 0, uuid: CBUUID(string: "2A19"))

    var delegate: CharacteristicKit.PeripheralDelegate<DeviceModel>?
    @Published var peripheral: CBPeripheral
    
    var name: String {
        return self.peripheral.name ?? "Unknown Peripheral"
    }
    
    required init(from peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        Task {
            self.delegate = await CharacteristicKit.PeripheralDelegate(model: self)
            peripheral.delegate = self.delegate
        }
    }
}
