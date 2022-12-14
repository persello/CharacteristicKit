//
//  PeripheralDelegate.swift
//  pulse.loop
//
//  Created by Riccardo Persello on 05/11/22.
//

import Foundation
import Runtime
import CoreBluetooth
import os

public class PeripheralDelegate<Device: DeviceModel>: NSObject, CBPeripheralDelegate {
    internal var logger: Logger
    private var device: Device
    
    private var variableMap: [CBUUID: any CharacteristicProtocol] = [:]
    
    public init(device: Device) {
        self.logger = Logger(subsystem: "CharacteristicKit", category: "Bluetooth Device Delegate")
        self.device = device
        
        variableMap = self.device.getCharacteristics()
        
        logger.info("Characteristic mapping complete: \(self.variableMap.count) characteristics mapped.")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        logger.trace("\(characteristic.value?.description ?? "Nothing") written to \(characteristic.uuid).")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        logger.trace("\(characteristic.value?.description ?? "Nothing") read from \(characteristic.uuid).")

        if let data = characteristic.value,
           let variable = self.variableMap[characteristic.uuid] {
            variable.setLocalValue(data: data)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.debug("Discovered \(peripheral.services?.description ?? "no services").")
        
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([], for: service)
        }
        
        DispatchQueue.main.async {
            self.device.status = .connected
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.debug("Discovered \(service.characteristics?.description ?? "no characteristics") in \(service).")
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // Request an initial reading...
            if let variable = self.variableMap[characteristic.uuid] {
                variable.onDiscovered(in: peripheral)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        logger.debug("Updated notification/indication state to \(characteristic.isNotifying) for \(characteristic).")
    }
}
