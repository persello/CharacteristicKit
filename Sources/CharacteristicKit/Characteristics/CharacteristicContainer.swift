//
//  CharacteristicContainer.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth
import Runtime

/// Protocol for defining types that contain characteristics.
///
/// If your ``DeviceModel`` contains nested ``Characteristic``s, make their containers adhere to this protocol.
/// The adhering types contained in a ``DeviceModel`` will be scanned in search for internal ``Characteristic`` properties.
public protocol CharacteristicContainer {}

public extension CharacteristicContainer {
    /// Get all the properties that of type ``Characteristic`` inside this container.
    /// - Returns: A dictionary of ``Characteristic``s keyed by their ``CBUUID``.
    internal func getCharacteristics() -> [CBUUID: any CharacteristicProtocol] {
        var variableMap: [CBUUID: any CharacteristicProtocol] = [:]
        let info = try! typeInfo(of: Self.self)
        for property in info.properties {
            if let variable = try? property.get(from: self) as? any CharacteristicProtocol {
                variableMap[variable.uuid] = variable
            } else if let variable = try? property.get(from: self) as? any CharacteristicContainer {
                variableMap.merge(variable.getCharacteristics(), uniquingKeysWith: { (current, _) in
                    current
                })
            }
        }
        
        return variableMap
    }
}
