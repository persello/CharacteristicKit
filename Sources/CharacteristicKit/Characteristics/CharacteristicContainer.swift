//
//  CharacteristicContainer.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth
import Runtime
import Combine

/// Protocol for defining types that contain characteristics.
///
/// If your ``GenericPeripheralModel`` contains nested ``Characteristic``s, make their containers adhere to this protocol.
/// The adhering types contained in a ``GenericPeripheralModel`` will be scanned in search for internal ``Characteristic`` properties.
public protocol CharacteristicContainer: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {}

public extension CharacteristicContainer {
    /// Get all the properties that of type ``Characteristic`` inside this container.
    /// - Returns: A dictionary of ``Characteristic``s keyed by their ``CBUUID``.
    internal func getCharacteristics() async -> [CBUUID: any DiscoverableCharacteristic] {
        var variableMap: [CBUUID: any DiscoverableCharacteristic] = [:]
        let info = try! typeInfo(of: Self.self)
        
        for property in info.properties {
            if let variable = try? property.get(from: self) as? any DiscoverableCharacteristic {
                
                // Characteristic.
                variableMap[variable.uuid] = variable
            } else if let publishedVariable = try? property.get(from: self) as? any PublishedCharacteristic {
                var x = publishedVariable
                let characteristic = await x.getInnerCharacteristic()
                variableMap[characteristic.uuid] = characteristic
            } else if let variable = try? property.get(from: self) as? any CharacteristicContainer {
                
                // Characteristic container.
                await variableMap.merge(variable.getCharacteristics(), uniquingKeysWith: { (current, _) in
                    current
                })
            }
        }
        
        // Register change handlers...
        if let model = self as? any GenericPeripheralModel {
            for variable in variableMap {
                let characteristic = variable.value
                model.valueChangeCancellable = characteristic.objectWillChange.sink { _ in
                    model.objectWillChange.send()
                }
            }
        }
        
        return variableMap
    }
}
