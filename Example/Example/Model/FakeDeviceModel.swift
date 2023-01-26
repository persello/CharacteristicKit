//
//  FakeDeviceModel.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit
import CoreBluetooth

class FakeDeviceModel: DeviceModelProtocol, MockPeripheralModel {
    typealias BatteryLevel = MockCharacteristic<Int8>
    
    var name: String = "Fake device \(Int.random(in: 0...1000))"
    var batteryLevel = BatteryLevel(constant: 45)
    @Published var state: CBPeripheralState = .disconnected
    
    private var updateTimer: Timer?
    
    func connect() {
        state = .connected
        
        if let updateTimer {
            updateTimer.invalidate()
        }
        
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.batteryLevel.value = Int8.random(in: 0...100)
            self.objectWillChange.send()
        }
    }
    
    func disconnect() {
        state = .disconnected
        
        if let updateTimer {
            updateTimer.invalidate()
        }
    }
}
