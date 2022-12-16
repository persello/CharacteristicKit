//
//  MockPeripheralModel.swift
//  
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation

public protocol MockPeripheralModel: GenericPeripheralModel {}

extension MockPeripheralModel {
    func connect() {
        self.status = .connected
    }
    
    func disconnect() {
        self.status = .disconnected
    }
}
