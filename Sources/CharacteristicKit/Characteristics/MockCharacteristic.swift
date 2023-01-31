//
//  MockCharacteristic.swift
//
//
//  Created by Riccardo Persello on 16/12/22.
//

import Foundation
import CoreBluetooth

/// Represents a mock of ``Characteristic``, useful for creating simulated device models.
public class MockCharacteristic<T: Equatable>: GeneralCharacteristicProtocol {

    /// The wrapped value of this property.
    @Published public var value: T

    /// A fake, empty identifier.
    public let uuid: CBUUID = CBUUID()

    /// Creates a new characteristic mock.
    /// - Parameter constant: The initial value of this property.
    public init(constant: T) {
        self.value = constant
    }

    public func setLocalValue(data: Data) {
        DispatchQueue.main.async {
            self.value = data.withUnsafeBytes({$0.load(as: T.self)})
        }
    }

    public func setLocalValue(value: T) {
        DispatchQueue.main.async {
            self.value = value
        }
    }

    public static func == (lhs: MockCharacteristic<T>, rhs: MockCharacteristic<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
