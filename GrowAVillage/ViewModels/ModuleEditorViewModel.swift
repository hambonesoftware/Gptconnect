import SwiftUI
import SwiftData

@Observable
final class ModuleEditorViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var title: String
    var components: [Component]
    var error: Error?
    var showError = false
    var showComponentSheet = false
    var componentToEdit: Component?
    var componentToDelete: Component?
    var showDeleteConfirmation = false
    var isLoading = false
    
    private let originalModule: Module
    
    init(dataManager: DataManager, module: Module) {
        self.dataManager = dataManager
        self.originalModule = module
        self.title = module.title
        self.components = module.components
    }
    
    var isValid: Bool {
        !title.isEmpty && components.allSatisfy { $0.validateValue() }
    }
    
    @MainActor
    func save() async {
        isLoading = true
        do {
            var updatedModule = originalModule
            updatedModule.title = title
            updatedModule.components = components
            
            try await dataManager.saveModule(updatedModule, in: updatedModule.page!)
            analytics.track(.saveAction("module_edit"))
            logger.log("Module edited: \(title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    func addComponent(_ component: Component) {
        components.append(component)
        logger.log("Component added to module: \(component.title)", category: .data)
    }
    
    func updateComponent(_ component: Component) {
        if let index = components.firstIndex(where: { $0.id == component.id }) {
            components[index] = component
            logger.log("Component updated: \(component.title)", category: .data)
        }
    }
    
    func duplicateComponent(_ component: Component) {
        let newComponent = component.duplicateComponent()
        components.append(newComponent)
        logger.log("Component duplicated: \(component.title)", category: .data)
    }
    
    func deleteComponent(_ component: Component) {
        components.removeAll { $0.id == component.id }
        logger.log("Component deleted: \(component.title)", category: .data)
    }
    
    func moveComponent(from source: IndexSet, to destination: Int) {
        components.move(fromOffsets: source, toOffset: destination)
        logger.log("Components reordered in module", category: .data)
    }
    
    func confirmDeleteComponent(_ component: Component) {
        componentToDelete = component
        showDeleteConfirmation = true
    }
    
    func resetToDefaults() {
        title = originalModule.title
        components = originalModule.components
        logger.log("Module reset to defaults: \(title)", category: .data)
    }
}
