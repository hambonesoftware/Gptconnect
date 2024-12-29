import SwiftUI
import SwiftData

@Observable
final class PageViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var page: Page
    var error: Error?
    var showError = false
    var isLoading = false
    var showingSaveAlert = false
    var showingDeleteConfirmation = false
    
    init(dataManager: DataManager, page: Page) {
        self.dataManager = dataManager
        self.page = page
    }
    
    @MainActor
    func savePage() async {
        isLoading = true
        do {
            try await dataManager.savePage(page)
            showingSaveAlert = true
            analytics.track(.saveAction("page"))
            logger.log("Page saved successfully: \(page.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func deletePage() async {
        isLoading = true
        do {
            try await dataManager.deletePage(page)
            AppRouter.shared.clearSelection()
            analytics.track(.userAction("delete_page", ["page_id": page.id.uuidString]))
            logger.log("Page deleted: \(page.title)", category: .data)
        } catch {
            self.error = error
            showError = true
            logger.error(error, category: .data)
        }
        isLoading = false
    }
    
    @MainActor
    func createTemplate() async {
        isLoading = true
        do {
            let template = page.createTemplate()
            try await dataManager.savePage(template)
            analytics.track(.userAction("create_template", ["source_page_id": page.id.uuidString]))
            logger.log("Template created from page: \(page.title)", category: .data)
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
    
    func validatePage() -> Bool {
        let isValid = page.validate()
        if !isValid {
            logger.log("Page validation failed: \(page.title)", category: .data)
        }
        return isValid
    }
    
    func exportPage() -> [String: Any] {
        return page.export()
    }
}
