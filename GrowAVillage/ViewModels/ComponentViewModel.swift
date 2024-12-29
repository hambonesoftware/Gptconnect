import SwiftUI
import SwiftData

@Observable
final class ComponentViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var component: Component
    var error: Error?
    var showError = false
    var isLoading = false
    
    init(dataManager: DataManager, component: Component) {
        self.dataManager = dataManager
        self.component = component
    }
    
    // MARK: - Value Bindings
    var stringValue: String {
        get { component.stringValue }
        set {
            component.stringValue = newValue
            validateAndSave()
        }
    }
    
    var numberValue: Double {
        get { component.numberValue }
        set {
            component.numberValue = newValue
            validateAndSave()
        }
    }
    
    var dateValue: Date {
        get { component.dateValue }
        set {
            component.dateValue = newValue
            validateAndSave()
        }
    }
    
    var boolValue: Bool {
        get { component.boolValue }
        set {
            component.boolValue = newValue
            validateAndSave()
        }
    }
    
    var pickerOptions: [String] {
        component.pickerOptions
    }
    
    // MARK: - Update Methods
    @MainActor
    private func validateAndSave() {
        Task {
            do {
                try await dataManager.updateComponent(component, value: component.value.value)
                analytics.track(.componentInteraction(component.id.uuidString, "update"))
                logger.log("Component updated: \(component.title)", category: .data)
            } catch {
                self.error = error
                showError = true
                logger.error(error, category: .data)
            }
        }
    }
    
    func validateValue() -> Bool {
        let isValid = component.validateValue()
        if !isValid {
            logger.log("Component validation failed: \(component.title)", category: .data)
        }
        return isValid
    }
    
    // MARK: - Configuration
    var configuration: ComponentConfiguration {
        component.configuration ?? ComponentConfiguration()
    }
    
    var placeholder: String {
        configuration.placeholder ?? "Enter \(component.type.displayName.lowercased())"
    }
    
    var helperText: String? {
        configuration.helperText
    }
    
    var isRequired: Bool {
        configuration.isRequired
    }
    
    var errorMessage: String? {
        configuration.errorMessage
    }
    
    // MARK: - Analytics
    func trackInteraction(_ action: String) {
        analytics.track(.componentInteraction(
            component.id.uuidString,
            action
        ))
    }
}
