import SwiftUI
import SwiftData

@Observable
final class PageEditorViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var title: String
    var modules: [Module]
    var error: Error?
    var showError = false
    var showModuleSheet = false
    var isLoading = false
    var hasUnsavedChanges = false
    
    private let originalPage: Page
    
    init(dataManager: DataManager, page: Page) {
        self.dataManager = dataManager
        self.originalPage = page
        self.title = page.title
        self.modules = page.modules
    }
    
    var isValid: Bool {
        !title.isEmpty && modules.allSatisfy { $0.validate() }
    }
    
    @MainActor
    func savePage() async {
        isLoading = true
        do {
            var updatedPage = originalPage
            updatedPage.title = title
            updatedPage.modules = modules
            
            try await dataManager.savePage(updatedPage)
            hasUnsavedChanges = false
            analytics.track(.saveAction("page_edit"))
            logger.log("Page edited: \(title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    func addModule(_ module: Module) {
        modules.append(module)
        hasUnsavedChanges = true
        logger.log("Module added to page: \(module.title)", category: .data)
    }
    
    func removeModule(at index: Int) {
        modules.remove(at: index)
        hasUnsavedChanges = true
        logger.log("Module removed from page", category: .data)
    }
    
    func moveModule(from source: IndexSet, to destination: Int) {
        modules.move(fromOffsets: source, toOffset: destination)
        hasUnsavedChanges = true
        logger.log("Modules reordered in page", category: .data)
    }
    
    func resetToDefaults() {
        title = originalPage.title
        modules = originalPage.modules
        hasUnsavedChanges = true
        logger.log("Page reset to defaults: \(title)", category: .data)
    }
}
