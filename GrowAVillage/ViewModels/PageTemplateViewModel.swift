import SwiftUI
import SwiftData

@Observable
final class PageTemplateViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var template: Page
    var error: Error?
    var showError = false
    var isLoading = false
    var showingSaveAlert = false
    var showDeleteConfirmation = false
    var showModuleCreator = false
    
    init(dataManager: DataManager, template: Page) {
        self.dataManager = dataManager
        self.template = template
    }
    
    @MainActor
    func saveTemplate() async {
        isLoading = true
        do {
            template.isTemplate = true
            try await dataManager.savePage(template)
            showingSaveAlert = true
            analytics.track(.saveAction("template"))
            logger.log("Template saved: \(template.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func deleteTemplate() async {
        isLoading = true
        do {
            try await dataManager.deletePage(template)
            analytics.track(.userAction("delete_template", ["template_id": template.id.uuidString]))
            logger.log("Template deleted: \(template.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func createPageFromTemplate() async -> Page? {
        isLoading = true
        do {
            let newPage = try await dataManager.createPageFromTemplate(template)
            analytics.track(.userAction("create_page", ["template_id": template.id.uuidString]))
            logger.log("Page created from template: \(template.title)", category: .data)
            isLoading = false
            return newPage
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
            isLoading = false
            return nil
        }
    }
    
    @MainActor
    func duplicateTemplate() async {
        isLoading = true
        do {
            let newTemplate = template.createTemplate(title: "\(template.title) Copy")
            try await dataManager.savePage(newTemplate)
            analytics.track(.userAction("duplicate_template", ["source_template_id": template.id.uuidString]))
            logger.log("Template duplicated: \(template.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    func addModule(_ module: Module) {
        template.modules.append(module)
        logger.log("Module added to template: \(module.title)", category: .data)
    }
    
    func removeModule(_ module: Module) {
        template.modules.removeAll { $0.id == module.id }
        logger.log("Module removed from template: \(module.title)", category: .data)
    }
    
    func moveModule(from source: IndexSet, to destination: Int) {
        template.modules.move(fromOffsets: source, toOffset: destination)
        logger.log("Modules reordered in template: \(template.title)", category: .data)
    }
    
    func validateTemplate() -> Bool {
        let isValid = template.validate()
        if !isValid {
            logger.log("Template validation failed: \(template.title)", category: .data)
        }
        return isValid
    }
}
