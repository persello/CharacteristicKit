//
//  DataDecodable.swift
//
//
//  Created by Riccardo Persello on 31/01/23.
//

import Foundation

public protocol DataDecodable {
  static func decode(from data: Data) -> Self?
}

extension Bool: DataDecodable {
    public static func decode(from data: Data) -> Bool? {
        guard data.count == 1 else {
            return nil
        }
        
        return data.withUnsafeBytes { $0.load(as: Int8.self) != 0 }
    }
}

extension Int8: DataDecodable {
    public static func decode(from data: Data) -> Int8? {
    guard data.count == 1 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Int8.self) }
  }
}

extension UInt8: DataDecodable {
    public static func decode(from data: Data) -> UInt8? {
    guard data.count == 1 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: UInt8.self) }
  }
}

extension Int16: DataDecodable {
  public static func decode(from data: Data) -> Int16? {
    guard data.count == 2 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Int16.self) }
  }
}

extension UInt16: DataDecodable {
  public static func decode(from data: Data) -> UInt16? {
    guard data.count == 2 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: UInt16.self) }
  }
}

extension Int32: DataDecodable {
  public static func decode(from data: Data) -> Int32? {
    guard data.count == 4 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Int32.self) }
  }
}

extension UInt32: DataDecodable {
  public static func decode(from data: Data) -> UInt32? {
    guard data.count == 4 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: UInt32.self) }
  }
}

extension Int64: DataDecodable {
  public static func decode(from data: Data) -> Int64? {
    guard data.count == 8 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Int64.self) }
  }
}

extension UInt64: DataDecodable {
  public static func decode(from data: Data) -> UInt64? {
    guard data.count == 8 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: UInt64.self) }
  }
}

#if os(macOS)
#else
extension Float16: DataDecodable {
  public static func decode(from data: Data) -> Float16? {
    guard data.count == 2 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Float16.self) }
  }
}
#endif

extension Float32: DataDecodable {
  public static func decode(from data: Data) -> Float32? {
    guard data.count == 4 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Float32.self) }
  }
}

extension Float64: DataDecodable {
  public static func decode(from data: Data) -> Float64? {
    guard data.count == 8 else {
      return nil
    }

    return data.withUnsafeBytes { $0.load(as: Float64.self) }
  }
}

extension String: DataDecodable {
  public static func decode(from data: Data) -> String? {
    if let encoding = data.stringEncoding {
      // We are SURE that T is String. We just checked.
      return String(data: data, encoding: encoding)
    }

    return nil
  }
}
