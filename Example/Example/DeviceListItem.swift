//
//  DeviceListItem.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import SwiftUI
import SFSafeSymbols

struct DeviceListItem: View {
    var device: DeviceModel
    
    var batteryIcon: SFSymbol {
        switch device.batteryLevel.value {
        case 0..<12: return .battery0
        case 13..<37: return .battery25
        case 38..<62: return .battery50
        case 63..<87: return .battery75
        case 88...100: return .battery100
        default: return .bolt
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .bold()
                
                HStack {
                    Text("Apple Inc. A2118")
                    Text("C07FN6D1GZ98L")
                        .monospaced()
                }
                
                Text("\(Image(systemSymbol: batteryIcon)) \(device.batteryLevel.value)%")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Text("Connect")
            }
        }
    }
}

struct DeviceListItem_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListItem(device: DeviceModel())
    }
}
