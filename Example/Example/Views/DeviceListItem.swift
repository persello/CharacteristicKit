//
//  DeviceListItem.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import SwiftUI
import SFSafeSymbols

struct DeviceListItem<Device: DeviceModelProtocol>: View {
    @ObservedObject var device: Device
    
    var batteryIcon: SFSymbol {
        switch device.batteryLevel.value {
        case 0..<12: return .battery0
        case 12..<37: return .battery25
        case 37..<62: return .battery50
        case 62..<87: return .battery75
        case 87...100: return .battery100
        default: return .bolt
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .bold()
                
                if device.state == .connected {
                    Text("\(Image(systemSymbol: batteryIcon)) \(device.batteryLevel.value)%")
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if device.state == .connected {
                Button {
                    device.disconnect()
                } label: {
                    Text("Disconnect")
                }
            } else if device.state == .disconnected {
                Button {
                    device.connect()
                } label: {
                    Text("Connect")
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct DeviceListItem_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListItem(device: FakeDeviceModel())
    }
}
