import SwiftUI
import SwiftData

@Observable
final class TemplateViewModel {
    private let dataManager: DataManager
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    var pageTemplates: [Page]
    var error: Error?
    var showError = false
    var isLoading = false
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self.pageTemplates = []
        loadPageTemplates()
    }
    
    // MARK: - Methods
    func loadPageTemplates() {
        isLoading = true
        do {
            pageTemplates = try dataManager.fetchAllPages()
            isLoading = false
        } catch {
            logger.log("Error loading page templates: \(error)")
            self.error = error
            showError = true
            isLoading = false
        }
    }
    
    func addPageTemplate(template: Page) {
        do {
            try dataManager.save(template)
            pageTemplates.append(template)
            analytics.trackEvent("Page Template Added")
        } catch {
            logger.log("Error adding page template: \(error)")
            self.error = error
            showError = true
        }
    }
    
    func deletePageTemplate(template: Page) {
        do {
            try dataManager.delete(template)
            pageTemplates.removeAll { $0.id == template.id }
            analytics.trackEvent("Page Template Deleted")
        } catch {
            logger.log("Error deleting page template: \(error)")
            self.error = error
            showError = true
        }
    }
    
    func duplicatePageTemplate(template: Page) -> Page? {
        do {
            let duplicatedTemplate = template.duplicate()
            try dataManager.save(duplicatedTemplate)
            pageTemplates.append(duplicatedTemplate)
            analytics.trackEvent("Page Template Duplicated")
            return duplicatedTemplate
        } catch {
            logger.log("Error duplicating page template: \(error)")
            self.error = error
            showError = true
            return nil
        }
    }
}
