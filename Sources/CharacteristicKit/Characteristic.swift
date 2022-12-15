//
//  Characteristic.swift
//  pulse.loop
//
//  Created by Riccardo Persello on 18/11/22.
//

import Foundation
import CoreBluetooth
import Runtime
import os

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

/// Represents a mock of ``Characteristic``, useful for creating simulated device models.
public class FakeCharacteristic<T: Equatable>: CharacteristicProtocol {
        
    /// The wrapped value of this property.
    @Published public var value: T
    
    /// A fake, empty identifier.
    public let uuid: CBUUID = CBUUID()
    
    
    /// Creates a new characteristic mock.
    /// - Parameter constant: The initial value of this property.
    public init(constant: T) {
        self.value = constant
    }
    
    public func onDiscovered(in peripheral: CBPeripheral) {}
    
    public func refreshValue() {}
    
    /// Set the internal value from a buffer of bytes.
    /// - Parameter data: Raw value representation.
    public func setLocalValue(data: Data) {
        DispatchQueue.main.async {
            self.value = data.withUnsafeBytes({$0.load(as: T.self)})
        }
    }
    
    /// Set the internal value
    /// - Parameter value: new value.
    public func setLocalValue(value: T) {
        DispatchQueue.main.async {
            self.value = value
        }
    }
    
    public static func == (lhs: FakeCharacteristic<T>, rhs: FakeCharacteristic<T>) -> Bool {
        return lhs.value == rhs.value
    }
}


/// Representation of a GATT characteristic.
public class Characteristic<T: Equatable>: CharacteristicProtocol {
    /// The latest read or written value for this ``Characteristic``.
    private var internalValue: T
    
    /// The associated peripheral.
    private var peripheral: CBPeripheral?
    
    /// The associated CoreBluetooth characteristic.
    private var characteristic: CBCharacteristic?
    
    /// The characteristic's identifier.
    public let uuid: CBUUID
    
    /// The maximum refresh interval, in seconds.
    let maximumPollingInterval: TimeInterval = 1
    
    /// The last time a read event happened for this characteristic.
    var lastReadingTime: Date
    
    /// Internal logger.
    private let logger: Logger
    
    /// Declare a new ``Characteristic``.
    /// - Parameters:
    ///   - initialValue: A default value.
    ///   - uuid: The characteristic's attribute identifier.
    public init(initialValue: T, uuid: CBUUID) {
        self.internalValue = initialValue
        self.uuid = uuid
        self.lastReadingTime = Date()
        
        self.logger = Logger(subsystem: "CharacteristicKit", category: "Characteristic \(uuid)")
        
        self.refreshValue()
    }
    
    /// Search for a characteristic with a corresponding identifier on the specified device.
    /// - Parameters:
    ///   - uuid: The identifier to search.
    ///   - peripheral: The remote peripheral.
    /// - Returns: A CoreBluetooth characteristic, if successful.
    internal static func discoverCharacteristic(from uuid: CBUUID, on peripheral: CBPeripheral) -> CBCharacteristic? {
        return (peripheral.services?.compactMap({ service in
            service.characteristics?.first(where: { characteristic in
                characteristic.uuid == uuid
            })
        }).first)
    }
    
    /// Initialise the internal peripheral reference and try to discover the correspondent CoreBluetooth characteristic.
    /// - Parameter peripheral: CoreBluetooth peripheral.
    public func onDiscovered(in peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.characteristic = Self.discoverCharacteristic(from: uuid, on: peripheral)
        self.refreshValue()
    }
    
    /// Tries to fetch an updated value for this characteristic.
    public func refreshValue() {
        guard let peripheral else {
            logger.warning("A refresh action has been tried before the peripheral has been set.")
            return
        }
        
        logger.trace("Read request.")
        
        if let characteristic {
            peripheral.readValue(for: characteristic)
        } else {
            self.characteristic = Self.discoverCharacteristic(from: self.uuid, on: peripheral)
            
            // Retry at most another time.
            if let characteristic {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    
    /// Tries to set a new value for the characteristic.
    /// - Parameter value: New value.
    func write(value: T) {
        
        guard let peripheral else {
            logger.warning("A write action has been tried before the peripheral has been set.")
            return
        }
        
        if let csc = value as? CustomStringConvertible {
            logger.trace("Write request for value \(csc.description)")
        } else {
            logger.trace("Write request.")
        }
        
        if let characteristic {
            // TODO: try to use self.setLocalValue(value: value) ???
            self.internalValue = value
            let size = MemoryLayout.size(ofValue: self.internalValue)
            peripheral.writeValue(Data(bytes: &self.internalValue, count: size), for: characteristic, type: .withResponse)
        } else {
            self.characteristic = Self.discoverCharacteristic(from: self.uuid, on: peripheral)
        }
    }
    
    public static func == (lhs: Characteristic<T>, rhs: Characteristic<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
    /// Sets the local (internal) value, without notifying the actual device.
    ///
    /// This function triggers an observable object change.
    /// - Parameter data: Raw data received from the device.
    public func setLocalValue(data: Data) {
        // Padding.
        let requiredPadding = MemoryLayout<T>.size - data.count
        var paddedData = Data(count: requiredPadding)
        paddedData.append(data)
        self.internalValue = paddedData.withUnsafeBytes({$0.load(as: T.self)})
        
        if let csc = self.internalValue as? CustomStringConvertible {
            logger.trace("Local value set to \(csc.description)")
        } else {
            logger.trace("Local value set.")
        }
                
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /// Sets the local (internal) value, without notifying the actual device.
    ///
    /// This function triggers an observable object change.
    /// - Parameter value: New value.
    public func setLocalValue(value: T) {
        self.internalValue = value
        
        if let csc = self.internalValue as? CustomStringConvertible {
            logger.trace("Local value set to \(csc.description)")
        } else {
            logger.trace("Local value set.")
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /// Whether the underlying characteristic has a notification or indication bit set.
    var notifying: Bool {
        return characteristic?.isNotifying ?? false
    }

    /// The updated value of this property.
    ///
    /// When reading, the updated value might not be immediately available.
    /// If this happens, an update is requested immediately and the ``Characteristic`` object will change when a response is received.
    public var value: T {
        get {
            if !notifying && abs(lastReadingTime.timeIntervalSinceNow) > self.maximumPollingInterval {
                lastReadingTime = Date()
                refreshValue()
            }
            return internalValue
        }
        set {
            if self.internalValue != newValue {
                write(value: newValue)
            }
        }
    }
}
