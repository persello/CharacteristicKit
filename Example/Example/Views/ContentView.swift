//
//  ContentView.swift
//  Example
//
//  Created by Riccardo Persello on 02/01/23.
//

import SwiftUI

struct ContentView: View {
    @State var devices: [DeviceModel] = []
    @State var fakeDevices: [FakeDeviceModel] = [FakeDeviceModel()]
    var body: some View {
        NavigationView {
            List {
                Section("Fake devices") {
                    ForEach(fakeDevices, id: \.name) { device in
                        DeviceListItem(device: device)
                            .swipeActions {
                                Button(role: .destructive) {
                                    fakeDevices.removeAll { d in
                                        d.name == device.name
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }

                Section("Real devices") {
                    ForEach(devices) { device in
                        DeviceListItem(device: device)
                    }
                }
            }
            #if os(macOS)
            .listStyle(.inset(alternatesRowBackgrounds: true))
            #endif
            .toolbar {
                Button {
                    Task {
                        devices = []
                        if let stream = DeviceModel.discover() {
                            for await deviceList in stream {
                                devices = deviceList.filter({ model in
                                    model.peripheral.name != nil
                                })
                            }
                        }
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }

                Button {
                    fakeDevices.append(FakeDeviceModel())
                } label: {
                    Label("Create mock device", systemImage: "plus")
                }
            }
            .navigationTitle("Batteries")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
