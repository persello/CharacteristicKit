//
//  DeviceStatus.swift
//  
//
//  Created by Riccardo Persello on 14/12/22.
//

import Foundation

public enum DeviceStatus: CustomStringConvertible {
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
