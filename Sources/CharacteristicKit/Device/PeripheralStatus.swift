//
//  PeripheralStatus.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation

/// Represents the status of the connection to the peripheral.
public enum PeripheralStatus: CustomStringConvertible {
    case disconnected
    case connecting
    case connected
    
    public var description: String {
        switch self {
        case .connected: return "connected"
        case .connecting: return "connecting"
        case .disconnected: return "disconnected"
        }
    }
}
