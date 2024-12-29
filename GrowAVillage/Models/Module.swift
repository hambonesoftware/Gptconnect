import Foundation
import SwiftData

@Model
final class Module {
    var id: UUID
    var title: String
    @Relationship(.cascade) var components: [Component]
    var order: Int
    
    @Transient var isExpanded: Bool = true
    @Transient var isValid: Bool {
        components.allSatisfy { $0.isValid }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        components: [Component] = [],
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.components = components
        self.order = order
    }
    
    // MARK: - Component Management
    func addComponent(_ component: Component) {
        components.append(component)
    }
    
    func removeComponent(_ component: Component) {
        components.removeAll { $0.id == component.id }
    }
    
    func moveComponent(from source: IndexSet, to destination: Int) {
        components.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Validation
    func validate() -> Bool {
        let isValid = components.allSatisfy { $0.isValid }
        return isValid
    }
    
    // MARK: - Data Management
    func resetToDefaults() {
        components.forEach { component in
            component.value = component.type.defaultValue
        }
    }
    
    func getValues() -> [String: Any] {
        var values: [String: Any] = [:]
        components.forEach { component in
            values[component.title] = component.value.value
        }
        return values
    }
    
    // MARK: - Template Management
    func createTemplate(title: String? = nil) -> Module {
        let templateComponents = components.map { component in
            Component(
                type: component.type,
                title: component.title,
                configuration: component.configuration
            )
        }
        
        return Module(
            title: title ?? "\(self.title) Template",
            components: templateComponents
        )
    }
}

// MARK: - Hashable
extension Module: Hashable {
    static func == (lhs: Module, rhs: Module) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
