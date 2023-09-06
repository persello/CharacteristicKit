//
//  DeviceListItem.swift
//  Example
//
//  Created by Riccardo Persello on 25/01/23.
//

import SwiftUI

struct DeviceListItem<Device: DeviceModelProtocol>: View {
    @ObservedObject var device: Device

    var batteryIcon: String {
        switch device.batteryLevel.value {
        case 0..<12: return "battery.0"
        case 12..<37: return "battery.25"
        case 37..<62: return "battery.50"
        case 62..<87: return "battery.75"
        case 87...100: return "battery.100"
        default: return "bolt"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .bold()

                if device.state == .connected {
                    HStack {
                        Text("\(device.manufacturerName.value)")
                        Text("\(Image(systemName: batteryIcon)) \(device.batteryLevel.value)%")
                            .foregroundColor(.secondary)
                    }
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
