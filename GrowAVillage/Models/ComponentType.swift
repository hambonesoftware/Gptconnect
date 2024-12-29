import Foundation

enum ComponentType: String, Codable, CaseIterable {
    case text
    case number
    case date
    case toggle
    case picker
    
    var displayName: String {
        switch self {
        case .text: return "Text Input"
        case .number: return "Number Input"
        case .date: return "Date Input"
        case .toggle: return "Toggle Switch"
        case .picker: return "Picker Select"
        }
    }
    
    var defaultValue: AnyCodable {
        switch self {
        case .text:
            return AnyCodable("")
        case .number:
            return AnyCodable(0.0)
        case .date:
            return AnyCodable(Date())
        case .toggle:
            return AnyCodable(false)
        case .picker:
            return AnyCodable("Option 1")
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text:
            return .default
        case .number:
            return .decimalPad
        case .date, .toggle, .picker:
            return .default
        }
    }
    
    var validationType: ValidationType {
        switch self {
        case .text:
            return .text
        case .number:
            return .number
        case .date:
            return .date
        case .toggle:
            return .boolean
        case .picker:
            return .text
        }
    }
}
