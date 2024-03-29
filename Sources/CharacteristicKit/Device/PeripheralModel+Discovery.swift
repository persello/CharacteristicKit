//
//  PeripheralModel+Discovery.swift
//
//
//  Created by Riccardo Persello on 26/01/23.
//

import Foundation
import CoreBluetooth
import Combine

class DiscoveryDelegate<Model>: NSObject, CBCentralManagerDelegate
where Model: PeripheralModel,
      Model.ObjectWillChangePublisher == ObservableObjectPublisher {

    private var continuation: AsyncStream<[Model]>.Continuation
    private var timeout: TimeInterval

    private var deviceDiscoveries: [UUID: Date] = [:]
    private var models: [Model] = []

    init(continuation: AsyncStream<[Model]>.Continuation, timeout: TimeInterval) {
        self.continuation = continuation
        self.timeout = timeout
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        // Update last seen.
        deviceDiscoveries[peripheral.identifier] = Date()

        // Add to models if a new device has been discovered.
        if !models.contains(where: { model in
            model.peripheral.identifier == peripheral.identifier
        }) {
            models.append(Model(from: peripheral))
        }

        // Keep only devices seen in the last `timeout` seconds, or that are currently connected.
        let filtered = models.filter { model in
            if model.state != .disconnected {
                return true
            }

            if let lastSeen = deviceDiscoveries[model.peripheral.identifier] {
                return lastSeen.addingTimeInterval(self.timeout) > Date()
            } else {
                return false
            }
        }

        continuation.yield(filtered)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let model = models.first(where: { model in
            model.peripheral.identifier == peripheral.identifier
        }) {
            DispatchQueue.main.async {
                model.objectWillChange.send()
            }

            model.peripheral.discoverServices(Model.servicesToScan)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let model = models.first(where: { model in
            model.peripheral.identifier == peripheral.identifier
        }) {
            DispatchQueue.main.async {
                model.objectWillChange.send()
            }
        }
    }
}

public extension PeripheralModel where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    static func discover(removeAfter timeout: TimeInterval = 5) -> AsyncStream<[Self]>? {
        if Self.centralManager == nil {
            Self.centralManager = CBCentralManager(delegate: nil, queue: .global(qos: .userInitiated))
        }

        guard let centralManager else {
            return nil
        }

        while centralManager.state == .unknown {
            // Blocking but works, I guess...
            // And blocks only once.
        }

        if centralManager.state != .poweredOn {
            return nil
        }

        return AsyncStream<[Self]> { continuation in
            if centralManagerDelegate == nil {
                centralManagerDelegate = DiscoveryDelegate(continuation: continuation, timeout: timeout)
            }

            centralManager.delegate = centralManagerDelegate

            centralManager.scanForPeripherals(
                withServices: Self.requiredAdvertisedServices,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        }
    }
}
