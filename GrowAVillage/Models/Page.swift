import Foundation
import SwiftData

@Model
final class Page {
    var id: UUID
    var title: String
    @Relationship(.cascade) var modules: [Module]
    var isTemplate: Bool
    var createdAt: Date
    var updatedAt: Date
    var metadata: [String: AnyCodable]?
    
    @Transient var isDirty: Bool = false
    @Transient var isValid: Bool {
        modules.allSatisfy { $0.isValid }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        modules: [Module] = [],
        isTemplate: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        metadata: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.title = title
        self.modules = modules
        self.isTemplate = isTemplate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.metadata = metadata
    }
    
    // MARK: - Module Management
    func addModule(_ module: Module) {
        modules.append(module)
        isDirty = true
        updateTimestamp()
    }
    
    func removeModule(_ module: Module) {
        modules.removeAll { $0.id == module.id }
        isDirty = true
        updateTimestamp()
    }
    
    func moveModule(from source: IndexSet, to destination: Int) {
        modules.move(fromOffsets: source, toOffset: destination)
        isDirty = true
        updateTimestamp()
    }
    
    // MARK: - Data Management
    func getAllValues() -> [String: [String: Any]] {
        var values: [String: [String: Any]] = [:]
        modules.forEach { module in
            values[module.title] = module.getValues()
        }
        return values
    }
    
    func resetToDefaults() {
        modules.forEach { module in
            module.resetToDefaults()
        }
        isDirty = true
        updateTimestamp()
    }
    
    // MARK: - Template Management
    func createTemplate(title: String? = nil) -> Page {
        let templateModules = modules.map { module in
            module.createTemplate()
        }
        
        return Page(
            title: title ?? "\(self.title) Template",
            modules: templateModules,
            isTemplate: true,
            metadata: ["sourcePageId": AnyCodable(self.id.uuidString)]
        )
    }
    
    func createPageFromTemplate() -> Page {
        let pageModules = modules.map { module in
            Module(
                title: module.title,
                components: module.components.map { component in
                    Component(
                        type: component.type,
                        title: component.title,
                        value: component.type.defaultValue,
                        configuration: component.configuration
                    )
                }
            )
        }
        
        return Page(
            title: title,
            modules: pageModules,
            isTemplate: false,
            metadata: ["templateId": AnyCodable(self.id.uuidString)]
        )
    }
    
    // MARK: - Validation
    func validate() -> Bool {
        let isValid = modules.allSatisfy { $0.validate() }
        return isValid
    }
    
    // MARK: - Export
    func export() -> [String: Any] {
        var export: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "isTemplate": isTemplate,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "modules": modules.map { module in
                [
                    "id": module.id.uuidString,
                    "title": module.title,
                    "values": module.getValues()
                ]
            }
        ]
        
        if let metadata = metadata {
            export["metadata"] = metadata.mapValues { $0.value }
        }
        
        return export
    }
    
    // MARK: - Private Helpers
    private func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - Hashable
extension Page: Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
