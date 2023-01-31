//
//  PublishedCharacteristic.swift
//
//
//  Created by Riccardo Persello on 26/01/23.
//

import Foundation
import Combine

protocol PublishedCharacteristic {
    mutating func getInnerCharacteristic() async -> any CharacteristicProtocol
}

extension Combine.Published: PublishedCharacteristic where Value: CharacteristicProtocol {
    mutating func getInnerCharacteristic() async -> any CharacteristicProtocol {
        await withCheckedContinuation({ continuation in
            _ = self.projectedValue.sink { characteristic in
                continuation.resume(returning: characteristic)
            }
        })
    }
}
