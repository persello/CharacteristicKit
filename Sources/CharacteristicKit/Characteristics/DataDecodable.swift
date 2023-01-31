//
//  DataDecodable.swift
//
//
//  Created by Riccardo Persello on 31/01/23.
//

import Foundation

protocol DataDecodable {
  func decode(from data: Data) -> Self?
}

extension Int8: DataDecodable {
  func decode(from data: Data) -> Int8? {
    return data.withUnsafeBytes { $0.load(as: Int8.self) }
  }
}

extension UInt8: DataDecodable {
  func decode(from data: Data) -> UInt8? {
    return data.withUnsafeBytes { $0.load(as: UInt8.self) }
  }
}

extension Int16: DataDecodable {
  func decode(from data: Data) -> Int16? {
    return data.withUnsafeBytes { $0.load(as: Int16.self) }
  }
}

extension UInt16: DataDecodable {
  func decode(from data: Data) -> UInt16? {
    return data.withUnsafeBytes { $0.load(as: UInt16.self) }
  }
}

extension Int32: DataDecodable {
  func decode(from data: Data) -> Int32? {
    return data.withUnsafeBytes { $0.load(as: Int32.self) }
  }
}

extension UInt32: DataDecodable {
  func decode(from data: Data) -> UInt32? {
    return data.withUnsafeBytes { $0.load(as: UInt32.self) }
  }
}

extension Int64: DataDecodable {
  func decode(from data: Data) -> Int64? {
    return data.withUnsafeBytes { $0.load(as: Int64.self) }
  }
}

extension UInt64: DataDecodable {
  func decode(from data: Data) -> UInt64? {
    return data.withUnsafeBytes { $0.load(as: UInt64.self) }
  }
}

extension Int: DataDecodable {
  func decode(from data: Data) -> Int? {
    return data.withUnsafeBytes { $0.load(as: Int.self) }
  }
}

extension UInt: DataDecodable {
  func decode(from data: Data) -> UInt? {
    return data.withUnsafeBytes { $0.load(as: UInt.self) }
  }
}

extension Float16: DataDecodable {
  func decode(from data: Data) -> Float16? {
    return data.withUnsafeBytes { $0.load(as: Float16.self) }
  }
}

extension Float64: DataDecodable {
  func decode(from data: Data) -> Float64? {
    return data.withUnsafeBytes { $0.load(as: Float64.self) }
  }
}

extension String: DataDecodable {
  func decode(from data: Data) -> String? {
    if let encoding = data.stringEncoding {
      // We are SURE that T is String. We just checked.
      return String(data: data, encoding: encoding)
    }

    return nil
  }
}
