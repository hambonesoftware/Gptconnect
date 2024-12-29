import Foundation
import SwiftData

actor DataManager {
    private let modelContext: ModelContext
    private let logger = AppLogger.shared
    private let analytics = Analytics.shared
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Page Operations
    func fetchPages() async throws -> [Page] {
        logger.log("Fetching pages", category: .data)
        let descriptor = FetchDescriptor<Page>(
            predicate: #Predicate<Page> { !$0.isTemplate },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            
        )
        
        do {
            let pages = try modelContext.fetch(descriptor)
            logger.log("Successfully fetched \(pages.count) pages", category: .data)
            return pages
        } catch {
            logger.error(error, category: .data)
            throw AppError.loadFailed(error)
        }
    }
    
    func savePage(_ page: Page) async throws {
        logger.log("Saving page: \(page.title)", category: .data)
        
        if !modelContext.hasChanges(for: page) {
            modelContext.insert(page)
        }
        
        do {
            try modelContext.save()
            analytics.track(.saveAction("page"))
            logger.log("Successfully saved page: \(page.title)", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.saveFailed(error)
        }
    }
    
    func deletePage(_ page: Page) async throws {
        logger.log("Deleting page: \(page.title)", category: .data)
        
        modelContext.delete(page)
        
        do {
            try modelContext.save()
            logger.log("Successfully deleted page: \(page.title)", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.deleteFailed(error)
        }
    }
    
    // MARK: - Template Operations
    func fetchTemplates() async throws -> [Page] {
        logger.log("Fetching templates", category: .data)
        let descriptor = FetchDescriptor<Page>(
            sortBy: [SortDescriptor(\.title)],
            predicate: #Predicate<Page> { $0.isTemplate }
        )
        
        do {
            let templates = try modelContext.fetch(descriptor)
            logger.log("Successfully fetched \(templates.count) templates", category: .data)
            return templates
        } catch {
            logger.error(error, category: .data)
            throw AppError.loadFailed(error)
        }
    }
    
    func createPageFromTemplate(_ template: Page) async throws -> Page {
        logger.log("Creating page from template: \(template.title)", category: .data)
        let page = template.createPageFromTemplate()
        
        do {
            try await savePage(page)
            logger.log("Successfully created page from template", category: .data)
            return page
        } catch {
            logger.error(error, category: .data)
            throw AppError.saveFailed(error)
        }
    }
    
    // MARK: - Module Operations
    func saveModule(_ module: Module, in page: Page) async throws {
        logger.log("Saving module: \(module.title)", category: .data)
        
        await MainActor.run {
            if !page.modules.contains(where: { $0.id == module.id }) {
                page.modules.append(module)
            }
        }
        
        do {
            try modelContext.save()
            analytics.track(.saveAction("module"))
            logger.log("Successfully saved module", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.saveFailed(error)
        }
    }
    
    // MARK: - Component Operations (continued)
    func updateComponent(_ component: Component, value: Any) async throws {
        logger.log("Updating component: \(component.title)", category: .data)
        
        await MainActor.run {
            component.value = AnyCodable(value)
        }
        
        do {
            try modelContext.save()
            analytics.track(.componentInteraction(component.id.uuidString, "update"))
            logger.log("Successfully updated component value", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.saveFailed(error)
        }
    }
    
    func deleteComponent(_ component: Component) async throws {
        logger.log("Deleting component", category: .data)
        
        modelContext.delete(component)
        
        do {
            try modelContext.save()
            logger.log("Successfully deleted component", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.deleteFailed(error)
        }
    }
    
    // MARK: - Export/Import Operations
    func exportData() async throws -> Data {
        logger.log("Exporting data", category: .data)
        
        let pages = try await fetchPages()
        let templates = try await fetchTemplates()
        
        let exportData = ExportData(
            pages: pages.map { $0.export() },
            templates: templates.map { $0.export() }
        )
        
        do {
            let data = try JSONEncoder().encode(exportData)
            logger.log("Successfully exported data", category: .data)
            return data
        } catch {
            logger.error(error, category: .data)
            throw AppError.custom("Failed to export data")
        }
    }
    
    func importData(_ data: Data) async throws {
        logger.log("Importing data", category: .data)
        
        do {
            let importData = try JSONDecoder().decode(ExportData.self, from: data)
            
            // Clear existing data
            try await clearAllData()
            
            // Import templates first
            for templateData in importData.templates {
                if let template = try? Page.from(exportData: templateData) {
                    try await savePage(template)
                }
            }
            
            // Then import pages
            for pageData in importData.pages {
                if let page = try? Page.from(exportData: pageData) {
                    try await savePage(page)
                }
            }
            
            logger.log("Successfully imported data", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.custom("Failed to import data")
        }
    }
    
    // MARK: - Utility Operations
    func clearAllData() async throws {
        logger.log("Clearing all data", category: .data)
        
        do {
            try modelContext.delete(model: Page.self)
            try modelContext.delete(model: Module.self)
            try modelContext.delete(model: Component.self)
            try modelContext.save()
            logger.log("Successfully cleared all data", category: .data)
        } catch {
            logger.error(error, category: .data)
            throw AppError.deleteFailed(error)
        }
    }
    
    func validate() async throws {
        logger.log("Validating data", category: .data)
        
        let pages = try await fetchPages()
        let templates = try await fetchTemplates()
        
        var validationErrors: [String] = []
        
        // Validate pages
        for page in pages {
            if !page.validate() {
                validationErrors.append("Invalid page: \(page.title)")
            }
        }
        
        // Validate templates
        for template in templates {
            if !template.validate() {
                validationErrors.append("Invalid template: \(template.title)")
            }
        }
        
        if !validationErrors.isEmpty {
            logger.log("Validation failed: \(validationErrors.joined(separator: ", "))", category: .data)
            throw AppError.modelValidationFailed(validationErrors.joined(separator: ", "))
        }
        
        logger.log("Data validation successful", category: .data)
    }
}

// MARK: - Export Data Structure
private struct ExportData: Codable {
    let pages: [[String: Any]]
    let templates: [[String: Any]]
    
    enum CodingKeys: String, CodingKey {
        case pages
        case templates
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pages.map { try JSONSerialization.data(withJSONObject: $0) }, forKey: .pages)
        try container.encode(templates.map { try JSONSerialization.data(withJSONObject: $0) }, forKey: .templates)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pagesData = try container.decode([Data].self, forKey: .pages)
        let templatesData = try container.decode([Data].self, forKey: .templates)
        
        pages = try pagesData.map { try JSONSerialization.jsonObject(with: $0) as! [String: Any] }
        templates = try templatesData.map { try JSONSerialization.jsonObject(with: $0) as! [String: Any] }
    }
    
    init(pages: [[String: Any]], templates: [[String: Any]]) {
        self.pages = pages
        self.templates = templates
    }
}
