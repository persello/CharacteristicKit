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

final class DeviceModel: DeviceModelProtocol, PeripheralModel {
    static var centralManager: CBCentralManager?
    static var centralManagerDelegate: CBCentralManagerDelegate?
    static var requiredAdvertisedServices: [CBUUID]? = nil
    static var servicesToScan: [CBUUID]? = [CBUUID(string: "180F"), CBUUID(string: "180A")]
    
    var cancellable: AnyCancellable?
    
    @Published var batteryLevel = Characteristic<Int8>(initialValue: 0, uuid: CBUUID(string: "2A19"))
    @Published var manufacturerName = Characteristic<String>(initialValue: "Unknown manufacturer", uuid: CBUUID(string: "2A29"))

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
