import Foundation
import SwiftData

struct AnyCodable: Codable, Equatable {
    private var storage: Storage
    
    var value: Any {
        storage.value
    }
    
    init(_ value: Any) {
        if let codable = value as? Codable {
            storage = .codable(codable)
        } else {
            storage = .string(String(describing: value))
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            storage = .codable(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            storage = .codable(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            storage = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            storage = .codable(boolValue)
        } else if let dateValue = try? container.decode(Date.self) {
            storage = .codable(dateValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch storage {
        case .codable(let value):
            try container.encode(value)
        case .string(let string):
            try container.encode(string)
        }
    }
    
    private enum Storage {
        case codable(Codable)
        case string(String)
        
        var value: Any {
            switch self {
            case .codable(let value):
                return value
            case .string(let string):
                return string
            }
        }
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.storage, rhs.storage) {
        case (.codable(let lhsValue as Int), .codable(let rhsValue as Int)):
            return lhsValue == rhsValue
        case (.codable(let lhsValue as Double), .codable(let rhsValue as Double)):
            return lhsValue == rhsValue
        case (.codable(let lhsValue as String), .codable(let rhsValue as String)):
            return lhsValue == rhsValue
        case (.codable(let lhsValue as Bool), .codable(let rhsValue as Bool)):
            return lhsValue == rhsValue
        case (.codable(let lhsValue as Date), .codable(let rhsValue as Date)):
            return lhsValue == rhsValue
        case (.string(let lhsString), .string(let rhsString)):
            return lhsString == rhsString
        default:
            return false
        }
    }
}

// MARK: - Type Safe Accessors
extension AnyCodable {
    var stringValue: String? {
        value as? String
    }
    
    var intValue: Int? {
        value as? Int
    }
    
    var doubleValue: Double? {
        if let double = value as? Double {
            return double
        }
        if let int = value as? Int {
            return Double(int)
        }
        return nil
    }
    
    var boolValue: Bool? {
        value as? Bool
    }
    
    var dateValue: Date? {
        value as? Date
    }
}
