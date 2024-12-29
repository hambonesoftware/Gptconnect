import Foundation
import SwiftData

@Model
final class Component {
    var id: UUID
    var type: ComponentType
    var title: String
    @Attribute(.transformable) private var valueData: Data
    @Relationship(.cascade) var configuration: ComponentConfiguration?
    @Transient var isValid: Bool = true
    
    var value: AnyCodable {
        get {
            do {
                return try JSONDecoder().decode(AnyCodable.self, from: valueData)
            } catch {
                return type.defaultValue
            }
        }
        set {
            do {
                valueData = try JSONEncoder().encode(newValue)
                validateValue()
            } catch {
                valueData = try! JSONEncoder().encode(type.defaultValue)
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        type: ComponentType,
        title: String,
        value: AnyCodable? = nil,
        configuration: ComponentConfiguration? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        
        let initialValue = value ?? type.defaultValue
        do {
            self.valueData = try JSONEncoder().encode(initialValue)
        } catch {
            self.valueData = try! JSONEncoder().encode(type.defaultValue)
        }
        
        self.configuration = configuration ?? ComponentConfiguration(
            isRequired: false,
            placeholder: "Enter \(title.lowercased())",
            validationRules: type.validationType.validationRules
        )
        
        validateValue()
    }
    
     func validateValue() {
        isValid = configuration?.validate(value.value) ?? true
    }
    
    func duplicateComponent() -> Component {
        return Component(
            type: self.type,
            title: "\(self.title) Copy",
            value: self.value,
            configuration: self.configuration
        )
    }
    // MARK: - Type Safe Accessors
    var stringValue: String {
        get { value.stringValue ?? "" }
        set { value = AnyCodable(newValue) }
    }
    
    var numberValue: Double {
        get { value.doubleValue ?? 0.0 }
        set { value = AnyCodable(newValue) }
    }
    
    var dateValue: Date {
        get { value.dateValue ?? Date() }
        set { value = AnyCodable(newValue) }
    }
    
    var boolValue: Bool {
        get { value.boolValue ?? false }
        set { value = AnyCodable(newValue) }
    }
    
    var pickerOptions: [String] {
        configuration?.pickerOptions ?? ["Option 1", "Option 2", "Option 3"]
    }
}
