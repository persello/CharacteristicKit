//
//  ContentView.swift
//  Example
//
//  Created by Riccardo Persello on 02/01/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            DeviceListItem(device: DeviceModel())
            DeviceListItem(device: DeviceModel())
            DeviceListItem(device: DeviceModel())
        }
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
