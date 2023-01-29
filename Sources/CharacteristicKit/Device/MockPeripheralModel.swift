//
//  MockPeripheralModel.swift
//
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth

public protocol MockPeripheralModel: GenericPeripheralModel {}

extension MockPeripheralModel {
    func connect() {
        self.state = .connected
    }

    func disconnect() {
        self.state = .disconnected
    }
}
