//
//  CharacteristicProtocol.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth

/// A protocol that defines a standardised interface for ``Characteristic`` and its mock ``FakeCharacteristic``.
public protocol CharacteristicProtocol<T>: ObservableObject, Equatable {
    associatedtype T: Equatable
    
    var value: T { get set }
    var uuid: CBUUID { get }
    var type: Any.Type { get }
    
    func onDiscovered(in peripheral: CBPeripheral)
    func refreshValue()
    func setLocalValue(data: Data)
    func setLocalValue(value: T)
}

public extension CharacteristicProtocol {
    var type: Any.Type {
        return T.self
    }
}
