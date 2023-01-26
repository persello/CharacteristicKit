//
//  PublishedCharacteristic.swift
//
//
//  Created by Riccardo Persello on 26/01/23.
//

import Foundation
import Combine

protocol PublishedCharacteristic {
    mutating func getInnerCharacteristic() async -> any DiscoverableCharacteristic
}

extension Combine.Published: PublishedCharacteristic where Value: DiscoverableCharacteristic {
    mutating func getInnerCharacteristic() async -> any DiscoverableCharacteristic {
        await withCheckedContinuation({ continuation in
            _ = self.projectedValue.sink { characteristic in
                continuation.resume(returning: characteristic)
            }
        })
    }
}
