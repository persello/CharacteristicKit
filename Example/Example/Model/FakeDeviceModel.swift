//
//  FakeDeviceModel.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import Foundation
import CharacteristicKit
import CoreBluetooth
import Combine

class FakeDeviceModel: DeviceModelProtocol, MockPeripheralModel {
    var cancellable: AnyCancellable?
    
    var name: String = "Fake device \(Int.random(in: 0...1000))"
    var batteryLevel = MockCharacteristic<Int8>(constant: 45)
    var manufacturerName = MockCharacteristic<String>(constant: "Antani Inc.")
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
