//
//  PeripheralDelegate.swift
//
//
//  Created by Riccardo Persello on 05/11/22.
//

import Foundation
import Runtime
import CoreBluetooth
import os

/// An extension of the Core Bluetooth peripheral delegate that automatically scans its associated ``PeripheralModel`` for contained and nested ``Characteristic``s.
public class PeripheralDelegate<Model: PeripheralModel>: NSObject, CBPeripheralDelegate {
    internal var logger: Logger
    private var model: Model
    
    private var variableMap: [CBUUID: any DiscoverableCharacteristic] = [:]
    
    
    // TODO: Allow user to opt-out from automatic subscription.
    
    /// Initialises a new instance of the delegate from a model that conforms to ``PeripheralModel``.
    /// - Parameter model: A model conforming to ``PeripheralModel``.
    public init(model: Model) async {
        self.logger = Logger(subsystem: "CharacteristicKit", category: "Bluetooth Device Delegate")
        self.model = model
        
        variableMap = await self.model.getCharacteristics()
        
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
            self.model.state = .connected
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
