//
//  Characteristic.swift
//  pulse.loop
//
//  Created by Riccardo Persello on 18/11/22.
//

import Foundation
import CoreBluetooth
import os

/// Representation of a GATT characteristic.
public class Characteristic<T: Equatable>: CharacteristicProtocol, DiscoverableCharacteristic {
    /// The latest read or written value for this ``Characteristic``.
    private var internalValue: T

    /// The associated peripheral.
    private var peripheral: CBPeripheral?

    /// The associated Core Bluetooth characteristic.
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
        self.lastReadingTime = .distantPast

        self.logger = Logger(subsystem: "CharacteristicKit", category: "Characteristic \(uuid)")

        self.refreshValue()
    }

    /// Search for a characteristic with a corresponding identifier on the specified device.
    /// - Parameters:
    ///   - uuid: The identifier to search.
    ///   - peripheral: The remote peripheral.
    /// - Returns: A Core Bluetooth characteristic, if successful.
    internal static func discoverCharacteristic(from uuid: CBUUID, on peripheral: CBPeripheral) -> CBCharacteristic? {
        return (peripheral.services?.compactMap({ service in
            service.characteristics?.first(where: { characteristic in
                characteristic.uuid == uuid
            })
        }).first)
    }

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
            self.internalValue = value
            let size = MemoryLayout.size(ofValue: self.internalValue)
            peripheral.writeValue(
                Data(bytes: &self.internalValue, count: size),
                for: characteristic,
                type: .withResponse
            )
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

    /// Sets the local (internal) value, without notifying the actual device.
    ///
    /// This function triggers an observable object change.
    /// - Parameter data: Raw data received from the device.
    public func setLocalValue(data: Data) {
        // Padding.
        let requiredPadding = MemoryLayout<T>.size - data.count

        guard requiredPadding >= 0 else {
            logger.error("The size of the received data is larger than the memory layout size of \(T.self).")
            return
        }

        var paddedData = Data(count: requiredPadding)
        paddedData.append(data)

        if T.self == String.self {
            if let encoding = data.stringEncoding {
                // We are SURE that T is String. We just checked.
                // swiftlint:disable:next force_cast
                self.internalValue = (String(data: data, encoding: encoding) ?? "") as! T
            }
        } else {
            self.internalValue = paddedData.withUnsafeBytes({$0.load(as: T.self)})
        }

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
    /// If this happens, an update is requested immediately and the ``Characteristic``
    /// object will change when a response is received.
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

extension Data {
    var stringEncoding: String.Encoding? {
        var nsString: NSString?
        guard case let rawValue = NSString.stringEncoding(
            for: self,
            encodingOptions: nil,
            convertedString: &nsString,
            usedLossyConversion: nil
        ),
        rawValue != 0 else {
            return nil
        }

        return .init(rawValue: rawValue)
    }
}
