import Foundation
import SwiftData

enum ValidationType {
    case text
    case number
    case date
    case boolean
    
    var validationRules: [ValidationRule] {
        switch self {
        case .text:
            return [.required, .minLength(1), .maxLength(1000)]
        case .number:
            return [.required, .range(min: nil, max: nil)]
        case .date:
            return [.required, .dateRange(from: nil, to: nil)]
        case .boolean:
            return [.required]
        }
    }
}

enum ValidationRule {
    case required
    case minLength(Int)
    case maxLength(Int)
    case range(min: Double?, max: Double?)
    case dateRange(from: Date?, to: Date?)
    case regex(String)
    case custom((Any) -> Bool)
}

@Model
final class ComponentConfiguration {
    var id: UUID
    var isRequired: Bool
    var placeholder: String?
    var helperText: String?
    var validationRules: [ValidationRule]?
    var pickerOptions: [String]
    var errorMessage: String?
    var defaultValue: AnyCodable?
    
    init(
        id: UUID = UUID(),
        isRequired: Bool = false,
        placeholder: String? = nil,
        helperText: String? = nil,
        validationRules: [ValidationRule]? = nil,
        pickerOptions: [String] = ["Option 1", "Option 2", "Option 3"],
        errorMessage: String? = nil,
        defaultValue: AnyCodable? = nil
    ) {
        self.id = id
        self.isRequired = isRequired
        self.placeholder = placeholder
        self.helperText = helperText
        self.validationRules = validationRules
        self.pickerOptions = pickerOptions
        self.errorMessage = errorMessage
        self.defaultValue = defaultValue
    }
    
    func validate(_ value: Any) -> Bool {
        guard let rules = validationRules else { return true }
        
        for rule in rules {
            let isValid = validateRule(rule, value: value)
            if !isValid {
                return false
            }
        }
        
        return true
    }
    
    private func validateRule(_ rule: ValidationRule, value: Any) -> Bool {
        switch rule {
        case .required:
            if let string = value as? String {
                return !string.isEmpty
            }
            return value is Any
            
        case .minLength(let min):
            guard let string = value as? String else { return false }
            return string.count >= min
            
        case .maxLength(let max):
            guard let string = value as? String else { return false }
            return string.count <= max
            
        case .range(let min, let max):
            guard let number = (value as? NSNumber)?.doubleValue else { return false }
            if let min = min, number < min { return false }
            if let max = max, number > max { return false }
            return true
            
        case .dateRange(let from, let to):
            guard let date = value as? Date else { return false }
            if let from = from, date < from { return false }
            if let to = to, date > to { return false }
            return true
            
        case .regex(let pattern):
            guard let string = value as? String else { return false }
            return string.range(of: pattern, options: .regularExpression) != nil
            
        case .custom(let validator):
            return validator(value)
        }
    }
}
