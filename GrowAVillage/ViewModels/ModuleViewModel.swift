import SwiftUI
import SwiftData

@Observable
final class ModuleViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var module: Module
    var error: Error?
    var showError = false
    var isLoading = false
    var showingDeleteConfirmation = false
    var showingComponentEditor = false
    var selectedComponent: Component?
    
    init(dataManager: DataManager, module: Module) {
        self.dataManager = dataManager
        self.module = module
    }
    
    @MainActor
    func saveModule() async {
        isLoading = true
        do {
            try await dataManager.saveModule(module, in: module.page)
            analytics.track(.saveAction("module"))
            logger.log("Module saved: \(module.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func deleteModule() async {
        isLoading = true
        do {
            await MainActor.run {
                module.page?.modules.removeAll { $0.id == module.id }
            }
            try await dataManager.savePage(module.page!)
            analytics.track(.userAction("delete_module", ["module_id": module.id.uuidString]))
            logger.log("Module deleted: \(module.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func duplicateModule() async {
        isLoading = true
        do {
            let newModule = module.createTemplate(title: "\(module.title) Copy")
            await MainActor.run {
                module.page?.modules.append(newModule)
            }
            try await dataManager.savePage(module.page!)
            analytics.track(.userAction("duplicate_module", ["source_module_id": module.id.uuidString]))
            logger.log("Module duplicated: \(module.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    func confirmDelete() {
        showingDeleteConfirmation = true
    }
    
    func editComponent(_ component: Component) {
        selectedComponent = component
        showingComponentEditor = true
    }
    
    func validateModule() -> Bool {
        let isValid = module.validate()
        if !isValid {
            logger.log("Module validation failed: \(module.title)", category: .data)
        }
        return isValid
    }
    
    func resetToDefaults() {
        module.resetToDefaults()
        logger.log("Module reset to defaults: \(module.title)", category: .data)
    }
    
    func getValues() -> [String: Any] {
        return module.getValues()
    }
}
